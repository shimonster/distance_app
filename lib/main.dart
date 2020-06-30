import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './providers/distances.dart';
import 'screens/auth/auth_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (ctx, snapshot) {
        print(snapshot.data);
        return ChangeNotifierProvider.value(
          value: snapshot.connectionState == ConnectionState.waiting
              ? Distances(false)
              : Distances(snapshot.data != null ? true : false),
          child: MaterialApp(
            title: 'Distance App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              accentColor: Color.fromARGB(1, 184, 115, 51),
              buttonTheme: ButtonTheme.of(context).copyWith(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                buttonColor: Colors.blue,
                textTheme: ButtonTextTheme.primary,
              ),
            ),
            home: AuthScreen(),
          ),
        );
      },
    );
  }
}
