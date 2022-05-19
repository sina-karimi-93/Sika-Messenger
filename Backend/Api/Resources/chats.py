import falcon
from pprint import pprint
from datetime import datetime

import pymongo
from Api.api_tools import ApiTools
from Database.db_handler import Database
from Api.Hooks.authenticate import Authenticate
from Api.Hooks.check_user_exists import CheckUserExists

HOST = 'localhost'
PORT = 27017
DB_NAME = 'sika-messenger'


class Chats:

    @falcon.before(Authenticate())
    def on_get(self, req: falcon.Request, resp: falcon.Response) -> None:
        """
        This method gets all chats that user has. First it checks the user
        credential and if valid, it will gives the users chats.
        """

        if req.is_auth:
            user_chats_ids = req.user["chats"]

            with Database(HOST, PORT, DB_NAME, 'chats') as db:
                db: Database

                user_chats = tuple(db.get_record(
                    query={"_id": {"$in": user_chats_ids}},
                    find_one=False,
                ).sort('create_date', pymongo.DESCENDING))

            user_chats = ApiTools.prepare_data_before_send(user_chats)

            resp.media = {
                "status": "ok",
                "message": "Chats are in descending order.",
                "chats": user_chats
            }
            return

        resp.media = {
            "status": "error",
            "message": "User credential is not valid."
        }
