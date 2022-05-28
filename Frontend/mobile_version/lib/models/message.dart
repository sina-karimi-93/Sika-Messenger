class Message {
  Message({
    required this.id,
    required this.message,
    required this.owner,
    required this.createDate,
  });

  final String id;
  final String message;
  final String owner;
  final String createDate;
  String updateDate = "";
}
