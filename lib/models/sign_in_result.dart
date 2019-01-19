/// Possible results of a user sign-in.
enum SignInResult {
  /// The user is allowed to sign in.
  /// This indicates that:
  /// * The user exists
  /// * The user used the correct method in signing in
  /// * The user entered the correct password, if applicable
  SUCCESS,

  /// The user attempted to sign in using the wrong method.
  /// For example, if the account was created through a Google account,
  /// the user cannot sign in later using the same email through Facebook.
  INCORRECT_METHOD,

  /// The user doesn't exist in the database.
  NONEXISTENT_USER,

  /// The user entered an incorrect password.
  /// This only applies for Email sign-ins.
  INCORRECT_PASSWORD,

  /// The sign-in attempt failed for an unknown reason.
  FAILURE
}