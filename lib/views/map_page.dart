import 'dart:core';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  @override
  _MapState createState() => new _MapState();
}

class _MapState extends State<MapPage> {

  var mapController;

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new GoogleMap(onMapCreated: _onMapCreated)
    );
  }
}