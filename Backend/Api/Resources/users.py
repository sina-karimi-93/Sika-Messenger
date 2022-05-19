from pprint import pprint
import falcon
from Api.Hooks.check_user_exists import CheckUserExists
from Api.api_tools import ApiTools
from Database.db_handler import Database
from Api.Hooks.authenticate import Authenticate

HOST = 'localhost'
PORT = 27017
DB_NAME = 'sika-messenger'


class Users:

    @falcon.before(Authenticate())
    def on_post_login(self, req: falcon.Request, resp: falcon.Response):
        """
        This method checks the user credential and if valid
        return a valid response for authentication and the user data.
        """

        if req.is_auth == True:
            user = ApiTools.prepare_data_before_send(req.user)
            resp.media = {
                "status": "ok",
                "message": "User is authenticated and can login.",
                "user": user
            }
        elif req.is_auth == False:
            resp.media = {
                "status": "error",
                "message": "Wrong password."
            }
        else:
            resp.media = {
                "status": "error",
                "message": "User does not exists."
            }

    @falcon.before(CheckUserExists())
    def on_post_signup(self, req: falcon.Request, resp: falcon.Response):
        """
        This method is stands for creating new user. With a hook first 
        it checks whether the user exists or not. If does not exists then
        create new user with dedicated data.
        """

        if req.is_user_exists:
            resp.media = {
                "status": "error",
                "message": "A user with this email is currently exists"
            }
        else:
            with Database(HOST, PORT, DB_NAME, 'users') as db:
                db: Database

                user_id = db.insert_record(req.user)
            resp.media = {
                "staus": "ok",
                "message": "User successfully registered",
                "user_id": ApiTools.prepare_data_before_send(user_id)
            }
