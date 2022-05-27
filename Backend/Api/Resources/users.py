import falcon
from datetime import datetime
from Api.api_tools import ApiTools
from Database.db_handler import Database
from Api.Hooks.authenticate import Authenticate
from falcon.asgi import Request,Response,WebSocket
from Api.Hooks.signup_check_user_exists import SignupCheckUserExists

HOST = 'localhost'
PORT = 27017
DB_NAME = 'sika-messenger'


class Users:

    def __str__(self) -> str:
        return "Users"

    @falcon.before(Authenticate())
    async def on_post_login(self, req: Request, resp: Response):
        """
        This method checks the user credential and if valid
        return a valid response for authentication and the user data.
        """
        user = ApiTools.prepare_data_before_send(req.user)
        resp.media = {
            "title": "ok",
            "description": "User is authenticated and can login.",
            "user": user
        }

    @falcon.before(SignupCheckUserExists())
    async def on_post_signup(self, req: falcon.Request, resp: falcon.Response):
        """
        This method is stands for creating new user. With a hook first 
        it checks whether the user exists or not. If does not exists then
        create new user with dedicated data.
        """

        req.user['create_date'] = datetime.now()
        req.user['password'] = ApiTools.encode_password(req.user['password'])
        with Database(HOST, PORT, DB_NAME, 'users') as db:
            db: Database

            user_id = db.insert_record(req.user)
        if user_id:
            resp.media = {
                "title": "ok",
                "description": "User successfully registered",
                "user_id": ApiTools.prepare_data_before_send(user_id)
            }
            return
        resp.media = {
            "title": "error",
            "description": "Something went wrong! Couldn't create new user!",
        }

    @falcon.before(Authenticate())
    def on_patch_edit(self, req: falcon.Request, resp: falcon.Response) -> None:
        """
        This method updates users information like, name, phone_number.
        First via hooks, it checks whether the user credential is match or not. If
        matched it will update the user.
        """

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

    @falcon.before(Authenticate())
    def on_delete(self, req: falcon.Request, resp: falcon.Response) -> None:
        """
        This method removes a user from database. First via hooks it checks
        user credential and if valid it will remove the user from database.
        """
        with Database(HOST, PORT, DB_NAME, 'users') as db:

            db: Database

            deleted_count = db.delete_record({"email": req.user['email']})

        if deleted_count == 1:
            resp.media = {
                "title": "ok",
                "description": "The user has been successfully deleted."
            }
            return
        resp.media = {
            "title": "error",
            "description": "Something went wrong. Couldn't remove the user."
        }
