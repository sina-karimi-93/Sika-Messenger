from bson import ObjectId
import falcon
from pprint import pprint
from datetime import datetime

import pymongo
from Api.api_tools import ApiTools
from Database.db_handler import Database
from Api.Hooks.authenticate import Authenticate

HOST = 'localhost'
PORT = 27017
DB_NAME = 'sika-messenger'


class Chats:

    def __str__(self) -> str:
        return "Chats"

    @falcon.before(Authenticate())
    def on_get(self, req: falcon.Request, resp: falcon.Response) -> None:
        """
        This method gets all chats that user has. First it checks the user
        credential and if valid, it will gives the users chats.
        """

        user_chats_ids: list = req.user["chats"]

        with Database(HOST, PORT, DB_NAME, 'chats') as db:
            db: Database

            user_chats = tuple(db.get_record(
                query={"_id": {"$in": user_chats_ids}},
                find_one=False,
            ).sort('create_date', pymongo.DESCENDING))

        if len(user_chats) < 1:
            resp.media = {
                "title": "error",
                "description": "User has not any groups."
            }
            return

        user_chats = ApiTools.prepare_data_before_send(user_chats)

        resp.media = {
            "title": "ok",
            "description": "Chats are in descending order.",
            "chats": user_chats
        }

    @falcon.before(Authenticate())
    def on_post(self, req: falcon.Request, resp: falcon.Response) -> None:
        """
        This method creates new chat for the user. After user authentication,
        It creates new chat document.Then it will insert it to the database and
        receives the chat id(new document id). Finally, it add this chat id to
        users chats array(which contains users chats ids).
        """

        # preparing chat data for making new chat document in database
        chat_data = ApiTools.prepare_body_data(req.stream.read())
        new_chat_document = ApiTools.create_new_chat(chat_data)

        with Database(HOST, PORT, DB_NAME, 'chats') as db:
            db: Database
            # Insert new chat document to chat collection
            chat_id = db.insert_record(new_chat_document)
            # Insert created chat id to users chats array.
            matched_count = db.update_record(
                query={"_id": {
                    "$in": [
                        ObjectId(chat_data['owner']),
                        ObjectId(chat_data['receiver'])
                    ]}
                },
                updated_data={
                    "$push": {"chats": ObjectId(chat_id)}
                },
                update_one=False,
                collection_name='users'
            )
        if matched_count == 2:
            resp.media = {
                "title": "ok",
                "description": "New chat has been successfully created.",
                "chat_id": ApiTools.prepare_data_before_send(ObjectId(chat_id))
            }
            return
        resp.media = {
            "title": "error",
            "description": "Something went wrong!"
        }

    @falcon.before(Authenticate())
    def on_post_new_message(self, req: falcon.Request, resp: falcon.Response, chat_id: str) -> None:
        """
        This method adds new message to ane existin chat.
        First user credential will be checked and if authenticated
        the process begins. The chat id comes from url and the data come
        from body.
        """

        message_data = ApiTools.prepare_body_data(req.stream.read())
        message_data = {'_id': ObjectId(),
                        **message_data,
                        'create_date': datetime.now(),
                        }

        with Database(HOST, PORT, DB_NAME, 'chats') as db:
            db: Database

            match_count = db.update_record(
                query={"_id": ObjectId(chat_id)},
                updated_data={"$push": {"messages": message_data}}
            )
        if match_count:
            resp.media = {
                "title": "ok",
                "description": "Message successfully added"
            }
            return
        resp.media = {
            "title": "error",
            "description": "Something went wrong"
        }

    @falcon.before(Authenticate())
    def on_patch_update_message(self, req: falcon.Request, resp: falcon.Response,
                                chat_id: str, message_id: str) -> None:
        """
        This method updates an existing message in a chat.
        After checking user credential, the message will be updated.
        """

        message_data = ApiTools.prepare_body_data(req.stream.read())
        with Database(HOST, PORT, DB_NAME, 'chats') as db:
            db: Database
            match_count = db.update_record(
                query={
                    "_id": ObjectId(chat_id),
                    "messages._id": ObjectId(message_id)},
                updated_data={
                    "$set": {
                        "messages.$.message": message_data['message'],
                        "messages.$.update_date": datetime.now()
                    }
                }
            )

        if match_count:
            resp.media = {
                "status": "ok",
                "message": "Message successfully updated"
            }
            return
        resp.media = {
            "status": "error",
            "message": "Something went wrong, Couldn't update the message"
        }
