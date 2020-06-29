import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './providers/distances.dart';
import './screens/auth_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (ctx, snapshot) => ChangeNotifierProvider.value(
        value: Distances(snapshot.data ? true : false),
        child: MaterialApp(
          title: 'Distance App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            accentColor: Color.fromARGB(1, 184, 115, 51),
          ),
          home: Scaffold(
            backgroundColor: Color.fromARGB(200, 184, 115, 51),
          ),
        ),
      ),
    );
  }
}
