import 'package:flutter/widgets.dart';
import 'package:mobile_version/models/chat.dart';

class ChatsProvider with ChangeNotifier {
  List<Chat> chats = [];

  Future<void> fetchAndSetData() async {}
}
