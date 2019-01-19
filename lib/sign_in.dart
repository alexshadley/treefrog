import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';

import 'api.dart';
import 'config.dart';
import 'registration_result.dart';
import 'signin_method.dart' as signInMethod;
import 'signin_result.dart';
import 'user.dart';
import 'util.dart' as util;

typedef Future<SignInResult> LoginMethod();

class SignIn {
  final Api api = new Api();
  final Config _config = new Config();
  bool _ready = false;

  Future<SignInResult> googleSignIn() async {
    if(!_ready)
      await _config.init();

    GoogleSignIn _googleSignIn = new GoogleSignIn(
        scopes: ['email']
    );
    GoogleSignInAccount user = await _googleSignIn.signIn();
    return await _loginWithApi(user.email, user.displayName, "Google", true);
  }

  Future<SignInResult> facebookSignIn() async {
    if (!_ready)
      await _config.init();

    var result = await new FacebookLogin().logInWithReadPermissions(['email']);

    if (result.status == FacebookLoginStatus.loggedIn) {
      http.Response response = await http.get(
          "${_config.getValue("facebook_url")}/${result.accessToken
              .userId}?fields=name,email&access_token=${result.accessToken
              .token}");
      Map data = convert.jsonDecode(response.body);
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
    File file = new File("${(await getApplicationDocumentsDirectory()).path}/login.json");
    await file.create(recursive: true);

    var contents = { "email": email, "password": password, "time": new DateTime.now().millisecondsSinceEpoch };

    file.writeAsString(convert.jsonEncode(contents));
  }

  Future<SignInResult> _loginWithApi(String email, String displayName, String method, bool tryRegister, [String password]) async {
    if (password == null)
      password = "";
    else
      password = util.hash(password);

    User user = await api.getUser(email);

    if (user != null && method.toUpperCase() == signInMethod.name(user.method) && password == user.passwordHash) {
      _cacheLogin(email, "");
      return SignInResult.SUCCESS;
    }
    else if (user != null && method.toUpperCase() != signInMethod.name(user.method))
      return SignInResult.INCORRECT_METHOD;
    else if (user != null) {
      print(password);
      print(user.passwordHash);
      return SignInResult.INCORRECT_PASSWORD;
    }
    else if (tryRegister) {
      RegistrationResult result = await api.registerUser(email, displayName, method, password);
      if (result == RegistrationResult.SUCCESS) {
        _cacheLogin(email, "");
        return SignInResult.SUCCESS;
      }
      else {
        return SignInResult.FAILURE;
      }
    }
    else
      return SignInResult.NONEXISTENT_USER;
  }
}