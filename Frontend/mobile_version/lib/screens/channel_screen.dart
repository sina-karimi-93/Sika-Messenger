import 'package:flutter/material.dart';
import 'package:mobile_version/models/channel.dart';
import 'package:provider/provider.dart';

import '../providers/channels_provider.dart';
import '../providers/user_provider.dart';
import '../tools/connection_tools.dart';

import '../widgets/channel_screen.dart/channel_message.dart';

class ChannelScreen extends StatelessWidget {
  static const routeName = "channel-screen";

  const ChannelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String channelId = routeArgs["id"];
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final Channel channel =
        Provider.of<ChannelsProvider>(context, listen: false)
            .getChannelById(channelId);

    return Scaffold(
      appBar: AppBar(
        title: Text(channel.channelName),
      ),
      // body: Column(children: [
      //   Expanded(
      //     child: ListView.builder(
      //       itemCount: channel.messages.length,
      //       itemBuilder: ((context, index) {
      //         final message = channel.messages[index].message;
      //         final createDate = channel.messages[index].createDate;
      //         final updateDate = channel.messages[index].updateDate;
      //         return ChannelMessage(message, createDate, updateDate);
      //       }),
      //     ),
      //   ),
      // ]
      //     ),
      body: StreamBuilder(
        stream: connectToWebSocket("/user/channels/${channel.id}",
            {"email": user.email, "password": user.password}),
        initialData: [
          1111,
        ],
        builder: (ctx, snapshot) {
          return ListView.builder(itemBuilder: ((context, index) {
            return ChannelMessage(snapshot.data.toString(), "10:22", "");
          }));
        },
      ),
    );
  }
}
