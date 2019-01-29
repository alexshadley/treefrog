import 'dart:core';
import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:leapfrog/config.dart';
import 'package:leapfrog/api.dart';
import 'package:leapfrog/models/pending_transfer.dart';
import 'package:leapfrog/models/confirmation_result.dart';
import 'package:leapfrog/views/qr_page.dart';

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
  final _api = Api();

  final _email;
  final _config;

  _TransferState(String email, Config config) : 
    _email = email,
    _config = config;

  void _showSuccess() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Transfer Successful"),
          content: new Text("Your leapfrog was swapped!"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showFailure() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Transfer Failed"),
          content: new Text("Your leapfrog was not swapped, try again!"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _newTransfer() async {
    var initResult = await _api.initiateTransfer(_email);
    if (initResult != null) {
      Navigator.push(context, new MaterialPageRoute(builder: (context) => new QrPage(initResult.transferCode, _config)));
    }
  }

  void _scanTransfer() async {
    var transferCode = await BarcodeScanner.scan();
    var confirmResult = await _api.confirmTransfer(transferCode, _email);
    if (confirmResult == ConfirmationResult.SUCCESS) {
      _showSuccess();
    }
    else {
      _showFailure();
    }
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