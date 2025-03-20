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
        return super().cursor(cursorclass, **(kwargs | {"dictionary": True}))

    def doAuth(self,
               auth: AuthModel,
               request) -> Tuple[str, dict[str, Any] | None]:
        cursor = self.cursor()
        cursor.execute("""SELECT operatorID, password, addedBy,
                       DATE_FORMAT(addedDt, GET_FORMAT(DATETIME,'ISO'))
                       as 'addedDt', updatedBy,
                       DATE_FORMAT(updatedDt, GET_FORMAT(DATETIME,'ISO')) as
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
                                      webUrl: str,
                                      method: str) -> bool:
        sql = """SELECT * FROM AUTH_PAGES WHERE pageURL = %s AND
        httpMethod = %s AND (operatorID = %s or operatorID IS NULL)"""
        cur = self.cursor()
        cur.execute(sql, (webUrl, method, operatorID))
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
    
    def get_all_operators(self):
        all_op_data = []
        for oID in self.get_all_operator_ids():
            all_op_data.append(self.get_operator(oID))
        
        return all_op_data

    def get_all_operator_ids(self):
        cursor = self.cursor()
        cursor.execute('SELECT operatorID from OPERATORS')
        return [x['operatorID'] for x in cursor.fetchall()]

    def get_operator(self, operatorID):
        opCursor = self.cursor()
        opCursor.execute("""SELECT operatorID, firstName, lastName,
                         addedBy as 'addedBy',
                         DATE_FORMAT(addedDt, GET_FORMAT(DATETIME,'ISO'))
                         as 'addedDt', updatedBy as 'updatedBy',
                         DATE_FORMAT(updatedDt, GET_FORMAT(DATETIME,'ISO'))
                         as 'updatedDt'FROM OPERATORS WHERE operatorID=%s;""",
                         (operatorID,))
        operatorData = []
        for row in opCursor.fetchall():
            contactID = self.get_operator_contact_id(operatorID)
            row['links'] = {
                "self": f"/OPERATORS?operatorID={row['operatorID']}",
                "creator": f"/OPERATORS?operatorID={row['addedBy']}",
                "updator": f"/OPERATORS?operatorID={row['updatedBy']}",
                "classes": [f"/CLASS?classID={x}" for x in
                            self.get_operator_class_ids(operatorID)]                             
            } | {
                "contact": f"/CONTACTS?contactID={contactID}",
                "sponsors": [
                    f"/SPONSORS?sponsorID={x}" for x
                    in self.get_contact_sponsors(contactID) 
                ]
            } if contactID else {}
            operatorData.append(row)
        return operatorData
    
    def get_operator_class_ids(self, operatorID):
        cursor = self.cursor()
        cursor.execute("""SELECT A.classID FROM CLASSES A,CLASS_OPERATOR_LINK B
                       WHERE A.classID = B.classID AND B.operatorID = %s""",
                       (operatorID,))
        return [x['classID'] for x in cursor.fetchall()]
        

    def get_operator_contact_id(self, operatorID):
        cursor = self.cursor()
        cursor.execute("""SELECT A.contactID FROM CONTACTS A
                       WHERE A.operatorID = %s""",
                       (operatorID,))
        row = cursor.fetchone()
        if row is None:
            return None
        return row['contactID']
    
    def get_contact_sponsors(self, contactID):
        cursor = self.cursor()
        cursor.execute("""SELECT A.sponsorID FROM SPONSORS A,
                       CONTACT_SPONSOR_LINK B WHERE A.sponsorID = B.sponsorID
                       AND B.contactID = %s""")
        return [x['sponsorID'] for x in cursor.fetchall()]
