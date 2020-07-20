import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:distanceapp/providers/categories.dart';
import 'package:distanceapp/providers/distances.dart';
import 'package:distanceapp/screens/auth/auth_screen.dart';
import 'package:distanceapp/screens/distances/distances_screen.dart';
import 'package:distanceapp/screens/pickers/add_distance_track_screen.dart';
import 'package:distanceapp/helpers/config.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with ChangeNotifier {
  var _account = true;
  StreamSubscription _listener;
  Map style;
  bool _isLoading = true;

  List<dynamic> primaryDark;
  List<dynamic> primary;
  List<dynamic> primaryLight;
  List<dynamic> accent;
  List<dynamic> scaffold;

  void _switchMode() {
    setState(() {
      _account = !_account;
    });
  }

  @override
  void initState() {
    super.initState();
    Config().getData().then((value) {
      setState(() {
        style = value;
        _isLoading = false;
        primaryDark = style['appStyle']['colors']['primaryLightRGBO'];
        primary = style['appStyle']['colors']['primaryRGBO'];
        primaryLight = style['appStyle']['colors']['primaryLightRGBO'];
        accent = style['appStyle']['colors']['accentRGBO'];
        scaffold = style['appStyle']['colors']['scaffoldRGBO'];
      });
      print('then block');
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
            ),
            ChangeNotifierProvider.value(
              value: this,
            ),
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
              primaryColorLight: style == null
                  ? Colors.lightBlue
                  : Color.fromRGBO(
                      primaryLight[0],
                      primaryLight[1],
                      primaryLight[2],
                      primaryLight[3],
                    ),
              primaryColor: style == null
                  ? Colors.blue
                  : Color.fromRGBO(
                      primary[0],
                      primary[1],
                      primary[2],
                      primary[3],
                    ),
              primaryColorDark: style == null
                  ? Colors.blue[900]
                  : Color.fromRGBO(
                      primaryDark[0],
                      primaryDark[1],
                      primaryDark[2],
                      primaryDark[3],
                    ),
              accentColor: style == null
                  ? Colors.yellowAccent
                  : Color.fromRGBO(
                      accent[0],
                      accent[1],
                      accent[2],
                      accent[3],
                    ),
              backgroundColor: style == null
                  ? Colors.white
                  : Color.fromRGBO(
                      scaffold[0],
                      scaffold[1],
                      scaffold[2],
                      scaffold[3],
                    ),
              scaffoldBackgroundColor: style == null
                  ? Colors.white
                  : Color.fromRGBO(
                      scaffold[0],
                      scaffold[1],
                      scaffold[2],
                      scaffold[3],
                    ),
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
                  borderRadius: BorderRadius.circular(style == null
                      ? 10
                      : style['appStyle']['general']['buttonRadius']),
                ),
                buttonColor: style == null
                    ? Colors.blue[900]
                    : Color.fromRGBO(
                        style['appStyle']['colors']['primaryLightRGBO'][0],
                        style['appStyle']['colors']['primaryLightRGBO'][1],
                        style['appStyle']['colors']['primaryLightRGBO'][2],
                        style['appStyle']['colors']['primaryLightRGBO'][3],
                      ),
                textTheme: ButtonTextTheme.primary,
              ),
            ),
            home: snapshot.connectionState == ConnectionState.waiting ||
                    _isLoading
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
