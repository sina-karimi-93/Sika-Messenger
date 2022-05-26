import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chats_provider.dart';

class Chats extends StatelessWidget {
  const Chats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatsProvider = Provider.of<ChatsProvider>(context);
    return FutureBuilder(
      future: chatsProvider.fetchAndSetData(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          return Container();
        } else {
          return const Center(child: Text("Something went wrong!"));
        }
      }),
    );
  }
}
