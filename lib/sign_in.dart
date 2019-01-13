import 'dart:convert' as convert;
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';

import 'api.dart';
import 'config.dart';

typedef Future<bool> LoginMethod();

class SignIn {
  final Api api = new Api();
  final Config _config = new Config();
  bool _ready = false;

  Future<bool> googleSignIn() async {
    if(!_ready)
      await _config.init();

    GoogleSignIn _googleSignIn = new GoogleSignIn(
        scopes: ['email']
    );
    GoogleSignInAccount user = await _googleSignIn.signIn();
    return await _loginWithApi(user.email, user.displayName);
  }

  Future<bool> facebookSignIn() async {
    if(!_ready)
      await _config.init();
    var result = await new FacebookLogin().logInWithReadPermissions(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        http.Response response = await http.get("${_config.getValue("facebook_url")}/${result.accessToken.userId}?fields=name,email&access_token=${result.accessToken.token}");
        Map data = convert.jsonDecode(response.body);
        return await _loginWithApi(data['email'], data['name']);
      default:
        return false;
    }
  }

  void _cacheLogin(String email, String password) async {
    File file = new File("${(await getApplicationDocumentsDirectory()).path}/login.json");
    await file.create(recursive: true);

    var contents = { "email": email, "password": password, "time": new DateTime.now().millisecondsSinceEpoch };

    file.writeAsString(convert.jsonEncode(contents));
  }

  Future<bool> _loginWithApi(String email, String displayName, [String password]) async {
    if (password == null)
      password = "";

    if (await api.userExists(email)) {
      _cacheLogin(email, "");
      return true;
    }
    else {
      bool created = await api.registerUser(email, displayName, password);
      if (created) {
        _cacheLogin(email, "");
        return true;
      }
      else {
        return false;
      }
    }
  }
}