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
      body: Column(
        children: [
          ChannelMessage(
            "The WebSocketChannel provides a Stream of messages from the server. The Stream class is a fundamental part of the dart:async package. It provides a way to listen to async events from a data source. Unlike Future, which returns a single async response, the Stream class can deliver many events over time. The StreamBuilder widget connects to a Stream and asks Flutter to rebuild every time it receives an event using the given builder() function.",
            "Sina Karimi",
            "19:55",
            "20:26",
          ),
        ],
      ),
      // body: StreamBuilder(
      //   stream: connectToWebSocket("/user/channels/${channel.id}",
      //       {"email": user.email, "password": user.password}),
      //   initialData: [
      //     1111,
      //   ],
      //   builder: (ctx, snapshot) {
      //     return Text(snapshot.data.toString());
      //   },
      // ),
    );
  }
}
