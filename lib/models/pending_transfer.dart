class PendingTransfer {
  final String id;
  final Map<String, double> position;

  PendingTransfer(String transferCode, Map<String, double> position) :
    this.id = transferCode,
    this.position = position;
}