class PendingTransfer {
  final String transferCode;
  final Map<String, double> position;

  PendingTransfer(String transferCode, Map<String, double> position) :
    this.transferCode = transferCode,
    this.position = position;
}