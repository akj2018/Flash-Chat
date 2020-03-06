import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:io' show Platform;
import 'package:fluttertoast/fluttertoast.dart';

enum authProblems { UserNotFound, PasswordNotValid, NetworkError }

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();

  static const String id = 'login_screen';
}

class _LoginScreenState extends State<LoginScreen> {
  String _email;
  String _password;
  bool showSpinner = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  authProblems errorType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/register_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Flexible(
                  child: Hero(
                    tag: 'logo',
                    child: Container(
                      height: 200.0,
                      child: Image.asset('images/logo.png'),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
                TextField(
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    _email = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your email'),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextField(
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                  obscureText: true,
                  onChanged: (value) {
                    _password = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your Password'),
                ),
                SizedBox(
                  height: 24.0,
                ),
                RoundedButton(
                  buttonColor: Colors.lightBlueAccent,
                  title: 'Log In',
                  onPressed: () async {
                    try {
                      setState(() {
                        showSpinner = true;
                      });

                      AuthResult validUser =
                          await _auth.signInWithEmailAndPassword(
                              email: _email, password: _password);
                      if (validUser != null) {
                        Navigator.pushNamed(context, ChatScreen.id);
                      }
                      setState(() {
                        showSpinner = false;
                      });
                    } catch (e) {
                      setState(() {
                        showSpinner = false;
                      });
                      String errorMessage = "";
                      if (Platform.isAndroid) {
                        switch (e.message) {
                          case 'There is no user record corresponding to this identifier. The user may have been deleted.':
                            errorType = authProblems.UserNotFound;
                            errorMessage = "USER NOT FOUND";
                            break;
                          case 'The password is invalid or the user does not have a password.':
                            errorType = authProblems.PasswordNotValid;
                            errorMessage = "INVALID PASSWORD";
                            break;
                          case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
                            errorType = authProblems.NetworkError;
                            errorMessage = "NETWORK ERROR";
                            break;
                          // ...
                          default:
                            print('Case ${e.message} is not jet implemented');
                            errorMessage = "TRY AGAIN";
                        }
                      } else if (Platform.isIOS) {
                        switch (e.code) {
                          case 'Error 17011':
                            errorType = authProblems.UserNotFound;
                            errorMessage = "USER NOT FOUND";
                            break;
                          case 'Error 17009':
                            errorType = authProblems.PasswordNotValid;
                            errorMessage = "INVALID PASSWORD";
                            break;
                          case 'Error 17020':
                            errorType = authProblems.NetworkError;
                            errorMessage = "NETWORK ERROR";
                            break;
                          // ...
                          default:
                            print('Case ${e.message} is not jet implemented');
                            errorMessage = "TRY AGAIN";
                        }
                      }

                      print('The error is $errorType');
                      Fluttertoast.showToast(
                          msg: "$errorMessage",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.TOP,
                          timeInSecForIos: 2,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
