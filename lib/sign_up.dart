import 'package:flutter/material.dart';
import 'config.dart';
import 'util.dart';

class SignUpPage extends StatefulWidget {
  Config _config;

  SignUpPage(Config config) {
    this._config = config;
  }

  @override
  _SignUpPageState createState() => new _SignUpPageState(_config);
}

class _SignUpPageState extends State<SignUpPage> {
  Config _config;
  final _formKey = GlobalKey<FormState>();
  final controller = new TextEditingController();

  _SignUpPageState(Config config) {
    this._config = config;
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Container(
          decoration: new BoxDecoration(color: new Color(int.parse(_config.getValue("primary_color"), radix: 16))),
          child: new Center(
            child: new Form(
              key: _formKey,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Container(
                    width: 200.0,
                    child: new TextFormField(
                      decoration: new InputDecoration(
                        labelText: "First Name"
                      ),
                      validator: (text) {
                        if (text.isEmpty)
                          return "Please enter your first name.";
                      },
                    )
                  ),
                  new Container(
                    width: 200.0,
                    child: new TextFormField(
                      decoration: new InputDecoration(
                        labelText: "Last Name"
                      ),
                      validator: (text) {
                        if (text.isEmpty)
                          return "Please enter your last name.";
                      },
                    )
                  ),
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
                      controller: controller,
                      obscureText: true,
                      decoration: new InputDecoration(
                        labelText: "Password"
                      ),
                      validator: (text) {
                        if (!isValidPassword(text))
                          return "Please enter a nonempty password.";
                      },
                    )
                  ),
                  new Container(
                    width: 200.0,
                    child: new TextFormField(
                      obscureText: true,
                      decoration: new InputDecoration(
                        labelText: "Confirm Password"
                      ),
                      validator: (text) {
                        if (text != controller.text)
                          return "Passwords must match.";
                        if (!isValidPassword(text))
                          return "Please enter a nonempty password.";
                      }
                    )
                  ),
                  new Container(
                    margin: new EdgeInsets.fromLTRB(0.0, _config.getValue("form_submit_margin"), 0.0, 0.0),
                    child: new RaisedButton(
                        child: new Text("Register"),
                        color: new Color(int.parse(_config.getValue("form_button_background"), radix: 16)),
                        onPressed: () {
                          if (_formKey.currentState.validate())
                            Scaffold
                                .of(context)
                                .showSnackBar(SnackBar(content: Text('Processing Data')));
                        }
                    )
                  )
                ]
              )
            )
          ),
        )
    );
  }
}