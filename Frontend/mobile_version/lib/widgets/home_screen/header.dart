import 'package:flutter/material.dart';
import 'header_item.dart';

class Header extends StatefulWidget {
  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  Map navigation = {
    "privates": true,
    "groups": false,
    "channels": false,
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
    return Container(
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
    );
  }
}
