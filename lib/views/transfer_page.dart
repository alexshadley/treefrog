import 'dart:core';

import 'package:flutter/material.dart';
import 'package:leapfrog/config.dart';

class TransferPage extends StatefulWidget {

  final _email;
  final _config;

  TransferPage(String email, Config config) :
    _email = email,
    _config = config;

  /// Creates the page state.
  @override
  _TransferState createState() => new _TransferState(_email, _config);
}

/// The state of the transfer page.
class _TransferState extends State<TransferPage> {

  final _email;
  final _config;

  _TransferState(String email, Config config) : 
    _email = email,
    _config = config;
  
  void _newTransfer() {

  }

  void _scanTransfer() {

  }

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
                      child: new Text("New Transfer"),
                      onPressed: () => _newTransfer(),
                    )
                ),
                new Container(
                    margin: new EdgeInsets.fromLTRB(0.0, _config.getValue("form_submit_margin"), 0.0, 0.0),
                    child: new RaisedButton(
                      color: new Color(int.parse(_config.getValue("form_button_background"), radix: 16)),
                      child: new Text("Scan Transfer"),
                      onPressed: () => _scanTransfer(),
                    )
                )
              ],
            )
        )
      )
    );
  }
}