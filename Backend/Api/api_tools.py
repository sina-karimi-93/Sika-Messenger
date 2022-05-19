import base64
from urllib import request


class ApiTools:

    """"""

    @staticmethod
    def extract_auth_data(auth_data: str) -> dict:
        """
        This method convert the base64 authorization data that
        came from a request to a reable python dictionary with
        two keys, namely username and password and return it.

        args:
            auth_data -> "Auth_Type ASCII str"

        return:
            dict
        """
        auth_type, auth_data = auth_data.split(' ')
        reshape = base64.b64decode(auth_data).decode("utf-8")
        user_credential = {
            "username": reshape.split(":")[0],
            "password": reshape.split(":")[1],
        }
        return user_credential
