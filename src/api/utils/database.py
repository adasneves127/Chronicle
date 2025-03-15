from mariadb import Connection
from mariadb.cursors import Cursor
from dotenv import load_dotenv
from os import environ
from src.api.models.AuthModel import AuthModel
from argon2 import PasswordHasher
from src.api.models.UserToken import UserToken
from src.api.utils.exceptions import UserTokenNotFoundException
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
               request) -> Tuple[str, dict[str,Any] | None]:
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
        cursor.execute("""SELECT 'x' FROM AUTH_PAGES WHERE pageURL = %s AND
                       allowGuest = 1 AND httpMethod = %s""", (path, method))
        return cursor.rowcount == 0
