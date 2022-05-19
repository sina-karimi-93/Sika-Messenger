import base64
import bcrypt
import json
from bson import json_util


class ApiTools:

    """"""

    @staticmethod
    def prepare_data_before_send(data: list or dict) -> dict:
        """
        This method prepare data for responding through http methods.
        Via json_utils tools it convert data to proper shape.
        """
        reshape_fields = json_util.dumps(data)
        serialized_data = json.loads(reshape_fields)
        return serialized_data

    @staticmethod
    def prepare_body_data(data) -> dict or list:
        """
        This function prepare and reshape the data which came from
        a post http method. First it read the data through request.stream.read(), 
        then decode it with utf-8. Finallyturn it to python dict with 
        json_utils.loads() and return it.
        """
        data = data.decode("utf-8")
        data = json_util.loads(data)
        return data

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
            "email": reshape.split(":")[0],
            "password": reshape.split(":")[1],
        }
        return user_credential

    @staticmethod
    def encode_password(password: str) -> str:
        """
        This function hash passwords and return them as string to 
        store them in database.
        """

        hashed_password = bcrypt.hashpw(password.encode(), bcrypt.gensalt())
        return hashed_password.decode()

    def check_password(password: str, encoded_password: str) -> bool:
        """
        This method check whether a password is match to existing or not.

        args:
            password -> input password from client
            encoded_password -> existing password in database
        """

        is_match = bcrypt.checkpw(password.encode(), encoded_password.encode())
        return is_match
