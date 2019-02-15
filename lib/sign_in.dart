import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';

import 'package:leapfrog/api.dart';
import 'package:leapfrog/config.dart';
import 'package:leapfrog/models/sign_in_method.dart' as signInMethod;
import 'package:leapfrog/models/sign_in_result.dart';
import 'package:leapfrog/models/user.dart';
import 'package:leapfrog/util.dart' as util;

/// A type corresponding to any function that performs OAuth login.
typedef Future<SignInResult> OAuthLoginMethod();

/// Performs various tasks related to signing a user into the app.
class SignIn {
  final _api = new Api();
  final _config = new Config();

  /// Indicates whether `init()` has been called on [_config].
  var _ready = false;

  /// Calls Google's OAuth flow to sign in.
  Future<SignInResult> googleSignIn() async {
    if(!_ready) {
      await _config.init();
      _ready = true;
    }

    var _googleSignIn = new GoogleSignIn(
        scopes: ['email']
    );
    var user = await _googleSignIn.signIn();
    var resultType = await _loginWithApi(user.email, user.displayName, "Google", true);
    return new SignInResult(resultType, user.email);
  }

  /// Calls Facebook's OAuth flow to sign in.
  Future<SignInResult> facebookSignIn() async {
    if (!_ready) {
      await _config.init();
      _ready = true;
    }

    var result = await new FacebookLogin().logInWithReadPermissions(['email']);

    if (result.status == FacebookLoginStatus.loggedIn) {
      var response = await http.get(
          "${_config.getValue("facebook_url")}/${result.accessToken
              .userId}?fields=name,email&access_token=${result.accessToken
              .token}");
      var data = convert.jsonDecode(response.body);
      var resultType = await _loginWithApi(data['email'], data['name'], "Facebook", true);
      return new SignInResult(resultType, data['email']);
    }
    else {
      return new SignInResult(SignInResultType.FAILURE, "");
    }
  }

  /// Signs in with an [email] and [password].
  Future<SignInResult> emailSignIn(String email, String password) async {
    var resultType = await _loginWithApi(email, null, "Email", false, password);
    return new SignInResult(resultType, email);
  }

  /// Checks whether a login is currently cached.
  /// This will return the user's email if a user has signed in more recently
  /// than the millisecond value of `login_timeout` in config.json.
  /// Otherwise, it will return an empty string.
  Future<String> checkCache() async {
    if (!_ready) {
      await _config.init();
      _ready = true;
    }

    var file = new File("${(await getApplicationDocumentsDirectory()).path}/login.json");

    if (await file.exists()) {
      file.open();
      var contents = convert.jsonDecode(await file.readAsString());
      if (new DateTime.now().millisecondsSinceEpoch - contents["time"] < int.parse(_config.getValue('login_timeout'))) {
        _cacheLogin(contents["email"]);
        return contents["email"];
      }
    }
    return "";
  }

  /// Saves a login to persistent storage. This allows the user to enter the
  /// app the next time without signing in again.
  void _cacheLogin(String email) async {
    if (!_ready) {
      await _config.init();
      _ready = true;
    }

    var file = new File("${(await getApplicationDocumentsDirectory()).path}/login.json");
    await file.create(recursive: true);

    var contents = { "email": email, "time": new DateTime.now().millisecondsSinceEpoch };

    file.writeAsString(convert.jsonEncode(contents));
  }

  /// Calls the API to sign the user in. [tryRegister] indicates whether it should
  /// try to register the user in the event that no user exists with [email].
  ///
  /// See [SignInResultType] for documentation on the return values.
  Future<SignInResultType> _loginWithApi(String email, String displayName, String method, bool tryRegister, [String password]) async {
    if (password == null)
      password = "";
    else
      password = util.hash(password);

    var user = await _api.getUser(email);

    if (user != null && method.toUpperCase() == signInMethod.name(user.method) && password == user.passwordHash) {
      _cacheLogin(email);
      return SignInResultType.SIGNED_IN;
    }
    else if (user != null && method.toUpperCase() != signInMethod.name(user.method)) {
      return SignInResultType.INCORRECT_METHOD;
    }
    else if (user != null) {
      return SignInResultType.INCORRECT_PASSWORD;
    }
    else if (tryRegister) {
      var result = await _api.registerUser(email, displayName, method, password);
      if (result == SignInResultType.CREATED) {
        _cacheLogin(email);
        return SignInResultType.CREATED;
      }
      else {
        return result;
      }
    }
    else {
      return SignInResultType.NONEXISTENT_USER;
    }
  }
}