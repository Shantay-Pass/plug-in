import 'dart:convert';

import 'hello.dart';
import 'package:http/http.dart' as http;

class Web {
  static Future<http.Response> postRequest(String endpoint, dynamic payload) async {
    return await http.post("http://${Hello.webApiHost}/$endpoint", headers: {
      'content-type': 'application/json'
    }, body: json.encode(payload));
  }

  static Future<http.Response> getRequest(String endpoint) async {
    return await http.get("http://${Hello.webApiHost}/$endpoint");
  }
}

class WebResult {
  int resultCode;
  String resultMessage;

  WebResult(resultCode, resultMessage) {
    this.resultCode = resultCode;
    this.resultMessage = resultMessage;
  }
}