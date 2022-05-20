import falcon
import pymongo
from datetime import datetime
from bson.objectid import ObjectId
from Api.api_tools import ApiTools
from Api.Hooks.authenticate import Authenticate
from Database.db_handler import Database

HOST = 'localhost'
PORT = 27017
DB_NAME = 'sika-messenger'


class Groups:

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
        """

        # preparing group data for making new group document in database
        new_group_data = ApiTools.prepare_body_data(req.stream.read())
        new_group_data = ApiTools.create_new_group(new_group_data)

        with Database(HOST, PORT, DB_NAME, 'groups') as db:
            db: Database
            # Insert new group document to chat collection
            group_id = db.insert_record(new_group_data)
            # Insert created group id to user groups array.
            matched_count = db.update_record(
                query={"_id": ObjectId(req.user['_id'])},
                updated_data={
                    "$push": {"groups": ObjectId(group_id)}
                },
                collection_name='users'
            )
        if matched_count == 1:
            resp.media = {
                "title": "ok",
                "description": "New group has been successfully created.",
                "group_id": ApiTools.prepare_data_before_send(ObjectId(group_id))
            }
            return
        resp.media = {
            "title": "error",
            "description": "Something went wrong!"
        }

    @falcon.before(Authenticate())
    def on_patch_add_member(self, req: falcon.Request, resp: falcon.Response) -> None:
        """
        This method adds new member to the group.
        After authentication if user is owner or one of admins, he/she can
        add new member to the group.
        """

        new_member_data = ApiTools.prepare_body_data(req.stream.read())
        # Check whether the applicant is owner or admin of the group or not
        with Database(HOST, PORT, DB_NAME, 'groups') as db:
            db: Database

            group = db.get_record({"_id": new_member_data['group_id']})

            is_authorize = ApiTools.check_user_authorization(
                req.user["_id"], group)

            if is_authorize:

                db.update_record(
                    query={"_id": group["_id"]},
                    updated_data={
                        "$push": {"members": new_member_data["new_member_id"]}}
                )
                db.update_record(
                    query={"_id": new_member_data['new_member_id']},
                    updated_data={
                        "$push": {"groups": group["_id"]}},
                    collection_name='users'
                )
                resp.media = {
                    "title": "ok",
                    "description": "New member has been successfully added to the group."
                }
                return

            resp.media = {
                "title": "error",
                "description": "User has not authorization to add new member."
            }

    @falcon.before(Authenticate())
    def on_patch_add_admin(self, req: falcon.Request, resp: falcon.Response) -> None:
        """
        This method change the authorization of a member to admin in a group.
        """
        new_admin_data = ApiTools.prepare_body_data(req.stream.read())
        # Check whether the applicant is owner of the group or not
        with Database(HOST, PORT, DB_NAME, 'groups') as db:
            db: Database

            group = db.get_record({"_id": new_admin_data['group_id']})

            is_authorize = ApiTools.check_user_authorization(
                req.user["_id"], group, just_owner=True)

            if is_authorize:
                # Remove member from group members
                db.update_record(
                    query={"_id": group["_id"]},
                    updated_data={
                        "$pull": {"members": new_admin_data["new_admin_id"]}}
                )
                # Add member to group admins
                db.update_record(
                    query={"_id": group["_id"]},
                    updated_data={
                        "$push": {"admins": new_admin_data["new_admin_id"]}}
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
    def on_patch_remove_admin(self, req: falcon.Request, resp: falcon.Response) -> None:
        """
        This method change the authorization of a member to admin in a group.
        """
        new_admin_data = ApiTools.prepare_body_data(req.stream.read())
        # Check whether the applicant is owner of the group or not
        with Database(HOST, PORT, DB_NAME, 'groups') as db:
            db: Database

            group = db.get_record({"_id": new_admin_data['group_id']})

            is_authorize = ApiTools.check_user_authorization(
                req.user["_id"], group, just_owner=True)

            if is_authorize:
                # Add member to group members
                db.update_record(
                    query={"_id": group["_id"]},
                    updated_data={
                        "$push": {"members": new_admin_data["new_admin_id"]}}
                )
                # Remove admin from group admins
                db.update_record(
                    query={"_id": group["_id"]},
                    updated_data={
                        "$pull": {"admins": new_admin_data["new_admin_id"]}}
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
    def on_delete(self, req: falcon.Request, resp: falcon.Response, group_id: str) -> None:
        """
        This method removes a group.
        """
        with Database(HOST, PORT, DB_NAME, 'groups') as db:
            db: Database

            group = db.get_record({"_id": ObjectId(group_id)})

            is_authorize = ApiTools.check_user_authorization(
                req.user["_id"], group, just_owner=True)

            if is_authorize:
                db.delete_record({"_id": ObjectId(group_id)})

                resp.media = {
                    "title": "ok",
                    "description": "Group has been successfully deleted."
                }
                return
        resp.media = {
            "title": "ok",
            "description": "You are not the owner of the group."
        }
