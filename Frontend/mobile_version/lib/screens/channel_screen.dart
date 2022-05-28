import 'package:flutter/material.dart';
import 'package:mobile_version/models/channel.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../providers/channels_provider.dart';
import '../providers/user_provider.dart';
import '../tools/connection_tools.dart';

import '../widgets/channel_screen.dart/channel_message.dart';

class ChannelScreen extends StatelessWidget {
  static const routeName = "channel-screen";

  ChannelScreen({Key? key}) : super(key: key);
  final _messageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String channelId = routeArgs["id"];
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final channelsProvider =
        Provider.of<ChannelsProvider>(context, listen: false);
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final Channel channel = channelsProvider.getChannelById(channelId);
    final bool isOwner = channel.owner == user.serverId;
    final socketConnection = connectToWebSocket("/user/channels/${channel.id}",
        {"email": user.email, "password": user.password});

    return Scaffold(
      appBar: AppBar(
        title: Text(channel.channelName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: socketConnection.stream,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  final String newMessage = snapshot.data as String;
                  final Map<String, dynamic> decodedMessage =
                      json.decode(newMessage);
                  channelsProvider.addMessage(
                      channelId,
                      decodedMessage["message"],
                      decodedMessage["owner"]["\$oid"],
                      decodedMessage["create_date"]["\$date"]);
                  return SingleChildScrollView(
                    reverse: true,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: channel.messages.length,
                        itemBuilder: ((context, index) {
                          return ChannelMessage(
                              channel.messages[index].message,
                              channel.messages[index].createDate,
                              channel.messages[index].updateDate);
                        })),
                  );
                }
                if (snapshot.connectionState == ConnectionState.none) {
                  print("Done");
                  socketConnection.sink.close();
                }
                return ListView.builder(
                    itemCount: channel.messages.length,
                    itemBuilder: ((context, index) {
                      return ChannelMessage(
                          channel.messages[index].message,
                          channel.messages[index].createDate,
                          channel.messages[index].updateDate);
                    }));
              },
            ),
          ),
          if (isOwner)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isPortrait ? 20 : 50,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          label: const Text(
                            "Message",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      socketConnection.sink.add(_messageController.value.text);
                      _messageController.clear();
                    },
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
