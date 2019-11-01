import 'package:flutter/material.dart';

import 'settings.dart';
import 'home.dart';

void main() => runApp(Main());

class Main extends StatelessWidget {

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example App',
      theme: ThemeData(
          primarySwatch: Colors.blue
      ),
      home: Start(),
    );
  }

}

class Start extends StatefulWidget {
@override
State<StatefulWidget> createState() {return StartState();}
}

class StartState extends State<Start> {
  int _currentIndex = 0;
  int _tabbedButton =0;

  final List<Widget> _children = [
    Home(),
    Settings(),
  ];

  void onTabTapped(int index) {
    setState(() {
      if ((_currentIndex == 0 && index == 0) || (_currentIndex == (_children.length-1) && index == 1)) {return;}
      if (index == 1){
        _currentIndex++;
      }
      else if (index == 0){
        _currentIndex--;
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LEGO Visual Aid'),
      ),

      body: _children[_currentIndex], // new

      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // new
        currentIndex: _tabbedButton, // new
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.arrow_left),
            title: Text('Left'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.arrow_right),
            title: Text('Right'),
          ),
        ],
      ),
    );
  }
}
