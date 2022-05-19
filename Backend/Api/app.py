import falcon
import falcon.asgi
from .Resources.users import Users

app = falcon.App()


app.add_route("/users/login", Users(), suffix="login")
app.add_route("/users/signup", Users(), suffix="signup")
