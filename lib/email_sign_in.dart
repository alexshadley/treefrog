import 'package:flutter/material.dart';
import 'dart:core';
import 'config.dart';
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
  final _formKey = GlobalKey<FormState>();

  _EmailSignInPageState(Config config) {
    this._config = config;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
                        decoration: new InputDecoration(
                            labelText: "Email"
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
                        obscureText: true,
                        decoration: new InputDecoration(
                            labelText: "Password"
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
                        _formKey.currentState.validate();
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
