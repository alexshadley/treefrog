import 'dart:core';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:flutter/material.dart';

import 'package:leapfrog/api.dart';
import 'package:leapfrog/config.dart';
import 'package:leapfrog/models/models.dart';
import 'package:leapfrog/views/qr_page.dart';

class TransferMenuPage extends StatefulWidget {
  final _email;
  final _config;

  TransferMenuPage(String email, Config config) :
    _email = email,
    _config = config;

  /// Creates the page state.
  @override
  _TransferMenuState createState() => new _TransferMenuState(_email, _config);
}

/// The state of the transfer page.
class _TransferMenuState extends State<TransferMenuPage> {
  final _api;
  final location = Location();

  final _email;
  final _config;

  _TransferMenuState(String email, Config config) :
    _email = email,
    _config = config,
    _api = Api(new http.Client(), config);

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Transfer Successful"),
          content: new Text("Your leapfrog was swapped!"),
          actions: <Widget>[
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
        return AlertDialog(
          title: new Text("Transfer Failed"),
          content: new Text("Your leapfrog was not swapped, try again!"),
          actions: <Widget>[
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
    Map<String, double> pos = await location.getLocation();
    var initResult = await _api.initiateTransfer(_email, pos);
    if (initResult != null) {
      Navigator.push(context, new MaterialPageRoute(builder: (context) => new QrPage(initResult.id, _config)));
    }
  }

  void _scanTransfer() async {
    var transferCode = await BarcodeScanner.scan();
    Map<String, double> pos = await location.getLocation();
    var confirmResult = await _api.confirmTransfer(transferCode, _email, pos);
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