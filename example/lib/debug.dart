import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hello/image.dart';

import 'package:image/image.dart' as Duncan;

class Debug extends StatefulWidget {
  @override
  _DebugState createState() => _DebugState();
}

class _DebugState extends State<Debug> {
  Image _debugImage;

  @override
  void initState() {
    super.initState();

    if (ImageAnalysis.debugImage == null)
      _debugImage = null;
    else
      _debugImage = Image.memory(Duncan.encodePng(ImageAnalysis.debugImage));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug'),
      ),
      body: Center(
        child: _debugImage == null
            ? Text('No image selected.')
            : _debugImage,
      )
    );
  }
}