import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../screens/channel_screen.dart';

class ChannelItem extends StatelessWidget {
  const ChannelItem(
      {required this.id,
      required this.channelName,
      required this.lastMessage,
      required this.lastMessageTime,
      Key? key})
      : super(key: key);

  final String id;
  final String channelName;
  final String lastMessage;
  final String lastMessageTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(1),
          bottomLeft: Radius.circular(1),
          topLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
        boxShadow: [
          BoxShadow(
            spreadRadius: 1,
            blurRadius: 4,
            color: Colors.cyan,
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          Navigator.of(context)
              .pushNamed(ChannelScreen.routeName, arguments: {"id": id});
        },
        // User profile Picture
        leading: const CircleAvatar(
          backgroundColor: Colors.cyan,
          child: Icon(Icons.person, color: Colors.white, size: 30),
        ),
        // User full name
        title: Text(
          channelName,
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
    );
  }
}
