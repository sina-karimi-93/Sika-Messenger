import './message.dart';

class Channel {
  Channel({
    required this.id,
    required this.channelName,
    required this.owner,
    required this.createDate,
    required this.messages,
    required this.admins,
    required this.members,
  });

  final String id;
  final String channelName;
  final String owner;
  final String createDate;
  final List<Message> messages;
  final List<String> admins;
  final List<String> members;
}
