import 'package:leapfrog/models/sign_in_method.dart';

/// Represents a user in the backend database.
class User {
  var email;
  var displayName;
  var passwordHash;
  var leapfrogId;
  var method;

  User(String email, String displayName, String passwordHash, String leapfrogId, String method) :
        this.email = email,
        this.displayName = displayName,
        this.passwordHash = passwordHash,
        this.leapfrogId = leapfrogId,
        this.method = SignInMethod.values.firstWhere((val) => name(val) == method.toUpperCase());
}