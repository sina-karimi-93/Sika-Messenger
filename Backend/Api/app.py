import falcon
import falcon.asgi
from .Resources.users import Users

app = falcon.App()


app.add_route("/users/login", Users(), suffix="login")
app.add_route("/users/signup", Users(), suffix="signup")
app.add_route("/users/edit", Users(), suffix="edit")
