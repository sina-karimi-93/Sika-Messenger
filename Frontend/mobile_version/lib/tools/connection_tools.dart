import 'dart:convert';
import 'package:http/http.dart' as http;

String convertToBase64(String email, String password) {
  /*
  This method gets email and password and convert them to
  a base64 codec. This is required when user send request
  to server and this should be in header as authorization.
  */
  String credential = "$email:$password";
  Codec<String, String> stringToBase64 = utf8.fuse(base64);
  String encoded = stringToBase64.encode(credential);
  String headerAuthorizeShape = "Basic $encoded";
  return headerAuthorizeShape;
}

Future<bool> getAllUserData() async {
  Map<String, String> headers = {
    "authorization": convertToBase64("sina@gmail.com", "1111")
  };
  // Uri userChatsUrl = Uri.parse("127.0.0.1:8001/user/chats");
  // Uri userGroupsUrl = Uri.parse("127.0.0.1:8001/user/groups");
  Uri userChannelsUrl = Uri.http("192.168.1.106:8001", "/user/channels");
  final userData = await Future.wait([
    // http.get(userChatsUrl),
    // http.get(userGroupsUrl),
    http.get(
      userChannelsUrl,
      headers: headers,
    ),
  ]);
  print(userData[0].body);
  return true;
}

Future<dynamic> loginUser(String email, String password) async {
  /*
  This method sends a post request to server to check user credential
  and if it is valid gets user data and login him/her.

  args: 
    email: user email
    password: user password
  */
  Uri loginUrl = Uri.http("192.168.1.106", "/user/login");
  final Map<String, String> headers = {
    "authorization": convertToBase64(email, password)
  };
  final response = await http.post(loginUrl, headers: headers);

  return response.body;
}
