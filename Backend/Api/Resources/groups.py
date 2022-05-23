import falcon
import pymongo
from datetime import datetime
from pprint import pprint
from bson.objectid import ObjectId
from Api.api_tools import ApiTools
from Api.Hooks.authenticate import Authenticate
from Api.Hooks.authorize import Authorize
from Database.db_handler import Database

HOST = 'localhost'
PORT = 27017
DB_NAME = 'sika-messenger'


class Groups:

    def __str__(self) -> str:
        return "Groups"

    @falcon.before(Authenticate())
    def on_get(self, req: falcon.Request, resp: falcon.Response) -> None:
        """
        This method gets all user groups chats.
        """

        user_groups_ids: list = req.user['groups']

        with Database(HOST, PORT, DB_NAME, 'groups') as db:
            db: Database
            user_groups = tuple(db.get_record(
                {"_id": {"$in": user_groups_ids}}, find_one=False).sort(
                'create_date', pymongo.DESCENDING))

        if len(user_groups) < 1:
            resp.media = {
                "title": "error",
                "description": "User has not any groups."
            }
            return

        user_groups = ApiTools.prepare_data_before_send(user_groups)

        resp.media = {
            "title": "ok",
            "description": "Groups are in descending order.",
            "groups": user_groups
        }

    @falcon.before(Authenticate())
    def on_post(self, req: falcon.Request, resp: falcon.Response) -> None:
        """
        This method creates new group for the user. After user authentication,
        It creates new group document.Then it will insert it to the database and
        receives the group id(new document id). Finally, it add this group id to
        user group array(which contains user groups ids).

        Request body:
            {
                "group_name" : "...",
                "owner" : {"$oid":"..."},
            }

        """

        # preparing group data for making new group document in database
        body = ApiTools.prepare_body_data(req.stream.read())
        new_group_document = ApiTools.create_new_group(
            name=body["group_name"], owner=req.user["_id"])

        with Database(HOST, PORT, DB_NAME, 'groups') as db:
            db: Database

            # Insert new group document to groups collection
            new_group_id = db.insert_record(new_group_document)

            # Insert created group id to user groups array.
            db.update_record(
                query={"_id": ObjectId(req.user['_id'])},
                updated_data={
                    "$push": {"groups": ObjectId(new_group_id)}
                },
                collection_name='users'
            )

        resp.media = {
            "title": "ok",
            "description": "New group has been successfully created.",
            "group_id": ApiTools.prepare_data_before_send(ObjectId(new_group_id))
        }

    @falcon.before(Authenticate())
    @falcon.before(Authorize())
    def on_delete(self, req: falcon.Request, resp: falcon.Response) -> None:
        """
        This route removes a group. After authentication
        and authorization (user have to be the owner of the group),
        group will be removed and the id of the group will be 
        deleted from the users groups array.
        """
        group = req.room
        all_members = [req.user["_id"], *group["admins"], *group["members"]]
        if req.is_owner:
            with Database(HOST, PORT, DB_NAME, 'users') as db:
                db: Database
                # Remove group id from all users who has this group id in their groups array
                db.update_record(
                    query={"_id": {"$in": all_members}},
                    updated_data={"$pull": {"groups": group["_id"]}},
                    update_one=False,
                )
                # remove group from groups collection
                db.delete_record(
                    query={"_id": group["_id"]},
                    collection_name='groups')
                resp.media = {
                    "title": "ok",
                    "description": "Group has been successfully deleted."
                }
                return
        resp.media = {
            "title": "ok",
            "description": "You are not the owner of the group."
        }

    @falcon.before(Authenticate())
    @falcon.before(Authorize())
    def on_patch_add_member(self, req: falcon.Request, resp: falcon.Response) -> None:
        """
        This method adds new member to the group.
        After authentication if user is owner or one of admins, he/she can
        add new member to the group.

        Request body:
            {
                "room_id" : {"$oid": "..."},
                "new_member_id : {"$oid": "..."}
            }
        """
        body = req.body_data
        group = req.room
        with Database(HOST, PORT, DB_NAME, 'groups') as db:
            db: Database

            # Insert new member to group members
            db.update_record(
                query={"_id": group["_id"]},
                updated_data={
                    "$push": {"members": body["new_member_id"]}}
            )

            # Insert group id to user groups
            db.update_record(
                query={"_id": body['new_member_id']},
                updated_data={
                    "$push": {"groups": group["_id"]}},
                collection_name='users'
            )
        resp.media = {
            "title": "ok",
            "description": "New member has been successfully added to the group."
        }

    @falcon.before(Authenticate())
    @falcon.before(Authorize())
    def on_patch_add_admin(self, req: falcon.Request, resp: falcon.Response) -> None:
        """
        This method change the authorization of a member to admin in a group.

        Request body:
            {
                "room_id" : {"$oid": "..."},
                "new_admin_id : {"$oid": "..."}
            }
        """
        # Check whether the applicant is owner of the group or not
        if req.is_owner:
            
            body = req.body_data
            group = req.room

            with Database(HOST, PORT, DB_NAME, 'groups') as db:
                db: Database

                # Remove member from group members
                db.update_record(
                    query={"_id": group["_id"]},
                    updated_data={
                        "$pull": {"members": body["new_admin_id"]}}
                )
                # Add member to group admins
                db.update_record(
                    query={"_id": group["_id"]},
                    updated_data={
                        "$push": {"admins": body["new_admin_id"]}}
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
    def on_patch_remove_admin(self, req: falcon.Request, resp: falcon.Response) -> None:
        """
        This method change the authorization of a member to admin in a group.
        Request body:
            {
                "room_id" : {"$oid": "..."},
                "admin_id : {"$oid": "..."}
            }
        """
        body = req.body_data
        group = req.room

        if req.is_owner:
            # Check whether the applicant is owner of the group or not
            with Database(HOST, PORT, DB_NAME, 'groups') as db:
                db: Database

                # Add member to group members
                db.update_record(
                    query={"_id": group["_id"]},
                    updated_data={
                        "$push": {"members": body["admin_id"]}}
                )
                # Remove admin from group admins
                db.update_record(
                    query={"_id": group["_id"]},
                    updated_data={
                        "$pull": {"admins": body["admin_id"]}}
                )
                resp.media = {
                    "title": "ok",
                    "description": "Admin successfully became member."
                }
                return
        resp.media = {
            "title": "ok",
            "description": "You are not the owner of the group"
        }

    @falcon.before(Authenticate())
    def on_post_new_message(self, req: falcon.Request, resp: falcon.Response) -> None:
        """
        This route adds new message to the group.

        Request body {
            room_id : {"$oid" : "..."},
            message : "...",
        }
        """

        body = ApiTools.prepare_body_data(req.stream.read())
        new_message_data = {
            "_id": ObjectId(),
            "message": body["message"],
            "owner": req.user["_id"],
            "create_date": datetime.now(),
        }

        with Database(HOST, PORT, DB_NAME, 'groups') as db:
            db: Database

            db.update_record(
                query={"_id": body["room_id"]},
                updated_data={"$push": {"messages": new_message_data}}
            )

        resp.media = {
            "title": "ok",
            "description": "New message has been successfully added"
        }
