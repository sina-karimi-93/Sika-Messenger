import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart' as ws;

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

Future<dynamic> apiInteraction(
  String path,
  Map userCredential,
  String method, {
  body = const {},
}) async {
  /*
  This method is the core of the interaction with the server APIs.

  args:
    path: url of the desired route
    userCredential: includes email and password(later we use tokens)
    method: http method request, it could be get, post, patch or delete
  */
  final uri = Uri.http("192.168.1.106:8001", path);
  final headers = {
    "authorization": convertToBase64(userCredential["email"], "1111")
  };
  var response;
  var encodedBody = json.encode(body);

  switch (method) {
    case "get":
      response = await http.get(uri, headers: headers);
      break;
    case "post":
      response = await http.post(uri, headers: headers, body: encodedBody);
      break;
    case "patch":
      response = await http.patch(uri, headers: headers, body: encodedBody);
      break;
    case "delete":
      response = await http.delete(uri, headers: headers, body: encodedBody);
  }

  return json.decode(response.body);
}

Future<dynamic> loginUser(String email, String password) async {
  /*
  This method sends a post request to server to check user credential
  and if it is valid gets user data and login him/her.

  args: 
    email: user email
    password: user password
  */
  Uri loginUrl = Uri.http("192.168.1.106:8001", "/user/login");
  final Map<String, String> headers = {
    "authorization": convertToBase64(email, password)
  };
  final response = await http.post(loginUrl, headers: headers);
  return json.decode(response.body);
}

Future<dynamic> getUserData(
    String owner, Map<String, String> userCredential) async {
  /*
  This methods get user serverId and ask server to give user information.
  */
  print(owner);
  final response = await apiInteraction("/user/get-user",
      {"email": userCredential["email"], "password": "1111"}, "post",
      body: {
        "user_id": {"\$oid": owner}
      });
  final user = response["user"];
  return user;
}

ws.IOWebSocketChannel connectToWebSocket(
    String url, Map<String, dynamic> userCredential) {
  /*
  This method stablish a socket connection with the desired websocket and return
  the instance of the IOWebSocketChannel
  */
  final headers = {
    "authorization": convertToBase64(userCredential["email"], "1111")
  };
  final Uri uri = Uri.parse("ws://192.168.1.106:8001$url");
  final connection = ws.IOWebSocketChannel.connect(uri, headers: headers);
  return connection;
}
