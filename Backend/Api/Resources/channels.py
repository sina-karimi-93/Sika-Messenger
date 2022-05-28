
import falcon
import asyncio
import pymongo
from time import sleep
from bson import ObjectId
from threading import Thread
from datetime import datetime
from falcon.asgi import Request
from falcon.asgi import Response
from falcon.asgi import WebSocket
from Api.api_tools import ApiTools
from Database.db_handler import Database
from Api.Hooks.authorize import Authorize
from Api.Hooks.authenticate import Authenticate
from Api.Hooks.channel_authoize import ChannelAuthorize

HOST = 'localhost'
PORT = 27017
DB_NAME = 'sika-messenger'


@falcon.before(Authenticate())
class Channels:
    __slots__ = ("message", "new_message_date", "online_users")

    def __init__(self) -> None:

        self.message = ''
        self.new_message_date = datetime.now()
        self.online_users = {}

    def __str__(self) -> str:
        return "Channels"

    async def on_get(self, req: Request, resp: Response) -> None:
        """
        This method gets all user groups chats.
        """
        user_channels_ids: list = req.user['channels']
        with Database(HOST, PORT, DB_NAME, 'channels') as db:
            db: Database
            user_channels = tuple(db.get_record(
                {"_id": {"$in": user_channels_ids}}, find_one=False).sort(
                'create_date', pymongo.DESCENDING))

        if len(user_channels) < 1:
            resp.media = {
                "title": "error",
                "description": "User has not any channels."
            }
            return

        user_channels = ApiTools.prepare_data_before_send(user_channels)

        resp.media = {
            "title": "ok",
            "description": "Channels are in descending order.",
            "channels": user_channels
        }

    async def on_post(self, req: Request, resp: Response) -> None:
        """
        This method creates new channel for the user.

        Request body:
            {
                "channel_name" : str,
            }
        """

        body = ApiTools.prepare_body_data(await req.stream.read())

        new_channel_document = ApiTools.create_new_channel(
            name=body['channel_name'],
            owner=req.user["_id"])

        with Database(HOST, PORT, DB_NAME, 'channels') as db:
            db:Database

            new_channel_id = db.insert_record(data=new_channel_document)

            db.update_record(
                query={"_id":req.user["_id"]},
                updated_data={"$push":{"channels":ObjectId(new_channel_id)}},
                collection_name='users')
            
        resp.media = {
            "title": "ok",
            "description": "New channel has been successfully created.",
            "channel_id": ApiTools.prepare_data_before_send(ObjectId(new_channel_id))
        }
    

    @falcon.before(Authorize())
    async def on_delete(self, req:Request, resp:Response)-> None:
        """
        This route removes a channel. After authentication
        and authorization (user have to be the owner of the channel),
        channel will be removed and the id of the channel will be 
        deleted from the users channels array.

        Request body {
            "room_id": {"$oid": "..."}
        }
        """

        if req.is_owner:
            user = req.user
            channel = req.room

            all_channel_members = [
                user["_id"], 
                *channel["admins"],
                *channel["members"]
                ]

            with Database(HOST, PORT,DB_NAME,'users') as db:
                db:Database

                # remove channel id from members channels array
                db.update_record(
                    query={"_id":{"$in":all_channel_members}},
                    updated_data = {"$pull":{"channels":channel["_id"]}}
                ) 

                # remove the channel from channels collection   
                db.delete_record(
                    query={"_id":channel["_id"]},
                    collection_name='channels'
                )
                resp.media = {
                    "title": "ok",
                    "description": "Channel has been successfully deleted."
                }
                return
        resp.media = {
            "title": "ok",
            "description": "You are not the owner of the chennel."
        }


    @falcon.before(Authorize())
    async def on_patch_add_member(self, req:Request, resp:Response)-> None:
        """
        This route adds a new member to the channel. After authentication 
        and authorization(user have to be the owner or admin of the channel)
        new member will be added to the members array of the channel data
        and also the channel id will be added to the member channels array.

        Request body:
            {
                "room_id" : ObjectId,
                "new_member_id : ObjectId
            }
        """

        new_member_id = req.body_data["new_member_id"]
        channel = req.room


        with Database(HOST,PORT,DB_NAME,'channels') as db:
            db:Database

            # Add member to members array of the channel
            db.update_record(
                query={"_id":channel["_id"]},
                updated_data={"$push":{"members":new_member_id}}
            )

            # Add channel id to the member channels array
            db.update_record(
                query={"_id":new_member_id},
                updated_data={"$push":{"channels":channel["_id"]}},
                collection_name='users',
            )

        resp.media = {
            "title": "ok",
            "description": "New member has been successfully added to the channel."
        }

    @falcon.before(Authorize())
    async def on_patch_remove_member(self, req:Request, resp:Response)-> None:
        """
        This route adds a removes a member from the channel. After authentication 
        and authorization(user have to be the owner or admin of the channel)
        member will be remove from the members array of the channel data
        and also the channel id will be removed from the member channels array.

        Request body:
            {
                "room_id" : ObjectId,
                "member_id : ObjectId
            }
        """

        member_id = req.body_data["member_id"]
        channel = req.room

        with Database(HOST,PORT,DB_NAME,'channels') as db:
            db:Database

            # Remove member from members array of the channel
            db.update_record(
                query={"_id":channel["_id"]},
                updated_data={"$pull":{"members":member_id}}
            )

            # Remove channel id from the member channels array
            db.update_record(
                query={"_id":member_id},
                updated_data={"$pull":{"channels":channel["_id"]}},
                collection_name='users'
            )

        resp.media = {
            "title": "ok",
            "description": "Member has been successfully removed from the channel."
        }


    @falcon.before(Authorize())
    async def on_patch_add_admin(self, req: Request, resp: Response) -> None:
        """
        This route change the authorization of a member to a admin in a channel.
        Only owner of the channel has the authorization to do this.
        Request body:
            {
                "room_id" : ObjectId,
                "new_admin_id : ObjectId
            }
        """
        # Check whether the applicant is owner of the channel or not
        if req.is_owner:
            
            new_admin_id = req.body_data["new_admin_id"]
            channel = req.room

            with Database(HOST, PORT, DB_NAME, 'channels') as db:
                db: Database

                # Remove member from channel members
                db.update_record(
                    query={"_id": channel["_id"]},
                    updated_data={
                        "$pull": {"members": new_admin_id}}
                )
                # Add member to channel admins
                db.update_record(
                    query={"_id": channel["_id"]},
                    updated_data={
                        "$push": {"admins": new_admin_id}}
                )
                resp.media = {
                    "title": "ok",
                    "description": "Member successfully became admin."
                }
                return
                
        resp.media = {
            "title": "ok",
            "description": "You are not the owner of the group"
        }

    @falcon.before(Authorize())
    async def on_patch_remove_admin(self, req: Request, resp: Response) -> None:
        """
        This route changes the authorization of a admin to a member in a channel.
        Only owner of the channel has authorization to do this act.
        Request body:
            {
                "room_id" : ObjectId,
                "admin_id : ObjectId
            }
        """
        admin_id = req.body_data["admin_id"]
        channel = req.room

        # Check whether the applicant is owner of the channel or not
        if req.is_owner:
            with Database(HOST, PORT, DB_NAME, 'channels') as db:
                db: Database

                # Add admin to channels members
                db.update_record(
                    query={"_id": channel["_id"]},
                    updated_data={
                        "$push": {"members": admin_id}}
                )
                # Remove admin from channels admins
                db.update_record(
                    query={"_id": channel["_id"]},
                    updated_data={
                        "$pull": {"admins": admin_id}}
                )
                resp.media = {
                    "title": "ok",
                    "description": "Admin successfully became member."
                }
                return
        resp.media = {
            "title": "ok",
            "description": "You are not the owner of the channel."
        }

    @falcon.before(ChannelAuthorize())
    async def on_websocket(self, req: Request, ws: WebSocket, channel_id: str)-> None:
        """
        This is a websocket route. Here owner or admins send messages and
        all users receives them.
        """

        try:
            await ws.accept()
            user = req.user
            self._add_new_thread(ws, user["_id"], channel_id)

            while True:
                new_message = await ws.receive_text()
                # cheks whether the user is owner or admin
                if req.is_channel_auth == True:
                    self.message = new_message
                    self._add_new_message(req.channel, new_message, user)
                    self.new_message_date = datetime.now()
                    sleep(0.1)


        except falcon.WebSocketDisconnected as e:
            print(e)
            self.online_users[user["_id"]] = False
            # This delay is necessary because it takes approximately 0.01 seconds
            # until a thread be killed by python. So after this delay we remove
            # the user status from online_users
            sleep(0.1)
            self.online_users.pop(user["_id"])

    def _add_new_message(self,channel:dict, message:str, owner:dict) -> None:
        """
        This method adds new message to the db channel messages array.
        Before a message come from the websocket route, it is authenticated
        and authorized.
        """
        message={
            "_id":ObjectId(),
            "message":message,
            "owner":owner["_id"],
            "created_date":datetime.now(),
        }
        with Database(HOST, PORT, DB_NAME, 'channels') as db:
            db:Database

            db.update_record(
                query={"_id": channel["_id"]},
                updated_data={"$push":{"messages":message}}
            )

    def _add_new_thread(self, ws: WebSocket, user_id: ObjectId)-> None:
        """
        This method creates new thread for each user. When a user becomes
        online and connects to the websocket in this resource, for receiving
        new message which adds by owner or admins, a thread will be made for
        processing this actions.

        args:
            ws: instance of websocket which belongs to a user.

            a key in online_users which defines a user is
                     connected or not.
        """
        # This boolean is for controlling the thread working in _send_message()
        self.online_users[user_id] = True
        sending_data_thread = Thread(target=self._async_bridge, args=(ws, user_id))
        sending_data_thread.start()

    def _async_bridge(self, ws:WebSocket , user_id:ObjectId, channel_id:str)-> None:
        """
        This method is a bridge between an async function (_send_message) and
        a thread (_add_new_thread) in websocket. As we can not define an async
        function in a thread, we have to make a bridge to establish
        this connection.

        args:
            ws: instance of websocket which belongs to a user.

            user_id: a key in online_users which defines a user is
                     connected or not.
        """

        loop = asyncio.new_event_loop()
        loop.run_until_complete(self._send_message(ws, user_id, channel_id))
        loop.close()

    def _get_last_message(self, channel_id:str)->dict:
        """
        This method returns the latest message in a channel.
        628e0bc8a92a88c0ded1a430
        """

        with Database(HOST,PORT,DB_NAME,'channels')as db:
            db:Database

            last_message = db.get_record(
                query={"_id":ObjectId(channel_id)},
                projection={
                    "_id":0,
                    "channel_name":0,
                    "owner":0,
                    "create_date":0,
                    "admins":0,
                    "members":0,
                    "messages":{"$slice":-1}
                })[0]
        return last_message


    async def _send_message(self, ws: WebSocket, user_id:ObjectId, channel_id:str)->None:
        """
        This method is responsible for sending new messages to
        the users. First it define current time. Then in a loop
        it checks a new message have came or not (everytime an admin
        or owner adds new message, it add the time of the receiving
        message in class in self.new_message_date). If if the time 
        of the new message is newer than the current time, it will
        send message to the user.

        args:
            ws: instance of websocket which belongs to a user
                and we send message to the user with this.

            user_id: this id is required to be aware of the user status
                     (connected or not). When user is going offline, his/her
                     status becomes False and the loop in this method will be
                     broken.
        """
        now_date = datetime.now()
        while self.online_users[user_id]:
            if now_date < self.new_message_date:
                last_message = self._get_last_message(channel_id)
                last_message = ApiTools.prepare_data_before_send(last_message)
                await ws.send_media(last_message)
                now_date = self.new_message_date
            sleep(0.1)



    

    

    

    

