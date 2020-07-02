import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthCard extends StatefulWidget {
  AuthCard(this.switchMode);

  final void Function() switchMode;

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _form = GlobalKey();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;
  String email;
  String password;
  bool _isLoading = false;

  Future<void> _authenticate() async {
    final auth = FirebaseAuth.instance;
    if (_form.currentState.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });
        _form.currentState.save();
        if (_isLogin) {
          auth.signInWithEmailAndPassword(email: email, password: password);
        } else {
          auth.createUserWithEmailAndPassword(email: email, password: password);
        }
        setState(() {
          _isLoading = false;
        });
      } on PlatformException catch (error) {
        Scaffold.of(context).hideCurrentSnackBar();
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
          ),
        );
      } catch (error) {
        Scaffold.of(context).hideCurrentSnackBar();
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong while trying authenticate you'),
          ),
        );
      }
    }
  }

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
            key: _form,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (value) => email = value,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter an email';
                      }
                      if (!RegExp(
                              '^([a-zA-Z0-9_\\-\\.]+)@([a-zA-Z0-9_\\-\\.]+)\\.([a-zA-Z]{2,5})\$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    onSaved: (value) => password = value,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 7) {
                        return 'Passwords must be at least 7 characters long';
                      }
                      return null;
                    },
                  ),
                  if (!_isLogin)
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Please enter the same value as your password';
                        }
                        return null;
                      },
                    ),
                  SizedBox(
                    height: 10,
                  ),
                  if (!_isLoading)
                    RaisedButton(
                      child: Text(_isLogin ? 'Login' : 'Signup'),
                      onPressed: _authenticate,
                    )
                  else
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                  FlatButton(
                    child: Text('${_isLogin ? 'Signup' : 'Login'} instead'),
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                  ),
                  FlatButton(
                    child: Text('Continue without an account'),
                    onPressed: _isLoading
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Are you sure?'),
                                content: Text(
                                    'If you continue without an account, the measurements you take will be saved to your device. Create and acount if you would like to back them up'),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('OK'),
                                    onPressed: widget.switchMode,
                                  ),
                                  FlatButton(
                                    child: Text('CANCEL'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              ),
                            );
                          },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
