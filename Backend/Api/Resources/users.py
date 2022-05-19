from pprint import pprint
import falcon
from Api.api_tools import ApiTools
from Database.db_handler import Database
from Api.Hooks.authenticate import Authenticate

HOST = 'localhost'
PORT = 27017
DB_NAME = 'sika-messenger'


class Users:

    @falcon.before(Authenticate())
    def on_get_login(self, req: falcon.Request, resp: falcon.Response):
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
