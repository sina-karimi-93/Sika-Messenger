import './message.dart';

class Channel {
  Channel({
    required this.id,
    required this.channelName,
    required this.description,
    required this.owner,
    required this.createDate,
    required this.messages,
    required this.members,
  });

  final String id;
  final String channelName;
  final String description;
  final Map<String, dynamic> owner;
  final String createDate;
  final List<Message> messages;
  final List<Map<String, dynamic>> members;
}
