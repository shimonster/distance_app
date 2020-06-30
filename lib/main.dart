import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './providers/categories.dart';
import './providers/distances.dart';
import './screens/auth/auth_screen.dart';
import './screens/distances/distances_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _account = true;

  void _switchMode() {
    setState(() {
      _account = !_account;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (ctx, snapshot) {
        print(snapshot.data);
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: Categories(
                snapshot.data != null ? snapshot.data.uid : null,
              ),
            ),
            ProxyProvider<Categories, Distances>(
              update: (ctx, cat, prev) => Distances(
                snapshot.data != null ? snapshot.data.uid : null,
                cat.categories,
                prev.distances,
              ),
            ),
          ],
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
            home: snapshot.data == null && _account
                ? AuthScreen()
                : DistancesScreen(),
          ),
        );
      },
    );
  }
}
