import 'package:flutter/material.dart';

import 'package:hello/hello.dart';

class Settings extends StatefulWidget {
  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _hostNameField = Hello.webApiHost;

  void _hostnameFieldChanged(String newHostname) {
    setState(() {
      _hostNameField = newHostname;
    });
  }

  void _updateHostname() {
    Hello.webApiHost = _hostNameField;
    print("Changed host to ${Hello.webApiHost}");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}
