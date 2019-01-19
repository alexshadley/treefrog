import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

import 'config.dart';
import 'email_sign_up.dart';
import 'email_sign_in.dart';
import 'placeholder.dart';
import 'signin_result.dart';
import 'sign_in.dart';

void main() => runApp(new LeapfrogApp());

final Config config = new Config();
final SignIn signIn = new SignIn();

class LeapfrogApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _ready = false;
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    config.init().then((result) {
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
    Navigator.push(context, new MaterialPageRoute(builder: (context) => new EmailSignInPage(config)));
  }

  void _emailSignUp() {
    Navigator.push(context, new MaterialPageRoute(builder: (context) => new SignUpPage(config)));
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return new Scaffold();
    }

    return new Scaffold(
      key: _scaffold,
      body: new Container(
        decoration: new BoxDecoration(color: new Color(int.parse(config.getValue("primary_color"), radix: 16))),
        child: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                config.getValue("app_name"),
                style: new TextStyle(fontSize: 40.0)
              ),
              new Container(
                  margin: new EdgeInsets.only(top: 80.0),
                  child: new Column(
                      children: <Widget>[
                        SignInButton(Buttons.GoogleDark, onPressed: _oauthSignIn(signIn.googleSignIn)),
                        SignInButton(Buttons.Facebook, onPressed: _oauthSignIn(signIn.facebookSignIn)),
                        SignInButton(Buttons.Email, onPressed: _emailSignIn),
                        new Container(
                          margin: new EdgeInsets.fromLTRB(0.0, config.getValue("form_submit_margin"), 0.0, 0.0),
                          child: new RaisedButton(
                            color: new Color(int.parse(config.getValue("form_button_background"), radix: 16)),
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
