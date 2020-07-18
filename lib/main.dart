import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yaml/yaml.dart';
import 'package:checked_yaml/checked_yaml.dart' as y;
import 'package:flutter/services.dart';

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
  String file;

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

  Future<void> getStyle() async {
    final data = await rootBundle.loadString('assets/style/style.yaml');
    final style = loadYaml(data);
    print(style);
  }

  @override
  void initState() {
    getStyle();
    super.initState();
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
//              primaryColor: Color.fromRGBO(126, 144, 241, 1),
//              primaryColorLight: Color.fromRGBO(212, 166, 230, 1),
//              primaryColorDark: Color.fromRGBO(121, 104, 184, 1),
//              accentColor: Color.fromRGBO(237, 120, 90, 1),
//              backgroundColor: Color.fromRGBO(255, 213, 173, 1),
//              scaffoldBackgroundColor: Color.fromRGBO(255, 213, 173, 1),
//
              primaryColorLight: Color.fromRGBO(187, 230, 228, 1),
              primaryColor: Color.fromRGBO(66, 191, 221, 1),
              primaryColorDark: Color.fromRGBO(8, 75, 131, 1),
              accentColor: Color.fromRGBO(252, 163, 17, 1),
              backgroundColor: Color.fromRGBO(255, 232, 189, 1),
              scaffoldBackgroundColor: Color.fromRGBO(255, 232, 189, 1),
              fontFamily: 'Nunito',
              textTheme: TextTheme(
                button: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nunito',
                ),
              ),
              appBarTheme: AppBarTheme.of(context).copyWith(
                iconTheme: IconThemeData(
                  color: Colors.white,
                ),
                textTheme: TextTheme(
                  headline6: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              buttonTheme: ButtonTheme.of(context).copyWith(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                buttonColor: Color.fromRGBO(8, 75, 131, 1),
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
