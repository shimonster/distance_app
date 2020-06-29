import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Distance App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Color.fromARGB(1, 184, 115, 51),
      ),
      home: Scaffold(
        backgroundColor: Theme.of(context).accentColor,
      ),
    );
  }
}
