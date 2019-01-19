import 'dart:core';

import 'package:flutter/material.dart';

import 'package:leapfrog/views/sign_in_page.dart';

void main() => runApp(new LeapfrogApp());

class LeapfrogApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new LoginPage(),
    );
  }
}