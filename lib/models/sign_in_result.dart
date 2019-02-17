part of 'models.dart';

/// Possible results of a user sign-in.
enum SignInResultType {
  /// A new account was created for the user.
  CREATED,

  /// The user has an existing account and signed in successfully.
  SIGNED_IN,

  /// The user attempted to sign in using the wrong method.
  /// For example, if the account was created through a Google account,
  /// the user cannot sign in later using the same email through Facebook.
  INCORRECT_METHOD,

  /// The user doesn't exist in the database.
  NONEXISTENT_USER,

  /// The user entered an incorrect password.
  /// This only applies for Email sign-ins.
  INCORRECT_PASSWORD,

  /// The user tried to register, but a user with the same email already exists.
  DUPLICATE_EMAIL,

  /// The sign-in attempt failed for an unknown reason.
  FAILURE
}

class SignInResult {
  final resultType;
  final email;

  SignInResult(SignInResultType resultType, String email) :
    this.resultType = resultType,
    this.email = email;
}