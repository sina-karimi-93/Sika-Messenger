import falcon
from Api.api_tools import ApiTools
from Database.db_handler import Database

HOST = 'localhost'
PORT = 27017
DB_NAME = 'sika-messenger'


class SignupCheckUserExists:
    """"""

    def __call__(self, req, resp, resource, params) -> None:
        """
        This magic method checks whether a user with this desired
        email is exists or not.
        """
        new_user = ApiTools.prepare_body_data(req.stream.read())
        try:
            user_email = new_user['email']
        except KeyError as e:
            raise falcon.HTTPBadRequest(
                title="error",
                description="There is no email in the sent data.")

        with Database(HOST, PORT, DB_NAME, "users") as db:
            db: Database

            user = db.get_record(
                {"email": user_email}, collection_name='users')
        if user:
            raise falcon.HTTPNotAcceptable(
                title="error",
                description="A user with this email is currently exists")
        req.user = new_user
