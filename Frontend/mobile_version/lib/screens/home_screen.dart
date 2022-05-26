import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/home_screen/header.dart';
import '../widgets/home_screen/chat_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  final String status = "Connecting...";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        elevation: 0,
        title: Text(status),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: Column(
        children: [
          const Header(),
          FutureBuilder(
            builder: ((context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              return Container();
            }),
          ),
        ],
      ),
    );
  }
}