import 'package:flutter/material.dart';

import '../../widgets/auth/auth_card.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen(this.switchMode);

  final void Function() switchMode;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            child: Image.asset(
              'assets/images/distance.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).accentColor.withOpacity(0.9),
                  Theme.of(context).primaryColor.withOpacity(0.75),
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
