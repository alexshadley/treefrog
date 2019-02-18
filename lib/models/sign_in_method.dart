/// Allowable methods for user sign-in.
enum SignInMethod {
  GOOGLE,
  FACEBOOK,
  EMAIL
}

/// Gets a string representation of the name of a sign-in method.
/// For example, for name(SignInMethod.Google) == "Google".
String name(SignInMethod m) {
  var s = m.toString();
  return s.substring(s.indexOf('.') + 1);
}