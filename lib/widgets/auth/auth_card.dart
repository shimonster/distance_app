import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:distanceapp/providers/categories.dart';
import 'package:distanceapp/main.dart';

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
  bool _isGoogleLoading = false;

  Future<void> _authenticate() async {
    final auth = FirebaseAuth.instance;
    if (_form.currentState.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });
        _form.currentState.save();
        if (_isLogin) {
          await auth.signInWithEmailAndPassword(
              email: email, password: password);
        } else {
          await auth
              .createUserWithEmailAndPassword(email: email, password: password)
              .then((value) => Provider.of<Categories>(context, listen: false)
                  .putInitialCategories(value.user.uid));
        }
        await Provider.of<Categories>(context, listen: false).getCategories();
        setState(() {
          _isLoading = false;
        });
      } on PlatformException catch (error) {
        Scaffold.of(context).hideCurrentSnackBar();
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        print(error);
        Scaffold.of(context).hideCurrentSnackBar();
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong while trying authenticate you'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainStyle = Provider.of<MyAppState>(context, listen: false).style;
    final style = mainStyle['appStyle']['authCard'];
    return Container(
      width: MediaQuery.of(context).size.width * style['width'],
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * style['maxHeight'],
      ),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(style['padding']),
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
                        return 'Password must be 7 characters long';
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
                      child: Text(_isLogin ? 'Login' : 'Sign up'),
                      onPressed: _authenticate,
                    )
                  else
                    CircularProgressIndicator(),
                  if (_isGoogleLoading)
                    CircularProgressIndicator()
                  else
                    SizedBox(
                      height: 37,
                      child: OutlineButton.icon(
                        borderSide: BorderSide(color: Colors.black87),
                        icon: Image.asset(
                          style['googleImage'],
                          fit: BoxFit.fitHeight,
                        ),
                        label: Text('Sign in with google'),
                        onPressed: () async {
                          setState(() {
                            _isGoogleLoading = true;
                          });
                          final result = await GoogleSignIn().signIn();
                          final GoogleSignInAuthentication authentication =
                              await result.authentication;
                          final AuthCredential credentials =
                              GoogleAuthProvider.getCredential(
                                  idToken: authentication.idToken,
                                  accessToken: authentication.accessToken);
                          final re = await FirebaseAuth.instance
                              .signInWithCredential(credentials)
                              .then((value) =>
                                  value.additionalUserInfo.isNewUser
                                      ? Provider.of<Categories>(context,
                                              listen: false)
                                          .putInitialCategories(value.user.uid)
                                      : null);
                        },
                      ),
                    ),
                  FlatButton(
                    child: Text(
                        '${_isLogin ? 'Create an acount' : 'Already have an acount'}'),
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
                                    'If you continue without an account, your '
                                    'distances will be saved to your devices '
                                    'hard-drive and won\'t be backed up. If '
                                    'something happens to your device, your '
                                    'distances will be lost.'),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      widget.switchMode();
                                      Provider.of<Categories>(context,
                                              listen: false)
                                          .putInitialCategories();
                                      Provider.of<Categories>(context,
                                              listen: false)
                                          .getCategories();
                                    },
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
