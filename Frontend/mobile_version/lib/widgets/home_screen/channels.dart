import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../providers/channels_provider.dart';
import './channel_item.dart';

class Channels extends StatelessWidget {
  const Channels({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final channelsProvider =
        Provider.of<ChannelsProvider>(context, listen: false);
    return FutureBuilder(
      future: channelsProvider.fetchAndSetChannels(
          userCredential: {"email": user.email, "password": "1111"}),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          return Expanded(
            child: ListView.builder(
              itemCount: channelsProvider.channels.length,
              itemBuilder: ((context, index) {
                print(channelsProvider.channels);
                return ChannelItem(
                  id: channelsProvider.channels[index].id,
                  channelName: channelsProvider.channels[index].channelName,
                  lastMessage:
                      channelsProvider.channels[index].messages.last.message,
                  lastMessageTime:
                      channelsProvider.channels[index].messages.last.createDate,
                );
              }),
            ),
          );
        }

        return const Center(
          child: Text("Something went wrong!"),
        );
      },
    );
  }
}
