from bson import ObjectId
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

    @falcon.before(Authenticate())
    def on_post_new_message(self, req: falcon.Request, resp: falcon.Response, chat_id: str) -> None:
        """
        This method adds new message to ane existin chat.
        """
        if req.is_auth:
            message_data = ApiTools.prepare_body_data(req.stream.read())
            message_data['create_date'] = datetime.now()
            with Database(HOST, PORT, DB_NAME, 'chats') as db:
                db: Database

                match_count = db.update_record(
                    query={"_id": ObjectId(chat_id)},
                    updated_data={"$push": {"messages": message_data}}
                )
            print(match_count)
            if match_count:
                resp.media = {
                    "status": "ok",
                    "message": "Message successfully added"
                }
                return
            resp.media = {
                "status": "error",
                "message": "Something went wrong"
            }
            return
        resp.media = {
            "status": "error",
            "message": "User Credential is not valid"
        }

    # @falcon.before(Authenticate())
    # def on_patch_update_message(self, req: falcon.Request, resp: falcon.Response) -> None:
    #     """"""

    # @falcon.before(Authenticate())
    # def on_post_new_chat(self, req: falcon.Request, resp: falcon.Response) -> None:
    #     """"""
