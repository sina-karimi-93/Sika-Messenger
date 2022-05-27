class User {
  const User({
    required this.localId,
    required this.serverId,
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
  });

  final int localId;
  final String serverId;
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
}
