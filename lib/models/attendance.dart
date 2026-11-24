/// One person's attendance at a session, stored at
/// orgs/{orgId}/events/{eventId}/attendance/{uid}.
class Attendance {
  final String uid; // document ID: the attendee's Firebase uid
  final String name;
  final String studentId; // school ID number, e.g. "2023-00123"
  final String scannedBy; // who recorded it (their own uid for a self check-in)
  final String method; // 'scan' or 'self'

  // Null for a moment right after a scan, until Firestore's server fills in
  // the serverTimestamp.
  final DateTime? scannedAt;

  const Attendance({
    required this.uid,
    required this.name,
    required this.studentId,
    required this.scannedBy,
    required this.method,
    required this.scannedAt,
  });

  /// True for "Mark me present" records, shown with a "Self check-in" label.
  bool get isSelfCheckIn => method == 'self';

  /// FirestoreService converts scannedAt from a Timestamp to a DateTime
  /// (or null) before calling this.
  factory Attendance.fromMap(String uid, Map<String, dynamic> map) {
    return Attendance(
      uid: uid,
      name: map['name'] ?? '',
      studentId: map['studentId'] ?? '',
      scannedBy: map['scannedBy'] ?? '',
      method: map['method'] ?? 'scan',
      scannedAt: map['scannedAt'] as DateTime?,
    );
  }

  /// The fields saved to Firestore. scannedAt is left out because
  /// FirestoreService adds it with a server timestamp, so the time comes from
  /// Firebase, not the phone's clock.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'studentId': studentId,
      'scannedBy': scannedBy,
      'method': method,
    };
  }
}
