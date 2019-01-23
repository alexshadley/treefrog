import 'dart:async';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

import 'package:leapfrog/config.dart';
import 'package:leapfrog/models/registration_result.dart';
import 'package:leapfrog/models/pending_transfer.dart';
import 'package:leapfrog/user.dart';
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
      return new User(body['email'], body['display_name'], body['password_hash'], body['leapfrog_id'], body['method']);
    }
  }

  /// Creates a user in the backend database. [password] should only be used if
  /// the user is being created using the `Email` sign-in method.
  /// This will return the appropriate [RegistrationResult] for the situation
  /// encountered.
  Future<RegistrationResult> registerUser(String email, String displayName, String method, [String password]) async {
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

    var response = await http.post("${_config.getValue("api_url")}/users/", body: body);

    if (response.statusCode == 201)
      return RegistrationResult.SUCCESS;
    else if(response.statusCode == 400)
      return RegistrationResult.DUPLICATE_EMAIL;
    else
      return RegistrationResult.FAILURE;
  }

  /// Creates a user in the backend database. [password] should only be used if
  /// the user is being created using the `Email` sign-in method.
  /// This will return the appropriate [RegistrationResult] for the situation
  /// encountered.
  Future<PendingTransfer> initiateTransfer(String email) async {
    if (!_ready) {
      await _config.init();
      _ready = true;
    }

    var body = {'email': email,
                'latitude': '42.42',
                'longitude': '13.13'};

    var response = await http.post("${_config.getValue("api_url")}/pendingtransfers/", body: body);
    
    if (response.statusCode == 201) {
      var responseJson = convert.jsonDecode(convert.utf8.decode(response.bodyBytes.toList()));
      Map<String, double> location = {'latitude': responseJson['latitude'], 'longitude': responseJson['longitude']};
      return PendingTransfer(responseJson['transfer_code'], location);
    }
    else {
      print('Failed with status code ${response.statusCode}');
      return null;
    }
  }
}