
from Api.api_tools import ApiTools
from Database.db_handler import Database

HOST = 'localhost'
PORT = 27017
DB_NAME = 'sika-messenger'


class CheckUserExists:
    """"""

    def __call__(self, req, resp, resource, params) -> None:
        """"""
        new_user = ApiTools.prepare_body_data(req)
        with Database(HOST, PORT, DB_NAME, "users") as db:
            db: Database

            user = db.get_record({"email": new_user["email"]})
        if user:
            req.is_user_exists = True
        else:
            req.is_user_exists = False
            req.user = new_user
