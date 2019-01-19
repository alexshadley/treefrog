enum SignInMethod {
  GOOGLE,
  FACEBOOK,
  EMAIL
}

String name(SignInMethod m) {
  String s = m.toString();
  return s.substring(s.indexOf('.') + 1);
}