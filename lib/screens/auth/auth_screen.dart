import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:distanceapp/widgets/auth/auth_card.dart';
import 'package:distanceapp/main.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen(this.switchMode);

  final void Function() switchMode;
  @override
  Widget build(BuildContext context) {
    final mainStyle = Provider.of<MyAppState>(context, listen: false).style;
    final style = mainStyle['appStyle']['authScreen'];
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            child: Image.asset(
              style['imageURL'],
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context)
                      .accentColor
                      .withOpacity(style['accentOpacity']),
                  Theme.of(context)
                      .primaryColor
                      .withOpacity(style['primaryOpacity']),
                ],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
            child: Center(
              child: AuthCard(switchMode),
            ),
          ),
        ],
      ),
    );
  }
}
