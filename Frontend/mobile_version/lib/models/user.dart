class User {
  const User({
    required this.localId,
    required this.serverId,
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.profilePictures,
    required this.chats,
    required this.groups,
    required this.channels,
  });

  final String localId;
  final String serverId;
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final List<String> profilePictures;
  final List<String> chats;
  final List<String> groups;
  final List<String> channels;
}
