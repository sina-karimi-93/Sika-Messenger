import falcon
from pprint import pprint
from datetime import datetime
from Database.db_handler import Database
from Api.api_tools import ApiTools
from Api.Hooks.check_user_exists import CheckUserExists
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
            req.user['create_date'] = datetime.now()
            with Database(HOST, PORT, DB_NAME, 'users') as db:
                db: Database

                user_id = db.insert_record(req.user)
            resp.media = {
                "staus": "ok",
                "message": "User successfully registered",
                "user_id": ApiTools.prepare_data_before_send(user_id)
            }

    @falcon.before(Authenticate())
    def on_patch_edit(self, req: falcon.Request, resp: falcon.Response) -> None:
        """
        This method updates users information like, name, phone_number.
        First via hooks, it checks whether the user credential is match or not. If
        matched it will update the user.
        """

        if req.is_auth:

            updated_fields = ApiTools.prepare_body_data(data=req.stream.read())

            with Database(HOST, PORT, DB_NAME, 'users') as db:
                db: Database

                matched_account = db.update_record(
                    query={"email": req.user["email"]},
                    updated_data={"$set": updated_fields},
                )
            if matched_account:
                resp.media = {
                    "status": "ok",
                    "message": "Desired document successfully updated"
                }
                return
            # Couldn't find desired document or field
            resp.media = {
                "status": "error",
                "message": "Something went wrong! Couldn't update"
            }
            return
        resp.media = {
            "status": "error",
            "message": "User credential is not valid!"
        }
