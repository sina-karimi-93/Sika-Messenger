import 'package:flutter/widgets.dart';
import '../models/user.dart';
import '../tools/connection_tools.dart' as server;
import '../database/db_handler.dart';

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

  // bool _checkUserExists(String serverId) {
  //   DbHandler.getUser(userId)
  //   return true;
  // }

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
    final user = response["user"];

    // Checks whether a user with this serverId exists in local database or not.
    // Sometimes it happens when user has trouble with his/her device.
    final currentUser = await DbHandler.isUserExists(user["_id"]["\$oid"]);
    if (currentUser.isNotEmpty) {
      await DbHandler.deleteUser(currentUser["localId"]);
    }
    // Insert user into local database
    final int localId = await DbHandler.insertRecord(
      table: 'users',
      data: {
        "serverId": user["_id"]["\$oid"],
        "email": user["email"],
        "name": user["name"],
        "password": user["password"],
        "phoneNumber": user["phone_number"]
      },
    );
    return true;
  }
}
