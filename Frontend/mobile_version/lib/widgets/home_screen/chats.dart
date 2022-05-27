import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../providers/chats_provider.dart';
import '../../tools/connection_tools.dart';

class Chats extends StatelessWidget {
  const Chats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final chatsProvider = Provider.of<ChatsProvider>(context);
    return FutureBuilder(
      future: getAllUserData(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            child: Text(snapshot.data.toString()),
          );
        } else {
          return const Center(child: Text("Something went wrong!"));
        }
      }),
    );
  }
}
