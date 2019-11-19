import 'package:flutter/material.dart';

import 'package:hello/hello.dart';
import 'package:hello/image.dart';

class Settings extends StatefulWidget {
  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  LegoColor _colorField = Hello.basePlateColor;

  List<DropdownMenuItem<LegoColor>> items = [DropdownMenuItem(child: Text("Grey"), value: LegoColor.none), DropdownMenuItem(child: Text("Red"), value: LegoColor.red), DropdownMenuItem(child: Text("Green"), value: LegoColor.green), DropdownMenuItem(child: Text("Blue"), value: LegoColor.blue)];

  void _hostnameFieldChanged(String newHostname) {
    Hello.webApiHost = newHostname;
  }

  void _updateBaseplateColor(LegoColor color) {
    Hello.basePlateColor = color;

    setState(() {
      _colorField = color;
    });
  }

  void _updateBaseplateWidth(String value) {
    int newWidth = int.parse(value);
    Hello.basePlateWidth = newWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: Container(
          child: Center(
            child: Column(
              children: <Widget>[
                TextField(
                  onChanged: _hostnameFieldChanged,
                  decoration: InputDecoration(
                    hintText: "Mindstorm IPv4 address",
                  ),
                ),
                Text("Baseplate color:"),
                DropdownButton(
                  items: items,
                  onChanged: _updateBaseplateColor,
                  value: _colorField,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: _updateBaseplateWidth,
                  decoration: InputDecoration(
                    hintText: "Baseplate width (cm)"
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}
