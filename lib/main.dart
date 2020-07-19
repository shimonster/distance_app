import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yaml/yaml.dart';

import './providers/categories.dart';
import './providers/distances.dart';
import './screens/auth/auth_screen.dart';
import './screens/distances/distances_screen.dart';
import './screens/pickers/add_distance_track_screen.dart';
import 'helpers/style.dart';

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

  void _switchMode() {
    setState(() {
      _account = !_account;
    });
  }

  @override
  void initState() {
    super.initState();
    Style().getData().then((value) {
      setState(() {
        style = value;
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
    print('main build: $style');
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
                      style['appStyle']['colors']['primaryLightRGBO'][0],
                      style['appStyle']['colors']['primaryLightRGBO'][1],
                      style['appStyle']['colors']['primaryLightRGBO'][2],
                      style['appStyle']['colors']['primaryLightRGBO'][3]
                          .toDouble(),
                    ),
              primaryColor: style == null
                  ? Colors.blue
                  : Color.fromRGBO(
                      style['appStyle']['colors']['primaryRGBO'][0],
                      style['appStyle']['colors']['primaryRGBO'][1],
                      style['appStyle']['colors']['primaryRGBO'][2],
                      style['appStyle']['colors']['primaryRGBO'][3].toDouble(),
                    ),
              primaryColorDark: style == null
                  ? Colors.blue[900]
                  : Color.fromRGBO(
                      style['appStyle']['colors']['primaryDarkRGBO'][0],
                      style['appStyle']['colors']['primaryDarkRGBO'][1],
                      style['appStyle']['colors']['primaryDarkRGBO'][2],
                      style['appStyle']['colors']['primaryDarkRGBO'][3]
                          .toDouble(),
                    ),
              accentColor: style == null
                  ? Colors.yellowAccent
                  : Color.fromRGBO(
                      style['appStyle']['colors']['accentRGBO'][0],
                      style['appStyle']['colors']['accentRGBO'][1],
                      style['appStyle']['colors']['accentRGBO'][2],
                      style['appStyle']['colors']['accentRGBO'][3].toDouble(),
                    ),
              backgroundColor: style == null
                  ? Colors.white
                  : Color.fromRGBO(
                      style['appStyle']['colors']['scaffoldRGBO'][0],
                      style['appStyle']['colors']['scaffoldRGBO'][1],
                      style['appStyle']['colors']['scaffoldRGBO'][2],
                      style['appStyle']['colors']['scaffoldRGBO'][3].toDouble(),
                    ),
              scaffoldBackgroundColor: style == null
                  ? Colors.white
                  : Color.fromRGBO(
                      style['appStyle']['colors']['scaffoldRGBO'][0],
                      style['appStyle']['colors']['scaffoldRGBO'][1],
                      style['appStyle']['colors']['scaffoldRGBO'][2],
                      style['appStyle']['colors']['scaffoldRGBO'][3].toDouble(),
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
                  borderRadius: BorderRadius.circular(10),
                ),
                buttonColor: style == null
                    ? Colors.blue[900]
                    : Color.fromRGBO(
                        style['appStyle']['colors']['primaryLightRGBO'][0],
                        style['appStyle']['colors']['primaryLightRGBO'][1],
                        style['appStyle']['colors']['primaryLightRGBO'][2],
                        style['appStyle']['colors']['primaryLightRGBO'][3]
                            .toDouble(),
                      ),
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
