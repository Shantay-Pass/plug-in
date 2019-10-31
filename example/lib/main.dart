import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hello/hello.dart';
import 'package:hello/web.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _serverStatus = 'Unknown';
  String _robotStatus = 'Unknown';

  List<String> _testProgram = ["mov 4 2", "rot 7 10", "say Hello, world", "pause 5", "mov 3 19"];

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _updateServerStatus();

    Timer.periodic(Duration(seconds: 3), (_) async {
      String status;

      try {
        bool busy = await Hello.checkBusy();
        status = busy ? "Busy" : "Ready";
      } on SocketException {
        status = "Unknown";
      }

      setState(() {
        _serverStatus = status == "Unknown" ? "Host unavailable" : _serverStatus;
        _robotStatus = status;
      });
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await Hello.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  void _updateServerStatus() async {
    String status = "Checking..";

    setState(() {
      _serverStatus = status;
    });

    try {
      WebResult res = await Hello.pingApi();
      status = res.resultMessage;
    } on SocketException {
      status = "Host unavailable";
    }

    if (!mounted) return;

    setState(() {
      _serverStatus = status;
    });
  }

  void _runProgram() {
    try {
      Hello.runProgram(_testProgram);
    } on SocketException {
      return;
    }
  }

  void _terminateProgram() {
    try {
      Hello.terminateProgram();
    } on SocketException {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: <Widget>[
            FloatingActionButton(
              child: Icon(Icons.play_arrow),
              onPressed: _runProgram,
              backgroundColor: Colors.green,
            ),
            FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: _terminateProgram,
              backgroundColor: Colors.red,
            ),
            FloatingActionButton(
              child: Icon(Icons.refresh),
              onPressed: _updateServerStatus,
              backgroundColor: Colors.amber,
            )
          ],
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Text('Running on: $_platformVersion\n'),
              Text('Server status: $_serverStatus\n'),
              Text('Robot status: $_robotStatus\n'),
            ]
          )
        ),
      ),
    );
  }
}
