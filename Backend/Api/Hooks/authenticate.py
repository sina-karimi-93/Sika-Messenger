
import falcon
from Api.api_tools import ApiTools
from Database.db_handler import Database

HOST = 'localhost'
PORT = 27017
DB_NAME = 'sika-messenger'


class Authenticate:

    def __call__(self, req, resp, resource, params) -> None:
        """
        This magic method checks user credential.
        """
        user_credential = ApiTools.extract_auth_data(req.auth)

        with Database(HOST, PORT, DB_NAME, 'users') as db:
            db: Database
            user = db.get_record({"email": user_credential['email']})

        try:
            is_match = ApiTools.check_password(
                user_credential.get('password'),
                user.get('password')
            )
            if is_match:
                req.user = user
                return

            raise falcon.HTTPUnauthorized(title='error',
                                          description="Username and Password are not matched")
        except (AttributeError, TypeError) as e:
            print(e)
            # This code runs when a user does not exists.
            raise falcon.HTTPNotFound(
                title='error', description='User is not exists')
