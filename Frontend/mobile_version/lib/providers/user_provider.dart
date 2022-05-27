import 'package:flutter/widgets.dart';
import '../models/user.dart';
import '../tools/connection_tools.dart' as server;

class UserProvider with ChangeNotifier {
  var user = User(
    id: 'id',
    name: 'name',
    email: 'email',
    password: 'password',
    phoneNumber: 'phoneNumber',
    createdDate: DateTime(2022),
    profilePictures: [],
    chats: [],
    groups: [],
    channels: [],
  );

  Future<void> login(String email, String password) async {
    final response = await server.loginUser(email, password);
  }
}
