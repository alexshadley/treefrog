import 'dart:core';

import 'package:flutter/material.dart';
import 'package:leapfrog/views/transfer_page.dart';

/// A placeholder. This will be replaced with the map when it's ready, but
/// I needed somewhere to navigate to after a successful login.
class PlaceholderPage extends StatefulWidget {

  final _email;

  /// Initializes the placeholder page.
  /// [email] is the email of the currently-signed-in user.
  PlaceholderPage(String email) : _email = email;

  /// Creates the page state.
  @override
  _PlaceholderPageState createState() => new _PlaceholderPageState();
}


/// The state of the placeholder page.
class _PlaceholderPageState extends State<PlaceholderPage> {

  void _OpenTransfer() {
    Navigator.push(context, new MaterialPageRoute(builder: (context) => new TransferPage()));
  }

  /// Builds the page [Widget].
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        child: new Center(
          child: new RaisedButton(
            onPressed: _OpenTransfer,
            child: new Text("Transfer")
          )
        )
      )
    );
  }
}