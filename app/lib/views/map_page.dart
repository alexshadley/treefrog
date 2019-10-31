import 'dart:core';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as location_services;

import 'package:leapfrog/api.dart';
import 'package:leapfrog/config.dart';

class MapPage extends StatefulWidget {

  final _config;
  final _email;

  MapPage(Config config, String email) :
    _config = config,
    _email = email;


  @override
  _MapState createState() => new _MapState(_config, _email);
}

class _MapState extends State<MapPage> {

  final _api;
  final _config;
  final _email;

  var _mapController;
  var _cameraPosition;

  _MapState(Config config, String email) :
    _config = config,
    _email = email,
    _api = new Api(new http.Client(), config);


  void _onMapCreated(GoogleMapController controller) async {
    setState(() {
      _mapController = controller;
    });

    var leapfrogs = await _api.getLeapfrogsForUser(_email);
    leapfrogs.forEach((leapfrog) async {
      var transfers = await _api.getTransfersForFrog(leapfrog);
      var polyPoints = new List<LatLng>();
      transfers.forEach((transfer) {
        polyPoints.add(new LatLng(transfer.location.latitude, transfer.location.longitude));
      });

      _mapController.addPolyline(new PolylineOptions(
        points: polyPoints,
        color: int.parse('FF00B6F9', radix: 16)
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    location_services.Location().getLocation().then((location) {
      setState(() {
        _cameraPosition = new CameraPosition(target: new LatLng(location['latitude'], location['longitude']));
      });
    });

    if (_cameraPosition != null) {
      return new Scaffold(
        body: new GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: _cameraPosition)
      );
    }
    else {
      return new Scaffold(
        body: new Container(
          decoration: new BoxDecoration(color: new Color(int.parse(_config.getValue("primary_color"), radix: 16))),
        )
      );
    }
  }
}