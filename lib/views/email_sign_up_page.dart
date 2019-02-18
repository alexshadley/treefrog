import 'package:flutter/material.dart';

import 'package:leapfrog/config.dart';
import 'package:leapfrog/models.dart';
import 'package:leapfrog/sign_in.dart';
import 'package:leapfrog/util.dart';
import 'package:leapfrog/views/menu.dart';

/// A page where the user can sign up using an email and password.
class SignUpPage extends StatefulWidget {
  final _config;
  final _signIn;

  /// Initializes the sign up page.
  /// [config] **must** have had its `init()` method called prior to this.
  SignUpPage(Config config, SignIn signIn) :
    _config = config,
    _signIn = signIn;

  /// Creates the page state.
  @override
  _SignUpPageState createState() => new _SignUpPageState(_config, _signIn);
}

/// The state of the sign up page.
class _SignUpPageState extends State<SignUpPage> {
  final _config;
  final _signIn;
  final _scaffold = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();
  final _firstNameController = new TextEditingController();
  final _lastNameController = new TextEditingController();
  final _emailController = new TextEditingController();
  final _passwordController = new TextEditingController();

  var _uniquenessError = '';

  /// Initializes the page state.
  /// [config] **must** have had its `init()` method called prior to this.
  _SignUpPageState(Config config, SignIn signIn) :
    _config = config,
    _signIn = signIn;

  /// Initializes the page state.
  @override
  void initState() {
    super.initState();

    _emailController.addListener((){
      setState(() {
        _uniquenessError = '';
      });
    });
  }

  /// Disposes the text input controllers.
  @override
  void dispose() {
    super.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  /// Builds the page [Widget].
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffold,
      body: new Container(
        decoration: new BoxDecoration(color: new Color(int.parse(_config.getValue('primary_color'), radix: 16))),
        child: new Center(
          child: new Form(
            key: _formKey,
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                  width: 200.0,
                  child: new TextFormField(
                    controller: _firstNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: new InputDecoration(
                      labelText: 'First Name'
                    ),
                    validator: (text) {
                      if (text.isEmpty)
                        return 'Please enter your first name.';
                    },
                  )
                ),
                new Container(
                  width: 200.0,
                  child: new TextFormField(
                    controller: _lastNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: new InputDecoration(
                      labelText: 'Last Name'
                    ),
                    validator: (text) {
                      if (text.isEmpty)
                        return 'Please enter your last name.';
                    },
                  )
                ),
                new Container(
                  width: 200.0,
                  child: new TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: new InputDecoration(
                      labelText: 'Email',
                      errorText: _uniquenessError.isNotEmpty ? _uniquenessError : null
                    ),
                    validator: (text) {
                      if (!isValidEmail(text))
                        return 'Please enter a valid email address.';
                    },
                  )
                ),
                new Container(
                  width: 200.0,
                  child: new TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: new InputDecoration(
                      labelText: 'Password'
                    ),
                    validator: (text) {
                      if (!isValidPassword(text))
                        return 'Please enter a nonempty password.';
                    },
                  )
                ),
                new Container(
                  width: 200.0,
                  child: new TextFormField(
                    obscureText: true,
                    decoration: new InputDecoration(
                      labelText: 'Confirm Password'
                    ),
                    validator: (text) {
                      if (text != _passwordController.text)
                        return 'Passwords must match.';
                      if (!isValidPassword(text))
                        return 'Please enter a nonempty password.';
                    }
                  )
                ),
                new Container(
                  margin: new EdgeInsets.fromLTRB(0.0, _config.getValue('form_submit_margin'), 0.0, 0.0),
                  child: new RaisedButton(
                      child: new Text('Register'),
                      color: new Color(int.parse(_config.getValue('form_button_background'), radix: 16)),
                      onPressed: () {
                        if (_formKey.currentState.validate())
                          _signIn.emailSignUp(_emailController.text, '${_firstNameController.text} ${_lastNameController.text}', 'Email', _passwordController.text)
                          .then((result){
                            setState(() {
                              if (result == SignInResultType.CREATED) {
                                Navigator.push(context, new MaterialPageRoute(builder: (builder) => new Menu(_emailController.text, _config)));
                              }
                              else if (result == SignInResultType.DUPLICATE_EMAIL) {
                                setState(() {
                                  _uniquenessError = 'Email already belongs to an account';
                                });
                              }
                              else {
                                setState(() {
                                  _uniquenessError = '';
                                });
                                _scaffold.currentState.showSnackBar(new SnackBar(content: new Text('Registration failed.')));
                              }
                            });
                          });
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