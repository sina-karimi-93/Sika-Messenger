import 'package:flutter/widgets.dart';

import '../tools/connection_tools.dart';

import '../models/message.dart';
import '../models/chat.dart';

class ChatsProvider with ChangeNotifier {
  List<Chat> _chats = [];

  List<Chat> get chats {
    return [..._chats];
  }

  Future<void> fetchAndSetChats({
    required Map<String, String> userCredential,
  }) async {
    final response = await apiInteraction('/user/chats', userCredential, "get");
    if (response["title"] == "ok") {
      final userChats = response["chats"];
      List<Chat> allChats = [];
      for (Map<String, dynamic> chat in userChats) {
        String id = chat["_id"]["\$oid"];
        List<String> owners = [
          chat["owners"][0]["\$oid"],
          chat["owners"][1]["\$oid"],
        ];
        String createDate = chat["create_date"]["\$date"];
        List<Message> messages = [];
        for (Map<String, dynamic> message in chat["messages"]) {
          var m = Message(
              id: message["_id"]["\$oid"],
              message: message["message"],
              owner: message["owner"]["\$oid"],
              createDate: message["create_date"]["\$date"]);

          if (message["update_date"] != null) {
            m.updateDate = message["update_date"]["\$date"];
          }

          messages.add(m);
        }
        allChats.add(
          Chat(
            id: id,
            owners: owners,
            messages: messages,
            createDate: createDate,
          ),
        );
      }
      _chats = allChats;
      notifyListeners();
    }
  }
}
