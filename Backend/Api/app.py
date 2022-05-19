import falcon
import falcon.asgi

from Api.Resources.chats import Chats
from Api.Resources.users import Users

app = falcon.App()


app.add_route("/user/login", Users(), suffix="login")
app.add_route("/user/signup", Users(), suffix="signup")
app.add_route("/user/edit", Users(), suffix="edit")
app.add_route("/user/delete", Users())


app.add_route("/user/chats", Chats())
