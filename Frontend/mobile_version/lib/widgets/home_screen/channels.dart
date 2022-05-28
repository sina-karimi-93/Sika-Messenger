import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../providers/channels_provider.dart';

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
            child: Text(""),
          );
        }

        return const Center(
          child: Text("Something went wrong!"),
        );
      },
    );
  }
}
