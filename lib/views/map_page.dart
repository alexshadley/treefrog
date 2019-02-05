import 'dart:core';

import 'package:leapfrog/api.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  @override
  _MapState createState() => new _MapState();
}

class _MapState extends State<MapPage> {

  var mapController;

  var _api;

  void _onMapCreated(GoogleMapController controller) async {
    setState(() {
      mapController = controller;
    });

    _api = new Api();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new GoogleMap(onMapCreated: _onMapCreated)
    );
  }
}