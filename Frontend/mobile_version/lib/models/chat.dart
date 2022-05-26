class Chat {
  const Chat({
    required this.id,
    required this.owner,
    required this.message,
    required this.createdDate,
  });

  final String id;
  final String owner;
  final String message;
  final DateTime createdDate;
}
