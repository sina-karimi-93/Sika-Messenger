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

  Future<bool> login(String email, String password) async {
    /*
    This method checks user credential and send a request to server
    for authentication and gets the response.

    args:
      email
      password
    */
    final response = await server.loginUser(email, password);
    if (response["title"] == "error") {
      return false;
    }
    print(response.runtimeType);
    return true;
  }
}
