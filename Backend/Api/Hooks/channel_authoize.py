
import falcon
from bson import ObjectId
from Database.db_handler import Database


HOST = 'localhost'
PORT = 27017
DB_NAME = 'sika-messenger'


class ChannelAuthorize:

    """
    This class is a hook object for api routes. In __call__ method
    it checks whether the desired user has authorization or not.
    For instance, is user owner or admin of a channel or not.

    if he/she is owner then the req.channel_auth becomes true, otherwise
    req.channel_auth is false(he/she is admins). And if he/she is not admin
    it will raise error to prevent running further codes.

    """

    async def __call__(self, req, res, resource, params) -> None:

        collection_name = str(resource).lower()
        channel_id = params["channel_id"]
        try:
            with Database(HOST, PORT, DB_NAME, collection_name) as db:
                db: Database
                channel = db.get_record({"_id": ObjectId(channel_id)})

            user_id = req.user["_id"]
            req.channel = channel

            if user_id == channel["owner"]:
                req.is_channel_auth = True
                return

            elif user_id in channel["admins"]:
                req.is_channel_auth = True

            else:
                req.is_channel_auth = False

        except (KeyError, TypeError) as e:
            raise falcon.HTTPBadRequest(
                title="error",
                description="Invalid data."
            )
