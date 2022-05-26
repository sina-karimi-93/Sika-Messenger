import 'package:flutter/material.dart';

class ChatItem extends StatelessWidget {
  const ChatItem(
      {required this.name,
      required this.profilePicture,
      required this.lastMessage,
      required this.lastMessageTime,
      Key? key})
      : super(key: key);

  final String name;
  final String profilePicture;
  final String lastMessage;
  final String lastMessageTime;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      // User profile Picture
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.person, color: Colors.white, size: 30),
      ),
      // User full name
      title: Text(
        name,
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
      trailing: Text(lastMessageTime),
    );
  }
}
