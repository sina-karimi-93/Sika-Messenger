
import falcon
from Api.api_tools import ApiTools
from Database.db_handler import Database


HOST = 'localhost'
PORT = 27017
DB_NAME = 'sika-messenger'


class Authorize:

    """
    This class is a hook object for api routes. In __call__ method
    it checks whether the desired user has authorization or not.
    For instance, is user owner or admin of a group or channel
    or not.
    """

    def __call__(self, req, res, resource, params) -> None:
        print("Authorize")
        req.body_data = ApiTools.prepare_body_data(req.stream.read())

        collection_name = str(resource).lower()

        with Database(HOST, PORT, DB_NAME, collection_name) as db:
            db: Database
            room = db.get_record({"_id": req.body_data["room_id"]})

        user_id = req.user["_id"]

        if user_id == room["owner"]:
            req.is_owner = True
            req.room = room
            return

        elif user_id in room["admins"]:
            req.is_owner = False
            req.room = room

        else:
            raise falcon.HTTPNotFound(
                title="error",
                description="User have no authorization for this action.")
