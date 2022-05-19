import 'package:flutter/material.dart';

class FavoriteChats extends StatelessWidget {
  FavoriteChats({
    Key? key,
    required this.size,
  }) : super(key: key);

  final Size size;
  List favoriteChats = [
    {
      "name": "David",
      "profile_picture":
          "https://avaliha.ir/wp-content/uploads/2018/10/%D8%B9%DA%A9%D8%B3-%D9%BE%D8%B1%D9%88%D9%81%D8%A7%DB%8C%D9%84-%D8%B4%D8%AE%D8%B5.jpeg",
    },
    {""}
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height * 0.1,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      // child: ListView.builder(itemBuilder: (ctx, index) {}),
    );
  }
}
