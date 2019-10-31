import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Compares [email] with a regex to check its validity.
bool isValidEmail(String email) {
  var exp = new RegExp(r"^[a-z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-z0-9](?:[a-z0-9-]{0,253}[a-z0-9]?)(?:\.[a-z0-9](?:[a-z0-9-]{0,253}[a-z0-9]?))+$", caseSensitive: false);
  var matches = exp.allMatches(email);
  return matches.toList().length > 0;
}

/// Checks whether [password] is valid. At the moment, this simply
/// checks if it's nonempty.
bool isValidPassword(String password) {
  return password.isNotEmpty;
}

/// Hashes a password. This right now uses a single SHA256 hash, but could be
/// made more secure in the future.
///
/// Returns the hash encoded in hexadecimal.
String hash(String password) {
  var bytes = utf8.encode(password);
  var digest = sha256.convert(bytes);

  var result = "";
  for (int b in digest.bytes) {
    result += b.toRadixString(16);
  }
  return result;
}