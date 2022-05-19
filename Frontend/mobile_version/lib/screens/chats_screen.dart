import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/chats_screen/favorite_chats.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  final String status = "Connecting...";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        elevation: 0,
        title: Text(status),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: Column(
        children: [
          FavoriteChats(size: size),
        ],
      ),
    );
  }
}
