import 'dart:core';

import 'package:flutter/material.dart';

import 'package:leapfrog/config.dart';
import 'package:leapfrog/models/models.dart';
import 'package:leapfrog/sign_in.dart';
import 'package:leapfrog/util.dart';
import 'package:leapfrog/views/menu.dart';

/// A page allowing the user to sign in using an email and password.
class EmailSignInPage extends StatefulWidget {
  final _config;
  final _signIn;

  /// Initializes the page.
  /// [config] **must** have had its `init()` method called prior to this.
  EmailSignInPage(Config config, SignIn signIn) :
    _config = config,
    _signIn = signIn;

  /// Creates the page state.
  @override
  _EmailSignInPageState createState() => new _EmailSignInPageState(_config, _signIn);
}

/// The state of the email sign-in page.
class _EmailSignInPageState extends State<EmailSignInPage> {
  final _config;
  final _signIn;
  final _scaffold = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _emailController = new TextEditingController();
  final _passwordController = new TextEditingController();

  /// Initializes the state.
  /// [config] **must** have had its `init()` method called prior to this.
  _EmailSignInPageState(Config config, SignIn signIn) :
    _config = config,
    _signIn = signIn;

  /// Deletes the text input controllers.
  @override
  void dispose() {
    super.dispose();

    _emailController.dispose();
    _passwordController.dispose();
  }

  /// Builds the page [Widget].
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffold,
      body: new Container(
        decoration: new BoxDecoration(
            color: new Color(int.parse(_config.getValue("primary_color"), radix: 16))
        ),
        child: new Form(
          key: _formKey,
            child: new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Container(
                      width: 200.0,
                      child: new TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: new InputDecoration(
                          labelText: "Email",
                        ),
                        validator: (text) {
                          if (!isValidEmail(text))
                            return "Please enter a valid email address.";
                        },
                      )
                  ),
                  new Container(
                      width: 200.0,
                      child: new TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: new InputDecoration(
                          labelText: "Password",
                        ),
                        validator: (text) {
                          if (!isValidPassword(text))
                            return "Please enter a valid password.";
                        },
                      )
                  ),
                  new Container(
                    margin: new EdgeInsets.fromLTRB(0.0, _config.getValue("form_submit_margin"), 0.0, 0.0),
                    child: new RaisedButton(
                      color: new Color(int.parse(_config.getValue("form_button_background"), radix: 16)),
                      child: new Text("Login"),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _signIn.emailSignIn(_emailController.text, _passwordController.text)
                          .then((result) {
                            if (result.resultType == SignInResultType.SIGNED_IN)
                              Navigator.push(context, new MaterialPageRoute(builder: (context) => new Menu(result.email, _config)));
                            else if (result.resultType == SignInResultType.NONEXISTENT_USER || result.resultType == SignInResultType.INCORRECT_PASSWORD)
                              _scaffold.currentState.showSnackBar(new SnackBar(content: new Text("Email or password was incorrect.")));
                            else if (result.resultType == SignInResultType.INCORRECT_METHOD)
                              _scaffold.currentState.showSnackBar(new SnackBar(content: new Text("Email already exists with a different sign-in method.")));
                            else
                              _scaffold.currentState.showSnackBar(new SnackBar(content: new Text("Sign-in failed.")));
                          });
                        }
                      }
                    )
                  )
                ],
              )
            )
        )
      )
    );
  }
}
