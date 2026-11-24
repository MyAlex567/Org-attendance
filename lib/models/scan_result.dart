/// What happened after one QR scan or "Mark me present".
enum ScanStatus { recorded, notMember, alreadyScanned, error }

/// The result shown in the card under the camera on the Scan QR screen.
class ScanResult {
  final ScanStatus status;
  final String message; // e.g. "Juan Dela Cruz recorded"

  const ScanResult(this.status, this.message);

  /// Only a new record gets the green card; everything else is gray.
  bool get isSuccess => status == ScanStatus.recorded;
}
