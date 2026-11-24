/// One event the user attended, stored at users/{uid}/attendance/{eventId}.
/// A copy for the History screen.
class AttendanceHistory {
  final String eventId; // document ID
  final String orgId;
  final String orgName;
  final String eventTitle;

  // Null for a moment right after a scan, until Firestore's server fills in
  // the serverTimestamp.
  final DateTime? scannedAt;

  const AttendanceHistory({
    required this.eventId,
    required this.orgId,
    required this.orgName,
    required this.eventTitle,
    required this.scannedAt,
  });

  /// FirestoreService converts scannedAt from a Timestamp to a DateTime
  /// (or null) before calling this.
  factory AttendanceHistory.fromMap(String eventId, Map<String, dynamic> map) {
    return AttendanceHistory(
      eventId: eventId,
      orgId: map['orgId'] ?? '',
      orgName: map['orgName'] ?? '',
      eventTitle: map['eventTitle'] ?? '',
      scannedAt: map['scannedAt'] as DateTime?,
    );
  }

  /// The fields saved to Firestore. eventId is the document ID, and scannedAt
  /// is added by FirestoreService with a server timestamp.
  Map<String, dynamic> toMap() {
    return {
      'orgId': orgId,
      'orgName': orgName,
      'eventTitle': eventTitle,
    };
  }
}
