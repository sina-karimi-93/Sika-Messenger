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
      final String description = channel["description"];
      final Map<String, dynamic> owner = channel["owner"];
      final String createDate = channel["create_date"]["\$date"];
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
          description: description,
          owner: owner,
          createDate: createDate,
          messages: messages,
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
    final newMessage = Message(
        id: channelId, message: message, owner: owner, createDate: createDate);
    _channels
        .where((element) => element.id == channelId)
        .first
        .messages
        .add(newMessage);
  }

  Future<void> addMember(
    Map<String, String> userCredential,
    String channelId,
    String memberId,
  ) async {
    /*
    This method adds new member to the channel.
    
    args:
      userCredential
      memberId
    */

    final response = await server.apiInteraction(
      "/user/channels/add-member",
      userCredential,
      "patch",
      body: {
        "room_id": {"\$oid": channelId},
        "member_id": {"\$oid": memberId},
      },
    );
    if (response["title"] == "ok") {
      final Channel channel = getChannelById(channelId);
      channel.members.add(response["user"]);
      notifyListeners();
    }
  }

  Future<void> removeMember(
    Map<String, String> userCredential,
    String channelId,
    String memberId,
  ) async {
    /*
    This method removes a member from the channel.
    
    args:
      userCredential
      memberId
    */

    final response = await server.apiInteraction(
      "/user/channels/remove-member",
      userCredential,
      "patch",
      body: {
        "room_id": {"\$oid": channelId},
        "member_id": {"\$oid": memberId},
      },
    );
    if (response["title"] == "ok") {
      final Channel channel = getChannelById(channelId);
      channel.members
          .removeWhere((element) => element["_id"]["\$oid"] == memberId);
      notifyListeners();
    }
  }

  Future<void> addAdmin(
    Map<String, String> userCredential,
    String channelId,
    String memberId,
  ) async {
    /*
    This method makes a member, admin.
    args:
      userCredential
      memberId
    */

    final response = await server.apiInteraction(
      "/user/channels/add-admin",
      userCredential,
      "patch",
      body: {
        "room_id": {"\$oid": channelId},
        "member_id": {"\$oid": memberId},
      },
    );
    if (response["title"] == "ok") {
      final Channel channel = getChannelById(channelId);
      channel.members
          .where((element) => element["_id"]["\$oid"] == memberId)
          .first["is_admin"] = true;
      notifyListeners();
    }
  }

  Future<void> removeAdmin(
    Map<String, String> userCredential,
    String channelId,
    String memberId,
  ) async {
    /*
    This method makes an admin, member.
    args:
      userCredential
      memberId
    */

    final response = await server.apiInteraction(
      "/user/channels/remove-admin",
      userCredential,
      "patch",
      body: {
        "room_id": {"\$oid": channelId},
        "member_id": {"\$oid": memberId},
      },
    );
    if (response["title"] == "ok") {
      final Channel channel = getChannelById(channelId);
      channel.members
          .where((element) => element["_id"]["\$oid"] == memberId)
          .first["is_admin"] = false;
      notifyListeners();
    }
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
      channelSocket = null;
    }
  }

  bool checkMemberExists(Channel channel, String memberId) {
    /*
    This method checks whether a user is exists in channel members or not.

    args:
      Channel channel
      String memberId
    */
    if (channel.owner["_id"]["\$oid"] == memberId) {
      return true;
    }
    for (var user in channel.members) {
      if (user["_id"]["\$oid"] == memberId) {
        return true;
      }
    }
    return false;
  }

  bool checkMemberIsAdmin(Channel channel, String memberId) {
    /*
    This method check whether the member is admin or not.

    args:
      Channel channel
      String memberId
    */
    for (var member in channel.members) {
      if (member["_id"]["\$oid"] == memberId) {
        if (member["is_admin"] == true) {
          return true;
        }
      }
    }

    return false;
  }
}
