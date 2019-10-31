import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart';

import 'web.dart';

class Hello {
  static const MethodChannel _channel =
      const MethodChannel('hello');

  static String webApiHost = '192.168.1.12:5000';

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<WebResult> pingApi() async {
    Response res = await Web.getRequest("echo");

    if (res.statusCode == 200)
      return new WebResult(res.statusCode, "API accessible");

    return new WebResult(res.statusCode, "API unavailable");
  }

  static Future<WebResult> runProgram(List<String> instructions) async {
    dynamic payload = {"instructions": instructions};

    Response res = await Web.postRequest("runprogram", payload);

    if (res.statusCode == 200)
      return new WebResult(res.statusCode, "Request successful");

    var body = jsonDecode(res.body);
    return new WebResult(res.statusCode, body['message']);

  }

  static Future<WebResult> terminateProgram() async {
    Response res = await Web.getRequest("terminate");

    if (res.statusCode == 200)
      return new WebResult(res.statusCode, "Program termination requested");

    var body = jsonDecode(res.body);
    return new WebResult(res.statusCode, body['message']);
  }

  static Future<bool> checkBusy() async {
    Response res = await Web.getRequest("busy");

    switch(res.statusCode) {
      case 200:
        var body = jsonDecode(res.body);

        return body["status"] == 'true' ? true : false;
      default:
        return true;
    }
  }
}
