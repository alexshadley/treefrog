import 'dart:async';
import 'dart:convert' as convert;
import 'dart:core';

import 'package:http/http.dart' as http;

import 'package:leapfrog/config.dart';
import 'package:leapfrog/models/confirmation_result.dart';
import 'package:leapfrog/models/pending_transfer.dart';
import 'package:leapfrog/models/sign_in_result.dart';
import 'package:leapfrog/models/transfer.dart';
import 'package:leapfrog/models/user.dart';
import 'package:leapfrog/util.dart' as util;

/// Interfaces with the app's backend API.
class Api {
  final _config = new Config();

  var _ready = false;

  /// Gets a user from the API. This returns a [User] if a user exists with the
  /// given [email]; otherwise, it returns `null`.
  Future<User> getUser(String email) async {
    if (!_ready) {
      await _config.init();
      _ready = true;
    }

    var response = await http.get("${_config.getValue("api_url")}/users/$email");
    if (response.statusCode != 200) {
      return null;
    }
    else {
      var body = convert.jsonDecode(convert.utf8.decode(response.bodyBytes.toList()));
      return new User(body['email'], body['leapfrog_id'], body['display_name'], body['password_hash'], body['method']);
    }
  }

  /// Creates a user in the backend database. [password] should only be used if
  /// the user is being created using the `Email` sign-in method.
  /// This will return the appropriate [RegistrationResult] for the situation
  /// encountered.
  Future<SignInResultType> registerUser(String email, String displayName, String method, [String password]) async {
    if (!_ready) {
      await _config.init();
      _ready = true;
    }

    var body;

    if (password != null && password.isNotEmpty) {
      password = util.hash(password);
      body = { 'email': email, 'display_name': displayName, 'password_hash': password, 'method': method };
    }
    else {
      body = { 'email': email, 'display_name': displayName, 'method': method };
    }

    var url = _config.getValue("api_url");
    var response = await http.post("${_config.getValue("api_url")}/users/", body: body);

    if (response.statusCode == 201)
      return SignInResultType.CREATED;
    else if(response.statusCode == 400)
      return SignInResultType.DUPLICATE_EMAIL;
    else
      return SignInResultType.FAILURE;
  }

  /// Creates a new pending transfer in the database
  Future<PendingTransfer> initiateTransfer(String email, Map<String, double> position) async {
    if (!_ready) {
      await _config.init();
      _ready = true;
    }

    var body = 
      {
        'email': email,
        'latitude': position['latitude'].toString(),
        'longitude': position['longitude'].toString()
      };

    var response = await http.post("${_config.getValue("api_url")}/pendingtransfers/", body: body);
    
    if (response.statusCode == 201) {
      var responseJson = convert.jsonDecode(convert.utf8.decode(response.bodyBytes.toList()));
      Map<String, double> location = {'latitude': responseJson['latitude'], 'longitude': responseJson['longitude']};
      return PendingTransfer(responseJson['id'], location);
    }
    else {
      print('Failed with status code ${response.statusCode}');
      return null;
    }
  }

  /// Confirms a transfer created by another user
  Future<ConfirmationResult> confirmTransfer(String transferCode, String email, Map<String, double> position) async {
    if (!_ready) {
      await _config.init();
      _ready = true;
    }

    var body = 
      {
        'email': email,
        'latitude': position['latitude'].toString(),
        'longitude': position['longitude'].toString()
      };

    var response = await http.post("${_config.getValue("api_url")}/pendingtransfers/$transferCode/confirm", body: body);
    
    if (response.statusCode == 201) {
      return ConfirmationResult.SUCCESS;
    }
    else {
      return ConfirmationResult.FAILURE;
    }
  }

  /// Gets a list of transfers for the frog with ID [leapfrogId], where the first element is
  /// the leapfrog's first transfer.
  Future<List<Transfer>> getTransfersForFrog(String leapfrogId) async {
    if (!_ready) {
      await _config.init();
      _ready = true;
    }
    
    http.Response response = await http.get("${_config.getValue("api_url")}/transfers/leapfrog/$leapfrogId");

    if (response.statusCode != 200)
      return null;

    var body = convert.jsonDecode(response.body);
    var transfers = new List<Transfer>();
    for (var i = 0; i < body.length; i++) {
      transfers.add(Transfer.fromJson(body[i]));
    }

    return transfers;
  }

  /// Gets all leapfrogs that the user with email [email] has held.
  /// These are in no particular order.
  Future<List<String>> getLeapfrogsForUser(String email) async {
    if (!_ready) {
      await _config.init();
      _ready = true;
    }

    http.Response response = await http.get("${_config.getValue("api_url")}/users/leapfrogs/$email");

    if (response.statusCode != 200)
      return null;

    var data = convert.jsonDecode(response.body);
    var leapfrogs = new List<String>();

    data.forEach((d) {
      leapfrogs.add(d);
    });

    return leapfrogs;
  }
}