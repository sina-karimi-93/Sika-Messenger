import 'package:flutter/widgets.dart';
import 'package:mobile_version/models/message.dart';
import 'package:web_socket_channel/io.dart' as ws;
import '../tools/connection_tools.dart' as server;
import '../models/channel.dart';

class ChannelsProvider with ChangeNotifier {
  List<Channel> _channels = [];
  var channelSocket;
  List<Channel> get channels {
    return [..._channels];
  }

  List<Channel> _extractData(List<dynamic> userChannels) {
    final List<Channel> allChannels = [];

    for (Map<String, dynamic> channel in userChannels) {
      final String id = channel["_id"]["\$oid"];
      final String channelName = channel["channel_name"];
      final String owner = channel["owner"]["\$oid"];
      final String createDate = channel["create_date"]["\$date"];

      final admins = channel["admins"];
      final members = channel["members"];
      final List<Message> messages = [];
      for (Map<String, dynamic> message in channel["messages"]) {
        final Message m = Message(
            id: message["_id"]["\$oid"],
            message: message["message"],
            owner: message["owner"]["\$oid"],
            createDate: message["create_date"]["\$date"]);
        if (message["update_date"] != null) {
          m.updateDate = message["update_date"]["\$date"];
        }
        messages.add(m);
      }
      allChannels.add(
        Channel(
          id: id,
          channelName: channelName,
          owner: owner,
          createDate: createDate,
          messages: messages,
          admins: admins,
          members: members,
        ),
      );
    }
    return allChannels;
  }

  Future<void> fetchAndSetChannels(
      {required Map<String, String> userCredential}) async {
    final response =
        await server.apiInteraction("/user/channels", userCredential, "get");
    if (response["title"] == "ok") {
      final userChannels = response["channels"];
      _channels = _extractData(userChannels);
      notifyListeners();
    }
  }

  Channel getChannelById(String id) {
    /*
    This method gets an id and return a channel which its id is match
    with the id comes from arguments.
    */
    final Channel channel =
        _channels.where((element) => element.id == id).first;
    return channel;
  }

  void addMessage(
      String channelId, String message, String owner, String createDate) {
    /*
        This method adds new message to a specific channel.
        */
    final new_message = Message(
        id: channelId, message: message, owner: owner, createDate: createDate);
    _channels
        .where((element) => element.id == channelId)
        .first
        .messages
        .add(new_message);
  }

  ws.IOWebSocketChannel connectToChannelSocket(
    String channelId,
    Map<String, dynamic> userCredential,
  ) {
    channelSocket = server.connectToWebSocket("/user/channels/$channelId", {
      "email": userCredential["email"],
      "password": userCredential["password"]
    });
    return channelSocket;
  }

  void closeChannelSocket() {
    /*
    This method close the connection of the channel socket;
    */
    if (channelSocket != null) {
      channelSocket.sink.close();
    }
  }
}
