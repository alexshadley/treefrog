import 'dart:async';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

import 'config.dart';
import 'util.dart' as util;

class Api {
  final _config = new Config();
  bool _ready = false;

  Future<bool> userExists(String email) async {
    if (!_ready) {
      await _config.init();
      _ready = true;
    }

    try {
      http.Response response = await http.get("${_config.getValue("api_url")}/users/$email");
      return response.statusCode == 200;
    }
    catch (ex) {
      print(ex);
      return false;
    }
  }

  Future<String> correctPassword(String email, String password) async {
    password = util.hash(password);
    try {
      String response = await http.read("${_config.getValue("api_url")}/users/$email");
      dynamic data = convert.jsonDecode(response);
      if (password == data['password_hash'])
        return "";
      else
        return "password";
    }
    catch(Exception) {
      return "email";
    }
  }

  Future<bool> registerUser(String email, String displayName, [String password]) async {
    Map body;
    if (password != null) {
      password = util.hash(password);
      body = { 'email': email, 'display_name': displayName, 'password_hash': password };
    }
    else {
      body = { 'email': email, 'display_name': displayName };
    }

    try {
      http.Response response = await http.post("${_config.getValue("api_url")}/users/", body: body);

      return response.statusCode == 201;
    }
    catch (ex) {
      print(ex.toString());
      return false;
    }
  }
}