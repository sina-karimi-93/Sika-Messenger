import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChannelMessage extends StatelessWidget {
  const ChannelMessage(
      this.message, this.isOwner, this.createDate, this.updateDate,
      {Key? key})
      : super(key: key);

  final String message;
  final bool isOwner;
  final String createDate;
  final String updateDate;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment:
          isOwner ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          width: size.width * 0.7,
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: isOwner
                ? const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    bottomLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                    bottomRight: Radius.circular(0),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    bottomLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(50),
                  ),
            boxShadow: [
              BoxShadow(
                spreadRadius: 1,
                blurRadius: 3,
                color: isOwner
                    ? Colors.purple
                    : Theme.of(context).colorScheme.primary,
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (updateDate.isNotEmpty)
                    Text(
                      "updated",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  const SizedBox(width: 5),
                  if (updateDate.isNotEmpty)
                    Text(
                      updateDate,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  if (updateDate.isEmpty)
                    Text(
                      DateFormat().format(DateTime.parse(createDate)),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
