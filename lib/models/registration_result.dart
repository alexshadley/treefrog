/// Possible results of registering a user.
enum RegistrationResult {
  /// The user is entered into the database successfully.
  SUCCESS,

  /// A user already exists with the given email.
  DUPLICATE_EMAIL,

  /// Registration failed for an unknown reason.
  FAILURE
}