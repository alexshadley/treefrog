import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'package:leapfrog/config.dart';
import 'package:leapfrog/sign_up.dart';
import 'package:leapfrog/email_sign_in.dart';
import 'package:leapfrog/api.dart';

void main() => runApp(new LeapfrogApp());

final config = new Config();
final api = new Api();

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

  void _googleSignIn() async {
    GoogleSignIn _googleSignIn = new GoogleSignIn(
      scopes: ['email']
    );
    GoogleSignInAccount user = await _googleSignIn.signIn();
    if (await api.userExists(user.email)) {
      print('User exists');
    }
    else {
      bool created = await api.registerUser(user.email, user.displayName);
      if (created) {
        //cache login
        print('User created');
      }
      else {
        _scaffold.currentState.showSnackBar(new SnackBar(content: new Text("Registration failed.")));
      }
    }
  }

  void _facebookSignIn() async {
    var result = await new FacebookLogin().logInWithReadPermissions(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        print('asdfjkl');
        break;
      default:
        print('lkjhgfdsa');
    }
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
                        SignInButton(Buttons.GoogleDark, onPressed: _googleSignIn),
                        SignInButton(Buttons.Facebook, onPressed: _facebookSignIn),
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
