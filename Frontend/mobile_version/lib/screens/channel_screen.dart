import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../tools/connection_tools.dart' as api;
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
    final size = MediaQuery.of(context).size;
    // getting routes args
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String channelId = routeArgs["id"];

    // providers
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final channelsProvider =
        Provider.of<ChannelsProvider>(context, listen: false);
    final Channel channel = channelsProvider.getChannelById(channelId);

    final bool isOwner = channel.owner["_id"]["\$oid"] == user.serverId;

    final socketConnection = channelsProvider.connectToChannelSocket(
        channel.id, {"email": user.email, "password": user.password});

    void showChannelInfo() {
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              content: Container(
                width: size.width * 0.8,
                height: size.height * 0.7,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      channel.channelName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      channel.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    // Owner
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Owner",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          ],
                        ),
                        Text(
                          channel.owner["name"],
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Create Date",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              Icons.calendar_month_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                        Text(
                          DateFormat.yMMMd()
                              .format(DateTime.parse(channel.createDate)),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    // Members
                    Text(
                      "Members",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                          itemCount: channel.members.length,
                          itemBuilder: (ctx, index) {
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (isOwner)
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    if (channel.members[index]["is_admin"] ==
                                        true)
                                      Text(
                                        "@",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                    GestureDetector(
                                      onLongPress: isOwner
                                          ? () {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30)),
                                                  content: channel
                                                              .members[index]
                                                          ["is_admin"]
                                                      ? Text(
                                                          "Do you want to remove ${channel.members[index]["name"]} from admin?")
                                                      : Text(
                                                          "Do you want to make ${channel.members[index]["name"]} admin?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                      child: const Text("No"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                      child: const Text("Yes"),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          : null,
                                      child: Text(
                                        channel.members[index]["name"],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                              ],
                            );
                          }),
                    ),
                  ],
                ),
              ),
            );
          });
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              channelsProvider.closeChannelSocket();
              Navigator.of(context).pop();
            }),
        title: GestureDetector(
          onTap: () => showChannelInfo(),
          child: Text(channel.channelName),
        ),
        actions: [
          IconButton(
            onPressed: () => moveController(1),
            icon: const Icon(Icons.arrow_downward),
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
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
