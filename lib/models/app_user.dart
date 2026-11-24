class AppUser {
  final String uid;
  final String fullName;
  final String studentId;
  final String email;

  const AppUser({
    required this.uid,
    required this.fullName,
    required this.studentId,
    required this.email,
  });

  /// Builds an AppUser from a Firestore document. The uid is the document ID,
  /// not a field inside the document.
  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      fullName: map['fullName'] ?? '',
      studentId: map['studentId'] ?? '',
      email: map['email'] ?? '',
    );
  }

  /// The fields saved to Firestore. uid is the document ID, and createdAt is
  /// added by FirestoreService with a server timestamp.
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'studentId': studentId,
      'email': email,
    };
  }
}
