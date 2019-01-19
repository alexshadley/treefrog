import 'dart:core';

import 'package:flutter/material.dart';

import 'config.dart';
import 'placeholder.dart';
import 'sign_in.dart';
import 'signin_result.dart';
import 'util.dart';

class EmailSignInPage extends StatefulWidget {
  Config _config;

  EmailSignInPage(Config config) {
    this._config = config;
  }

  @override
  _EmailSignInPageState createState() => new _EmailSignInPageState(_config);
}

class _EmailSignInPageState extends State<EmailSignInPage> {
  Config _config;
  SignIn _signIn;

  final _scaffold = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _emailController = new TextEditingController();
  final _passwordController = new TextEditingController();

  _EmailSignInPageState(Config config) {
    this._config = config;
    this._signIn = new SignIn();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffold,
      body: new Container(
        decoration: new BoxDecoration(color: new Color(int.parse(_config.getValue("primary_color"), radix: 16))),
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
                            if (result == SignInResult.SUCCESS)
                              Navigator.push(context, new MaterialPageRoute(builder: (context) => new PlaceholderPage()));
                            else if (result == SignInResult.NONEXISTENT_USER || result == SignInResult.INCORRECT_PASSWORD)
                              _scaffold.currentState.showSnackBar(new SnackBar(content: new Text("Email or password was incorrect.")));
                            else if (result == SignInResult.INCORRECT_METHOD)
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
