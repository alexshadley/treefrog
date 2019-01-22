import 'dart:core';

import 'package:flutter/material.dart';

import 'package:leapfrog/config.dart';
import 'package:leapfrog/views/map_page.dart';

/// A placeholder. This will be replaced with the map when it's ready, but
/// I needed somewhere to navigate to after a successful login.
class Menu extends StatefulWidget {

  final _email;
  final _config;

  /// Initializes the placeholder page.
  /// [email] is the email of the currently-signed-in user.
  Menu(String email, Config config) :
    _email = email,
    _config = config;

  /// Creates the page state.
  @override
  _MenuState createState() => new _MenuState(_config);
}

/// The state of the placeholder page.
class _MenuState extends State<Menu> {

  final _config;

  _MenuState(Config config) : _config = config;

  /// Builds the page [Widget].
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        decoration: new BoxDecoration(color: new Color(int.parse(_config.getValue("primary_color"), radix: 16))),
        child: new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                    margin: new EdgeInsets.fromLTRB(0.0, _config.getValue("form_submit_margin"), 0.0, 0.0),
                    child: new RaisedButton(
                      color: new Color(int.parse(_config.getValue("form_button_background"), radix: 16)),
                      child: new Text("Map"),
                      onPressed: () => Navigator.push(context, new MaterialPageRoute(builder: (context) => new MapPage())),
                    )
                )
              ],
            )
        )
      )
    );
  }
}