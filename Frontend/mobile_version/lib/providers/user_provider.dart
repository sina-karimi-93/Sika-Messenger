import 'package:flutter/widgets.dart';
import '../models/user.dart';

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
}
