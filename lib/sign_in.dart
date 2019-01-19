import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';

import 'package:leapfrog/api.dart';
import 'package:leapfrog/config.dart';
import 'package:leapfrog/models/registration_result.dart';
import 'package:leapfrog/models/sign_in_method.dart' as signInMethod;
import 'package:leapfrog/models/sign_in_result.dart';
import 'package:leapfrog/util.dart' as util;

typedef Future<SignInResult> LoginMethod();

class SignIn {
  final Api api = new Api();
  final Config _config = new Config();

  var _ready = false;

  Future<SignInResult> googleSignIn() async {
    if(!_ready)
      await _config.init();

    var _googleSignIn = new GoogleSignIn(
        scopes: ['email']
    );
    var user = await _googleSignIn.signIn();
    return await _loginWithApi(user.email, user.displayName, "Google", true);
  }

  Future<SignInResult> facebookSignIn() async {
    if (!_ready)
      await _config.init();

    var result = await new FacebookLogin().logInWithReadPermissions(['email']);

    if (result.status == FacebookLoginStatus.loggedIn) {
      var response = await http.get(
          "${_config.getValue("facebook_url")}/${result.accessToken
              .userId}?fields=name,email&access_token=${result.accessToken
              .token}");
      var data = convert.jsonDecode(response.body);
      return await _loginWithApi(data['email'], data['name'], "Facebook", true);
    }
    else {
      return SignInResult.FAILURE;
    }
  }

  Future<SignInResult> emailSignIn(String email, String password) async {
    return await _loginWithApi(email, null, "Email", false, password);
  }

  void _cacheLogin(String email, String password) async {
    var file = new File("${(await getApplicationDocumentsDirectory()).path}/login.json");
    await file.create(recursive: true);

    var contents = { "email": email, "password": password, "time": new DateTime.now().millisecondsSinceEpoch };

    file.writeAsString(convert.jsonEncode(contents));
  }

  Future<SignInResult> _loginWithApi(String email, String displayName, String method, bool tryRegister, [String password]) async {
    if (password == null)
      password = "";
    else
      password = util.hash(password);

    var user = await api.getUser(email);

    if (user != null && method.toUpperCase() == signInMethod.name(user.method) && password == user.passwordHash) {
      _cacheLogin(email, "");
      return SignInResult.SUCCESS;
    }
    else if (user != null && method.toUpperCase() != signInMethod.name(user.method)) {
      return SignInResult.INCORRECT_METHOD;
    }
    else if (user != null) {
      return SignInResult.INCORRECT_PASSWORD;
    }
    else if (tryRegister) {
      var result = await api.registerUser(email, displayName, method, password);
      if (result == RegistrationResult.SUCCESS) {
        _cacheLogin(email, "");
        return SignInResult.SUCCESS;
      }
      else {
        return SignInResult.FAILURE;
      }
    }
    else {
      return SignInResult.NONEXISTENT_USER;
    }
  }
}