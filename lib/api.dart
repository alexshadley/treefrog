import 'dart:async';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

import 'config.dart';
import 'registration_result.dart';
import 'user.dart';
import 'util.dart' as util;

class Api {
  final _config = new Config();
  bool _ready = false;

  Future<User> getUser(String email) async {
    if (!_ready) {
      await _config.init();
      _ready = true;
    }

    http.Response response = await http.get("${_config.getValue("api_url")}/users/$email");
    if (response.statusCode != 200) {
      return null;
    }
    else {
      Map body = convert.jsonDecode(convert.utf8.decode(response.bodyBytes.toList()));
      return new User(body['email'], body['display_name'], body['password_hash'], body['leapfrog_id'], body['method']);
    }
  }

  Future<RegistrationResult> registerUser(String email, String displayName, String method, [String password]) async {
    Map body;
    if (!_ready) {
      await _config.init();
      _ready = true;
    }

    if (password != null && password.isNotEmpty) {
      password = util.hash(password);
      body = { 'email': email, 'display_name': displayName, 'password_hash': password, 'method': method };
    }
    else {
      body = { 'email': email, 'display_name': displayName, 'method': method };
    }

    http.Response response = await http.post("${_config.getValue("api_url")}/users/", body: body);
    print(response.statusCode);

    if (response.statusCode == 201)
      return RegistrationResult.SUCCESS;
    else if(response.statusCode == 400)
      return RegistrationResult.DUPLICATE_EMAIL;
    else
      return RegistrationResult.FAILURE;
  }
}