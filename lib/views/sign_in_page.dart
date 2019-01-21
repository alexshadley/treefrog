import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

import 'package:leapfrog/config.dart';
import 'package:leapfrog/views/email_sign_up_page.dart';
import 'package:leapfrog/views/email_sign_in_page.dart';
import 'package:leapfrog/views/placeholder_page.dart';
import 'package:leapfrog/models/sign_in_result.dart';
import 'package:leapfrog/sign_in.dart';

/// The main sign-in page, where the user can select a sign-in method.
class SignInPage extends StatefulWidget {
  /// Creates the state of the sign-in page.
  @override
  _SignInPageState createState() => new _SignInPageState();
}

/// The state of the sign-in page.
class _SignInPageState extends State<SignInPage> {
  final _config = new Config();
  final _signIn = new SignIn();
  final _scaffold = new GlobalKey<ScaffoldState>();

  /// Indicates whether `init()` has been called on [_config].
  var _ready = false;

  /// Initializes the sign-in page state.
  @override
  void initState() {
    super.initState();
    _signIn.checkCache()
    .then((email) {
       if (email.isNotEmpty)
         Navigator.push(context, new MaterialPageRoute(builder: (context) => new PlaceholderPage(email)));
    });

    _config.init().then((result) {
      setState(() {
        _ready = true;
      });
    });
  }

  /// Gets a function that can be called to sign in with the given [OAuthLoginMethod].
  Function() _oauthSignIn(OAuthLoginMethod method) {
    return (){
      method().then((result) {
        if (result.resultType == ResultType.INCORRECT_METHOD) {
          _scaffold.currentState.showSnackBar(new SnackBar(content: new Text("Email was originally registered with a different sign-in method.")));
        }
        else if (result.resultType == ResultType.FAILURE) {
          _scaffold.currentState.showSnackBar(new SnackBar(content: new Text("Registration failed.")));
        }
        else {
          Navigator.push(context, new MaterialPageRoute(builder: (context) => new PlaceholderPage(result.email)));
        }
      });
    };
  }

  /// Opens the email sign-in page.
  void _emailSignIn() {
    Navigator.push(context, new MaterialPageRoute(builder: (context) => new EmailSignInPage(_config)));
  }

  /// Opens the email sign-up page.
  void _emailSignUp() {
    Navigator.push(context, new MaterialPageRoute(builder: (context) => new SignUpPage(_config)));
  }

  /// Builds the sign-in page [Widget].
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
