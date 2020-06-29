import 'package:flutter/material.dart';

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 3 / 4,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 3 / 4,
      ),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Form(
            child: SingleChildScrollView(
              child: Column(),
            ),
          ),
        ),
      ),
    );
  }
}
