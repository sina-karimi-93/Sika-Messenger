from re import M
from typing import Collection
import falcon
from ..api_tools import ApiTools
from Database.db_handler import Database
from pprint import pprint

HOST = 'localhost'
PORT = 27017
DB_NAME = 'sika-messenger'


class Users:

    def on_get_login(self, req: falcon.Request, resp: falcon.Response):
        """
        This method checks the user credential and if valid
        return a valid response for authentication
        """

        user_credential = ApiTools.extract_auth_data(req.auth)

        with Database(HOST, PORT, DB_NAME, 'users') as db:
            db: Database
            user = db.get_record({"email": user_credential['email']})
        try:
            is_match = ApiTools.check_password(
                user_credential['password'],
                user['password']
            )

            if is_match:
                user = ApiTools.prepare_data_before_send(user)
                resp.media = {
                    "status": "ok",
                    "message": "User is authenticated and can login.",
                    "user": user
                }
            else:
                resp.media = {
                    "status": "error",
                    "message": "Wrong password"
                }
        except TypeError as e:
            print(e)
            resp.media = {
                "status": "error",
                "message": "User does not exists."
            }
