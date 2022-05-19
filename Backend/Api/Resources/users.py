import falcon
from ..api_tools import ApiTools


class Users:

    def on_get_login(self, req: falcon.Request, resp: falcon.Response):
        """
        This method checks the user credential and if valid
        return a valid response for authentication
        """

        user_credential = ApiTools.extract_auth_data(req.auth)
