
import falcon
import pymongo
from bson import ObjectId
from falcon.asgi import Request
from falcon.asgi import Response
from falcon.asgi import WebSocket
from Api.api_tools import ApiTools
from Database.db_handler import Database
from Api.Hooks.authorize import Authorize
from Api.Hooks.authenticate import Authenticate


HOST = 'localhost'
PORT = 27017
DB_NAME = 'sika-messenger'


class Channels:

    def __str__(self) -> str:
        return "Channels"

    @falcon.before(Authenticate())
    def on_get(self, req: Request, resp: Response) -> None:
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
            "description": "Groups are in descending order.",
            "groups": user_channels
        }

    @falcon.before(Authenticate())
    def on_post(self, req: Request, resp: Response) -> None:
        """
        This method creates new channel for the user.

        Request body:
            {
                "channel_name" : str,
                "owner" : {"$oid": "..."}
            }
        """

        body = ApiTools.prepare_body_data(req.stream.read())
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
    

    @falcon.before(Authenticate())
    @falcon.before(Authorize())
    def on_delete(self, req:Request, resp:Response)-> None:
        """
        This route removes a channel. After authentication
        and authorization (user have to be the owner of the channel),
        channel will be removed and the id of the channel will be 
        deleted from the users channels array.
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
                    query={"_id":channel["_id"]}
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


    @falcon.before(Authenticate())
    @falcon.before(Authorize())
    def on_patch_add_member(self, req:Request, resp:Response)-> None:
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
                updated_data={"$push":{"channels":channel["_id"]}}
            )

        resp.media = {
            "title": "ok",
            "description": "New member has been successfully added to the channel."
        }

    @falcon.before(Authenticate())
    @falcon.before(Authorize())
    def on_patch_add_admin(self, req: Request, resp: Response) -> None:
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

                # Remove member from group members
                db.update_record(
                    query={"_id": channel["_id"]},
                    updated_data={
                        "$pull": {"members": new_admin_id}}
                )
                # Add member to group admins
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

    @falcon.before(Authenticate())
    @falcon.before(Authorize())
    def on_patch_remove_admin(self, req: Request, resp: Response) -> None:
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

                # Add member to channel members
                db.update_record(
                    query={"_id": channel["_id"]},
                    updated_data={
                        "$push": {"members": admin_id}}
                )
                # Remove admin from channel admins
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