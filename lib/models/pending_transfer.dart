/// Model representing a pending transfer in the database.  Note that `id` is
/// the data built into the confirmation barcode
class PendingTransfer {
  final String id;
  final Map<String, double> position;

  PendingTransfer(String transferCode, Map<String, double> position) :
    this.id = transferCode,
    this.position = position;
}