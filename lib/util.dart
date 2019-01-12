import 'package:crypto/crypto.dart';
import 'dart:convert';

bool isValidEmail(String email) {
  RegExp exp = new RegExp(r"^[a-z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-z0-9](?:[a-z0-9-]{0,253}[a-z0-9]?)(?:\.[a-z0-9](?:[a-z0-9-]{0,253}[a-z0-9]?))+$", caseSensitive: false);
  Iterable<Match> matches = exp.allMatches(email);
  return matches.toList().length > 0;
}

bool isValidPassword(String password) {
  return password.isNotEmpty;
}

String hash(String password) {
  var bytes = utf8.encode(password);
  var digest = sha256.convert(bytes);

  return utf8.decode(digest.bytes);
}