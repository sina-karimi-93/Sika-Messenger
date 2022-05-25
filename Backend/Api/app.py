import falcon.asgi 

from Api.Resources.channels import Channels

app = falcon.asgi.App()


# app.add_route("/user/login", Users(), suffix="login")
# app.add_route("/user/signup", Users(), suffix="signup")
# app.add_route("/user/edit", Users(), suffix="edit")
# app.add_route("/user/delete", Users())


# app.add_route("/user/chats", Chats())
# app.add_route("/user/chats", Chats(), suffix='new_message')
# app.add_route("/user/chats", Chats(), suffix='update_message')

# app.add_route("/user/groups", Groups())  # user groups
# app.add_route("/user/groups/add-member", Groups(), suffix="add_member")
# app.add_route("/user/groups/add-admin", Groups(), suffix="add_admin")
# app.add_route("/user/groups/remove-admin", Groups(), suffix="remove_admin")
# app.add_route("/user/groups/new-message", Groups(), suffix="new_message")

app.add_route("/user/channels", Channels())  # user channels
# app.add_route("/user/channels/{channel_id}", Channels())  # channel websocket
app.add_route("/user/channel/add-member", Channels(), suffix="add_member")
# app.add_route("/user/channel/add-memeber", Channels(), suffix="remove_member")
# app.add_route("/user/channel/add-admin", Channels(), suffix="add_admin")
# app.add_route("/user/channel/add-admin", Channels(), suffix="remove_admin")
