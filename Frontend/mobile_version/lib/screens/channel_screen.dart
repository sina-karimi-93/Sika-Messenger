import 'dart:convert';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../../models/channel.dart';
import '../providers/channels_provider.dart';
import '../providers/user_provider.dart';

import '../widgets/channel_screen.dart/channel_message.dart';
import '../widgets/channel_screen.dart/channel_screen_footer.dart';

class ChannelScreen extends StatelessWidget {
  static const routeName = "channel-screen";

  ChannelScreen({Key? key}) : super(key: key);
  final ScrollController scrollController = ScrollController();

  void moveController(int messageCount) {
    scrollController.position.animateTo(
        scrollController.position.maxScrollExtent + messageCount * 4,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    // getting routes args
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String channelId = routeArgs["id"];

    // providers
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final channelsProvider =
        Provider.of<ChannelsProvider>(context, listen: false);
    final Channel channel = channelsProvider.getChannelById(channelId);

    final bool isOwner = channel.owner == user.serverId;

    final socketConnection = channelsProvider.connectToChannelSocket(
        channel.id, {"email": user.email, "password": user.password});

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              channelsProvider.closeChannelSocket();
              Navigator.of(context).pop();
            }),
        title: Text(channel.channelName),
        actions: [
          IconButton(
              onPressed: () => moveController(1),
              icon: const Icon(Icons.arrow_downward))
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.greenAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          channelsProvider.closeChannelSocket();
          return true;
        },
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: channelsProvider.channelSocket.stream,
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

                    var l = ListView.builder(
                      controller: scrollController,
                      itemCount: channel.messages.length,
                      itemBuilder: ((context, index) {
                        return ChannelMessage(
                            channel.messages[index].message,
                            isOwner,
                            channel.messages[index].createDate,
                            channel.messages[index].updateDate);
                      }),
                    );
                    moveController(channel.messages.length);
                    return l;
                  }
                  if (snapshot.connectionState == ConnectionState.done) {
                    channelsProvider.closeChannelSocket();
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: channel.messages.length,
                    itemBuilder: ((context, index) {
                      return ChannelMessage(
                          channel.messages[index].message,
                          isOwner,
                          channel.messages[index].createDate,
                          channel.messages[index].updateDate);
                    }),
                  );
                },
              ),
            ),
            if (isOwner)
              ChannelScreenFooter(
                socketConnection: socketConnection,
                handler: moveController,
                messageCount: channel.messages.length,
              ),
          ],
        ),
      ),
    );
  }
}
