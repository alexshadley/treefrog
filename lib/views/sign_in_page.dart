import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

import 'package:leapfrog/config.dart';
import 'package:leapfrog/views/email_sign_up_page.dart';
import 'package:leapfrog/views/email_sign_in_page.dart';
import 'package:leapfrog/views/placeholder_page.dart';
import 'package:leapfrog/models/sign_in_result.dart';
import 'package:leapfrog/sign_in.dart';

class LoginPage extends StatefulWidget {
  LoginPage();

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _config = new Config();
  final _signIn = new SignIn();
  final _scaffold = new GlobalKey<ScaffoldState>();

  var _ready = false;

  @override
  void initState() {
    super.initState();

    _config.init().then((result) {
      setState(() {
        _ready = true;
      });
    });
  }

  Function() _oauthSignIn(LoginMethod method) {
    return (){
      method().then((result) {
        if (result == SignInResult.INCORRECT_METHOD) {
          _scaffold.currentState.showSnackBar(new SnackBar(content: new Text("Email was originally registered with a different sign-in method.")));
        }
        else if (result == SignInResult.FAILURE) {
          _scaffold.currentState.showSnackBar(new SnackBar(content: new Text("Registration failed.")));
        }
        else {
          Navigator.push(context, new MaterialPageRoute(builder: (context) => new PlaceholderPage()));
        }
      });
    };
  }

  void _emailSignIn() {
    Navigator.push(context, new MaterialPageRoute(builder: (context) => new EmailSignInPage(_config)));
  }

  void _emailSignUp() {
    Navigator.push(context, new MaterialPageRoute(builder: (context) => new SignUpPage(_config)));
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready)
      return new Scaffold();

    return new Scaffold(
      key: _scaffold,
      body: new Container(
        decoration: new BoxDecoration(color: new Color(int.parse(_config.getValue("primary_color"), radix: 16))),
        child: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                _config.getValue("app_name"),
                style: new TextStyle(fontSize: 40.0)
              ),
              new Container(
                  margin: new EdgeInsets.only(top: 80.0),
                  child: new Column(
                      children: <Widget>[
                        SignInButton(Buttons.GoogleDark, onPressed: _oauthSignIn(_signIn.googleSignIn)),
                        SignInButton(Buttons.Facebook, onPressed: _oauthSignIn(_signIn.facebookSignIn)),
                        SignInButton(Buttons.Email, onPressed: _emailSignIn),
                        new Container(
                          margin: new EdgeInsets.fromLTRB(0.0, _config.getValue("form_submit_margin"), 0.0, 0.0),
                          child: new RaisedButton(
                            color: new Color(int.parse(_config.getValue("form_button_background"), radix: 16)),
                            child: new Text("Sign Up"),
                            onPressed: _emailSignUp,
                          )
                        )
                      ]
                  )
              )
            ],
          ),
        ),
      )
    );
  }
}
