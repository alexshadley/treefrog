part of 'models.dart';

/// Represents a user in the backend database.
class User {
  final email;
  final displayName;
  final passwordHash;
  final leapfrogId;
  final method;

  User(String email, String leapfrogId, String displayName, String passwordHash, String method) :
    this.email = email,
    this.displayName = displayName,
    this.passwordHash = passwordHash,
    this.leapfrogId = leapfrogId,
    this.method = SignInMethod.values.firstWhere((val) => name(val) == method.toUpperCase());
}