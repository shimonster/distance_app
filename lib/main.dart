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
//              primaryColor: Color.fromRGBO(191, 154, 202, 1),
//              primaryColorLight: Color.fromRGBO(212, 188, 220, 1),
//              primaryColorDark: Color.fromRGBO(152, 95, 171, 1),
//              accentColor: Color.fromRGBO(199, 232, 243, 1),
//              backgroundColor: Color.fromRGBO(245, 249, 241, 1),
//              scaffoldBackgroundColor: Color.fromRGBO(245, 249, 241, 1),
//
//              primaryColor: Color.fromRGBO(30, 204, 114, 1),
//              primaryColorLight: Color.fromRGBO(191, 214, 255, 1),
//              primaryColorDark: Color.fromRGBO(0, 148, 67, 1),
//              accentColor: Color.fromRGBO(212, 89, 36, 1),
//              backgroundColor: Color.fromRGBO(26, 9, 100, 1),
//              scaffoldBackgroundColor: Color.fromRGBO(255, 235, 219, 1),
//
              primaryColor: Color.fromRGBO(126, 144, 241, 1),
              primaryColorLight: Color.fromRGBO(212, 166, 230, 1),
              primaryColorDark: Color.fromRGBO(121, 104, 184, 1),
              accentColor: Color.fromRGBO(237, 120, 90, 1),
              backgroundColor: Color.fromRGBO(255, 213, 173, 1),
              scaffoldBackgroundColor: Color.fromRGBO(255, 213, 173, 1),
              buttonTheme: ButtonTheme.of(context).copyWith(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                buttonColor: Color.fromRGBO(237, 120, 90, 1),
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
