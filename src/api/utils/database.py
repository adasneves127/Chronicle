from mariadb import Connection
from mariadb.cursors import Cursor
from dotenv import load_dotenv
from os import environ
from src.api.models.AuthModel import AuthModel
from src.api.models.Sponsor import Sponsor
from argon2 import PasswordHasher
from uuid import uuid4
from typing import Tuple, Any


class connect(Connection):
    def __init__(self, db_cluster: str | None = None):
        load_dotenv()
        super().__init__(
            user=environ['MARIADB_USERNAME'],
            passwd=environ['MARIADB_PASSWORD'],
            host=environ['MARIADB_HOST'],
            db=(db_cluster or environ['MARIADB_DEFAULT_CLUSTER']),
            port=3306
        )

    def cursor(self, cursorclass: type[Cursor] = Cursor, **kwargs):
        return super().cursor(cursorclass, **kwargs, dictionary=True)

    def doAuth(self,
               auth: AuthModel,
               request) -> Tuple[str, dict[str, Any] | None]:
        cursor = self.cursor()
        cursor.execute("""SELECT operatorID, password, addedBy,
                       DATE_FORMAT(addedDt, '%a, %b %e %Y %r') as 'addedDt',
                       updatedBy,  DATE_FORMAT(updatedDt, '%a, %b %e %Y %r') as
                       'updatedDt' FROM OPERATORS WHERE operatorID = %s""",
                       (auth.username,))
        if cursor.rowcount != 1:
            cursor.close()
            return "", None
        user: dict = cursor.fetchone()
        ph = PasswordHasher()
        if ph.verify(user['password'], auth.password):
            userToken = uuid4().hex
            userTokenCursor = self.cursor()

            userTokenCursor.execute("""INSERT INTO OPERATOR_ACCESS_TOKENS
                                    (operatorAccessTokenID, operatorID,
                                    createdDT, expireDT, createdIPAddr)
                                    VALUES (%s, %s, current_timestamp,
                                    FROM_UNIXTIME(UNIX_TIMESTAMP()+ 3600), %s);
                                    """,
                                    (userToken, user['operatorID'],
                                     request.client.host))
            self.commit()
            user.pop('password')
            return userToken, user

        return "", None

    def get_operator_by_token(self, user_info: str) -> str | None:
        cur = self.cursor()
        cur.execute("""SELECT operatorID FROM OPERATOR_ACCESS_TOKENS
                    WHERE operatorAccessTokenID=%s AND
                    expireDT > current_timestamp""",
                    (user_info,))
        if cur.rowcount != 1:
            cur.close()
            return None
        row = cur.fetchone()
        cur.close()
        return row['operatorID']

    def does_operator_have_permission(self,
                                      operatorID: str,
                                      permission: str) -> bool:
        sql = """SELECT 'x' FROM CLASS_PERMISSIONS A, CLASS_OPERATOR_LINK B
        WHERE A.classID = B.classID AND B.operatorID = %s AND
        A.permissionName = %s"""
        cur = self.cursor()
        cur.execute(sql, (operatorID, permission))
        row_count = cur.rowcount
        cur.close()
        return row_count > 0

    def does_page_require_auth(self, path, method):
        cursor = self.cursor()
        cursor.execute("""SELECT 'x' FROM AUTH_PAGES WHERE %s LIKE pageURL AND
                       allowGuest = 1 AND httpMethod = %s""", (path, method))
        return cursor.rowcount == 0

    def create_sponsor(self, sponsor: Sponsor, user_token: str):
        cursor = self.cursor()
        operator_id = self.get_operator_by_token(user_token)
        sql = "INSERT INTO SPONSORS (sponsorName, addedBy, updatedBy) VALUES "\
        "(%s, %s, %s)"
        cursor.execute(sql, (sponsor.sponsorName,
                             operator_id,
                             operator_id))
        sponsorID = cursor.lastrowid
        attributeSql = """INSERT IGNORE INTO SPONSOR_ATTRIBUTE_TYPES
        (sponsorAttributeTypeDesc, addedBy, updatedBy) VALUES (%s, %s, %s)"""
        selectAttr = """SELECT sponsorAttributeTypeID FROM
        SPONSOR_ATTRIBUTE_TYPES WHERE sponsorAttributeTypeDesc = %s"""
        addAttrSql = """INSERT INTO SPONSOR_ATTRIBUTES (sponsorID,
        sponsorAttributeTypeID, sponsorAttributeText, addedBy, updatedBy)
        VALUES (%s,%s,%s,%s,%s)"""
        for attribute in sponsor.sponsorAttributes:
            cursor.execute(attributeSql, (attribute.sponsorAttributeType,
                                          operator_id, operator_id))
            attributeID = cursor.lastrowid
            if attributeID is None:
                cursor.execute(selectAttr, (attribute.sponsorAttributeType))
                attributeID = cursor.fetchone()['sponsorAttributeTypeID']
            cursor.execute(addAttrSql, (sponsorID, attributeID,
                                        attribute.sponsorAttributeValue,
                                        operator_id, operator_id))
        self.commit()
        return sponsorID
