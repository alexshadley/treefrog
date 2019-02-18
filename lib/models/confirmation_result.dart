/// Possible results of confirming a pending registration.
enum ConfirmationResult {
  /// Successful confirmation
  SUCCESS,

  /// A transfer with the given code was not found
  TRANSFER_NOT_FOUND,

  /// Confirmation failed for some unknown reason
  FAILURE
}