import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './providers/categories.dart';
import './providers/distances.dart';
import './screens/auth/auth_screen.dart';
import './screens/distances/distances_screen.dart';
import './screens/pickers/add_distance_track_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _account = true;
  StreamSubscription _listener;

  void _switchMode() {
    setState(() {
      _account = !_account;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _listener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (ctx, AsyncSnapshot<FirebaseUser> snapshot) {
        print('auth snapshot: ${snapshot.data}');
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: Categories(
                snapshot.data != null ? snapshot.data.uid : null,
              ),
            ),
            ChangeNotifierProvider.value(
              value:
                  Distances(snapshot.data != null ? snapshot.data.uid : null),
            )
          ],
          child: MaterialApp(
            title: 'Distance App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              accentColor: Color.fromARGB(1000, 184, 115, 51),
              buttonTheme: ButtonTheme.of(context).copyWith(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                buttonColor: Colors.blue,
                textTheme: ButtonTextTheme.primary,
              ),
            ),
            home: snapshot.connectionState == ConnectionState.waiting
                ? Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : snapshot.data != null || !_account
                    ? DistancesScreen(_switchMode)
                    : AuthScreen(_switchMode),
            routes: {
              AddDistanceTrackScreen.routeName: (ctx) =>
                  AddDistanceTrackScreen(),
            },
          ),
        );
      },
    );
  }
}
