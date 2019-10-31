import 'dart:core';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:leapfrog/config.dart';

class QrPage extends StatefulWidget {
  final _id;
  final _config;

  QrPage(String id, Config config) :
    _id = id,
    _config = config;

  /// Creates the page state.
  @override
  _QrState createState() => new _QrState(_id, _config);
}

/// The state of the transfer page.
class _QrState extends State<QrPage> {
  final _id;
  final _config;

  _QrState(String id, Config config) :
    _id = id,
    _config = config;
  
  /// Builds the page [Widget].
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        decoration: new BoxDecoration(color: new Color(int.parse(_config.getValue("primary_color"), radix: 16))),
        child: new Center(
          child: new QrImage(
            data: _id,
            size: 300
          )
        )
      )
    );
  }
}