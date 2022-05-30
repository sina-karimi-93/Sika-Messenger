import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';

class ChannelScreenFooter extends StatelessWidget {
  ChannelScreenFooter({
    Key? key,
    required this.socketConnection,
    required this.handler,
    required this.messageCount,
  }) : super(key: key);

  final _messageController = TextEditingController();

  final IOWebSocketChannel socketConnection;
  final handler;
  final int messageCount;
  @override
  Widget build(BuildContext context) {
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary,
            spreadRadius: 0.1,
            blurRadius: 0.1,
          )
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isPortrait ? 20 : 50,
          vertical: 10,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _messageController,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  label: const Text(
                    "Message",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                final message = _messageController.value.text;
                if (message.isNotEmpty) {
                  handler(messageCount);
                  socketConnection.sink.add(_messageController.value.text);
                  _messageController.clear();
                }
              },
              icon: Icon(
                Icons.send,
                color: Theme.of(context).colorScheme.secondary,
              ),
            )
          ],
        ),
      ),
    );
  }
}
