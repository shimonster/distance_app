import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  GoogleSignInAccount _googleAccount;
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
  void initState() {
    _listener = _googleSignIn.onCurrentUserChanged.listen((account) {
      print('authstate changed');
      setState(() {
        _googleAccount = account;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (ctx, snapshot) {
        print('builder was run');
        print('auth snapshot: ${snapshot.data}');
        print('google snapshot: ${_googleAccount}');
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: Categories(
                snapshot.data != null
                    ? snapshot.data.uid
                    : _googleAccount != null ? _googleAccount.id : null,
              ),
            ),
            ChangeNotifierProxyProvider<Categories, Distances>(
              create: (ctx) => Distances(
                snapshot.data != null
                    ? snapshot.data.uid
                    : _googleAccount != null ? _googleAccount.id : null,
                [],
                [],
              ),
              update: (ctx, cat, prev) => Distances(
                snapshot.data != null
                    ? snapshot.data.uid
                    : _googleAccount != null ? _googleAccount.id : null,
                cat.categories,
                prev == null ? [] : prev.distances,
              ),
            ),
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
                : snapshot.data != null || _googleAccount != null || !_account
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
