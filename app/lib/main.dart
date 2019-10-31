import 'dart:core';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:leapfrog/api.dart';
import 'package:leapfrog/config.dart';
import 'package:leapfrog/file_factory.dart';
import 'package:leapfrog/sign_in.dart';
import 'package:leapfrog/views/sign_in_page.dart';

/// The main entry point of the app.
void main() => runApp(new LeapfrogApp());

class LeapfrogApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final config = new Config();
    return new MaterialApp(
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new SignInPage(config, new SignIn(new Api(new http.Client(), config), config, new FileFactory())),
    );
  }
}