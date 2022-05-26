class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.createdDate,
    required this.profilePictures,
    required this.chats,
    required this.groups,
    required this.channels,
  });

  final String id;
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final DateTime createdDate;
  final List<String> profilePictures;
  final List<String> chats;
  final List<String> groups;
  final List<String> channels;
}
