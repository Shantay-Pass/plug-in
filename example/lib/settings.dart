import 'package:flutter/material.dart';

import 'package:hello/hello.dart';
import 'package:hello/image.dart';

class Settings extends StatefulWidget {
  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _hostNameField = Hello.webApiHost;
  LegoColor _colorField = Hello.basePlateColor;
  int _widthField = Hello.basePlateWidth;

  List<DropdownMenuItem<LegoColor>> items = [DropdownMenuItem(child: Text("Grey"), value: LegoColor.none), DropdownMenuItem(child: Text("Green"), value: LegoColor.green), DropdownMenuItem(child: Text("Red"), value: LegoColor.red)];

  void _hostnameFieldChanged(String newHostname) {
    setState(() {
      _hostNameField = newHostname;
    });
  }

  void _updateHostname() {
    Hello.webApiHost = _hostNameField;
    print("Changed host to ${Hello.webApiHost}");
  }

  void _updateBasePlateColor(LegoColor color) {
    Hello.basePlateColor = color;

    setState(() {
      _colorField = color;
    });
  }

  void _updateBasePlateWidth(String value) {
    int newWidth = int.parse(value);
    Hello.basePlateWidth = newWidth;

    setState(() {
      _widthField = newWidth;
    });
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
                Text("Mindstorm hostname:"),
                TextField(
                  onChanged: _hostnameFieldChanged,
                  decoration: InputDecoration(
                    hintText: _hostNameField,
                  ),
                ),
                FlatButton(
                  child: Text("Set hostname"),
                  onPressed: _updateHostname,
                ),
                Text("Base plate color:"),
                DropdownButton(
                  items: items,
                  onChanged: _updateBasePlateColor,
                  value: _colorField,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: _updateBasePlateWidth,
                  decoration: InputDecoration(
                    hintText: _widthField.toString()
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}
