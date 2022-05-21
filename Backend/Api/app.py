import falcon
import falcon.asgi

from Api.Resources.chats import Chats
from Api.Resources.groups import Groups
from Api.Resources.users import Users

app = falcon.App()


app.add_route("/user/login", Users(), suffix="login")
app.add_route("/user/signup", Users(), suffix="signup")
app.add_route("/user/edit", Users(), suffix="edit")
app.add_route("/user/delete", Users())


app.add_route("/user/chats", Chats())
app.add_route("/user/chats/{chat_id}", Chats(), suffix='new_message')
app.add_route("/user/chats/{chat_id}/{message_id}",
              Chats(), suffix='update_message')

app.add_route("/user/groups", Groups())  # user groups
app.add_route("/user/groups/add-member", Groups(), suffix="add_member")
app.add_route("/user/groups/add-admin", Groups(), suffix="add_admin")
app.add_route("/user/groups/remove-admin", Groups(), suffix="remove_admin")
