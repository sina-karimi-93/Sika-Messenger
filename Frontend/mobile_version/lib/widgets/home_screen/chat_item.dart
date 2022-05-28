import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_version/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../../tools/connection_tools.dart';

class ChatItem extends StatelessWidget {
  const ChatItem(
      {required this.owner,
      required this.profilePicture,
      required this.lastMessage,
      required this.lastMessageTime,
      Key? key})
      : super(key: key);

  final String owner;
  final String profilePicture;
  final String lastMessage;
  final String lastMessageTime;

  Future<String> getOwnerName(String owner, String userEmail) async {
    final user = await apiInteraction(
        "/user/get-user", {"email": userEmail, "password": "1111"}, "post",
        body: {
          "user_id": {"\$oid": owner}
        });
    return user["user"]["name"];
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).user;

    return FutureBuilder<String>(
      future: getOwnerName(owner, user.email),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: [
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(1),
                    bottomLeft: Radius.circular(1),
                    topLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 1,
                      blurRadius: 4,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                child: ListTile(
                  onTap: () {},
                  // User profile Picture
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child:
                        const Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  // User full name
                  title: Text(
                    snapshot.data.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  // User last message
                  subtitle: Text(
                    lastMessage,
                    softWrap: true,
                    maxLines: 1,
                  ),
                  // User last message time
                  trailing: Text(
                      "${DateFormat.E().format(DateTime.parse(lastMessageTime))} ${DateFormat.Hm().format(DateTime.parse(lastMessageTime))}"),
                ),
              ),
              // const Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 20),
              //   child: Divider(),
              // )
            ],
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Center(
            child: LinearProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
              minHeight: 8,
            ),
          ),
        );
      },
    );
  }
}
