import './message.dart';

class Group {
  Group({
    required this.id,
    required this.groupName,
    required this.owner,
    required this.createDate,
    required this.messages,
    required this.admins,
    required this.members,
  });

  final String id;
  final String groupName;
  final String owner;
  final String createDate;
  final List<Message> messages;
  final List<String> admins;
  final List<String> members;
}
