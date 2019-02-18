import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:http/http.dart' as http;

import 'package:leapfrog/api.dart';
import 'package:leapfrog/config.dart';
import 'package:leapfrog/file_factory.dart';
import 'package:leapfrog/models.dart';
import 'package:leapfrog/sign_in.dart';
import 'package:leapfrog/views/email_sign_in_page.dart';
import 'package:leapfrog/views/email_sign_up_page.dart';
import 'package:leapfrog/views/menu.dart';

/// The main sign-in page, where the user can select a sign-in method.
class SignInPage extends StatefulWidget {

  final _config;
  final _signIn;

  final _googleSignInFunc;
  final _facebookSignInFunc;
  final _emailSignInFunc;
  final _emailSignUpFunc;

  SignInPage(Config config, SignIn signIn,
      {dynamic googleSignInFunc, dynamic facebookSignInFunc, dynamic emailSignInFunc, dynamic emailSignUpFunc}) :
    _config = config,
    _signIn = signIn,
    _googleSignInFunc = googleSignInFunc,
    _facebookSignInFunc = facebookSignInFunc,
    _emailSignInFunc = emailSignInFunc,
    _emailSignUpFunc = emailSignUpFunc;

  /// Creates the state of the sign-in page.
  @override
  _SignInPageState createState() => new _SignInPageState(_config, _signIn,
        googleSignInFunc: _googleSignInFunc,
        facebookSignInFunc: _facebookSignInFunc,
        emailSignInFunc: _emailSignInFunc,
        emailSignUpFunc: _emailSignUpFunc);
}

/// The state of the sign-in page.
class _SignInPageState extends State<SignInPage> {
  final _config;
  final _signIn;
  final _scaffold = new GlobalKey<ScaffoldState>();

  final _googleSignInFunc;
  final _facebookSignInFunc;
  final _emailSignInFunc;
  final _emailSignUpFunc;

  var _ready;

  _SignInPageState(Config config, SignIn signIn,
      {dynamic googleSignInFunc, dynamic facebookSignInFunc, dynamic emailSignInFunc, dynamic emailSignUpFunc}) :
    _config = config,
    _signIn = signIn,
    _ready = config.ready,
    _googleSignInFunc = googleSignInFunc,
    _facebookSignInFunc = facebookSignInFunc,
    _emailSignInFunc = emailSignInFunc,
    _emailSignUpFunc = emailSignUpFunc;

  /// Initializes the sign-in page state.
  @override
  void initState() {
    super.initState();
    _signIn.checkCache().then((email) {
      if (email.isNotEmpty)
        Navigator.push(context, new MaterialPageRoute(builder: (context) => new Menu(email, _config)));
    });

    if (!_ready) {
      _config.init().then(() {
        setState(() {
          _ready = true;
        });
      });
    }
  }

  /// Gets a function that can be called to sign in with the given [OAuthLoginMethod].
  Function() _oauthSignIn(OAuthLoginMethod method) {
    return (){
      method().then((result) {
        if (result.resultType == SignInResultType.INCORRECT_METHOD) {
          _scaffold.currentState.showSnackBar(new SnackBar(content: new Text("Email was originally registered with a different sign-in method.")));
        }
        else if (result.resultType == SignInResultType.FAILURE) {
          _scaffold.currentState.showSnackBar(new SnackBar(content: new Text("Registration failed.")));
        }
        else {
          Navigator.push(context, new MaterialPageRoute(builder: (context) => new Menu(result.email, _config)));
        }
      });
    };
  }

  /// Opens the email sign-in page.
  void _emailSignIn() {
    Navigator.push(context, new MaterialPageRoute(builder: (context) => new EmailSignInPage(_config, _signIn)));
  }

  /// Opens the email sign-up page.
  void _emailSignUp() {
    Navigator.push(context, new MaterialPageRoute(builder: (context) => new SignUpPage(_config, _signIn)));
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
                        new SignInButton(Buttons.GoogleDark, onPressed: _googleSignInFunc ?? _oauthSignIn(_signIn.googleSignIn)),
                        new SignInButton(Buttons.Facebook, onPressed: _facebookSignInFunc ?? _oauthSignIn(_signIn.facebookSignIn)),
                        new SignInButton(Buttons.Email, onPressed: _emailSignInFunc ?? _emailSignIn),
                        new Container(
                          margin: new EdgeInsets.fromLTRB(0.0, _config.getValue("form_submit_margin"), 0.0, 0.0),
                          child: new RaisedButton(
                            color: new Color(int.parse(_config.getValue("form_button_background"), radix: 16)),
                            child: new Text("Sign Up"),
                            onPressed: _emailSignUpFunc ?? _emailSignUp,
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
