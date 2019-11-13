import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as RealImage;

import 'package:hello/hello.dart';
import 'package:hello/web.dart';
import 'package:hello/image.dart';

import 'settings.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _platformVersion = 'Unknown';
  String _serverStatus = 'Unknown';
  String _robotStatus = 'Unknown';
  String _imageResult = 'Unknown';

  List<String> _testProgram = ["mov 50 200", "rot 100 500", "say Hello, world", "pause 5", "mov 25 400"];

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _updateServerStatus();

    Timer.periodic(Duration(seconds: 10), (_) async {
      if(_serverStatus != "API accessible")
        return;

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
      _robotStatus =  status == "Host unavailable" ? "Unknown" : _robotStatus;
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

  void _testImageAnalysis() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    List<Brick> bricks = await Hello.getImageData(RealImage.decodeImage(image.readAsBytesSync()));
    Brick firstBrick = bricks.first;
    setState(() {
      _imageResult = "The first brick detected was a ${firstBrick.color} ${firstBrick.height} by ${firstBrick.width} brick";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
        actions: <Widget>[
          FloatingActionButton(
            child: Icon(Icons.add_a_photo),
            onPressed: _testImageAnalysis,
            backgroundColor: Colors.cyan,
          ),
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
            Text('Image results: $_imageResult\n'),
          ]
        )
      ),
    );
  }
}
