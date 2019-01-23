/// Possible results of registering a user.
class InitiationResult {
  final int statusCode;
  final String transferCode;
  final Map<String, double> position;

  InitiationResult(int statusCode, String transferCode, Map<String, double> position) :
    this.statusCode = statusCode,
    this.transferCode = transferCode,
    this.position = position;

}