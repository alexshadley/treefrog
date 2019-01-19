import 'dart:convert';

import 'package:crypto/crypto.dart';

bool isValidEmail(String email) {
  var exp = new RegExp(r"^[a-z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-z0-9](?:[a-z0-9-]{0,253}[a-z0-9]?)(?:\.[a-z0-9](?:[a-z0-9-]{0,253}[a-z0-9]?))+$", caseSensitive: false);
  var matches = exp.allMatches(email);
  return matches.toList().length > 0;
}

bool isValidPassword(String password) {
  return password.isNotEmpty;
}

String hash(String password) {
  var bytes = utf8.encode(password);
  var digest = sha1.convert(bytes);

  var result = "";
  for (int b in digest.bytes) {
    result += b.toRadixString(16);
  }
  return result;
}