import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/channels_provider.dart';
import '../providers/user_provider.dart';

class ChannelScreen extends StatelessWidget {
  static const routeName = "channel-screen";

  ChannelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String channelId = routeArgs["id"];

    Provider.of<ChannelsProvider>(context);

    return Scaffold(
      appBar: AppBar(),
    );
  }
}
