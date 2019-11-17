import 'dart:convert';

import 'package:http/http.dart' as http;

Future getResponseFromEndpoint(String url) async {
  try {
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Exception $e');
    return null;
  }
}

Future postToEndpointWithBody(String url, Map<String, String> body) async {
  try {
    var response = await http.post(url, body: body);

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204 ||
        response.statusCode == 206) {
      return jsonDecode(response.body);
    } else {
      print('Error: ${response.statusCode}  response : ${response.body}');
      return null;
    }
  } catch (e) {
    print('Exception $e');
    return null;
  }
}
