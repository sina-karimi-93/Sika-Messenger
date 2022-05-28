import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/home_screen/header_item.dart';
import '../widgets/home_screen/private_chats.dart';
import '../widgets/home_screen/channels.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const routeName = 'home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String status = "Connecting...";
  Map navigation = {
    "privates": false,
    "groups": false,
    "channels": true,
  };

  void navigationHandler({required String navigationKey}) {
    /*
    This method change the status of the navigation in Header.
    User by tapping on each HeaderItem select them like a RadioBox.

    args:
      navigationKey: name of a key in navigation variable which
                     comes from HeaderItem gesturedetector.
    */
    setState(() {
      navigation = {
        "privates": false,
        "groups": false,
        "channels": false,
      };
      navigation[navigationKey] = true;
    });
  }

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
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                HeaderItem(
                    title: "Privates",
                    isSelected: navigation["privates"],
                    navigationHandler: navigationHandler),
                HeaderItem(
                    title: "Groups",
                    isSelected: navigation["groups"],
                    navigationHandler: navigationHandler),
                HeaderItem(
                    title: "Channels",
                    isSelected: navigation["channels"],
                    navigationHandler: navigationHandler),
              ],
            ),
          ),
          if (navigation["privates"]) const PrivateChats(),
          if (navigation["channels"]) const Channels(),
        ],
      ),
    );
  }
}
