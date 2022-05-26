import 'package:flutter/material.dart';

class HeaderItem extends StatelessWidget {
  const HeaderItem(
      {required this.title,
      required this.isSelected,
      required this.navigationHandler,
      Key? key})
      : super(key: key);

  final String title;
  final bool isSelected;
  final navigationHandler;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigationHandler(navigationKey: title.toLowerCase());
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 7),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              Icons.circle,
              size: 15,
              color: isSelected
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.blueGrey[900],
            )
          ],
        ),
      ),
    );
  }
}
