import 'signin_method.dart';

class User {
  String email;
  String displayName;
  String passwordHash;
  String leapfrogId;
  SignInMethod method;

  User(String email, String displayName, String passwordHash, String leapfrogId, String method) {
    this.email = email;
    this.displayName = displayName;
    this.passwordHash = passwordHash;
    this.leapfrogId = leapfrogId;
    this.method = SignInMethod.values.firstWhere((val) => name(val) == method.toUpperCase());
  }
}