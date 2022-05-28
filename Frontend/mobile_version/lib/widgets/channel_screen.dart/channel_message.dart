import 'package:flutter/material.dart';

class ChannelMessage extends StatelessWidget {
  const ChannelMessage(this.message, this.createDate, this.updateDate,
      {Key? key})
      : super(key: key);

  final String message;
  final String createDate;
  final String updateDate;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.8,
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            spreadRadius: 1,
            blurRadius: 8,
            color: Colors.black87,
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (updateDate.isNotEmpty)
                Text(
                  "updated",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(width: 5),
              if (updateDate.isNotEmpty)
                Text(
                  updateDate,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (updateDate.isEmpty)
                Text(
                  createDate,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
