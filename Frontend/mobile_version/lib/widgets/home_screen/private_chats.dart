import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chats_provider.dart';
import '../../providers/user_provider.dart';
import './chat_item.dart';

class PrivateChats extends StatelessWidget {
  const PrivateChats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatsProvider = Provider.of<ChatsProvider>(context, listen: false);
    final user = Provider.of<UserProvider>(context, listen: false).user;

    return FutureBuilder(
      future: chatsProvider.fetchAndSetChats(userCredential: {
        "email": user.email,
        "password": user.password,
      }),
      builder: ((ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          return Expanded(
            child: ListView.builder(
                itemCount: chatsProvider.chats.length,
                itemBuilder: ((context, index) {
                  // =========================== Shaping Data ===============================
                  String owner = "";
                  if (chatsProvider.chats[index].owners[0] == user.serverId) {
                    owner = chatsProvider.chats[index].owners[1];
                  } else {
                    owner = chatsProvider.chats[index].owners[0];
                  }
                  var lastMessage =
                      chatsProvider.chats[index].messages.last.message;
                  var lastMessageDate =
                      chatsProvider.chats[index].messages.last.createDate;
                  return ChatItem(
                    owner: owner,
                    lastMessage: lastMessage,
                    lastMessageTime: lastMessageDate,
                    profilePicture: "",
                  );
                })),
          );
        } else {
          return const Center(child: Text("Something went wrong!"));
        }
      }),
    );
  }
}
