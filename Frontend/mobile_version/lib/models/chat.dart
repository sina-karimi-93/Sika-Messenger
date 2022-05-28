import './message.dart';

class Chat {
  const Chat({
    required this.id,
    required this.owners,
    required this.messages,
    required this.createDate,
  });

  final String id;
  final List<String> owners;
  final List<Message> messages;
  final String createDate;
}
