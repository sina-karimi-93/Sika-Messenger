import 'dart:convert';

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
