class Member {
  final String uid; // document ID
  final String name;
  final String studentId;
  final String role; // 'admin', 'officer' or 'member'
  final String? joinCode; // null for the admin, who created the org instead of joining

  const Member({
    required this.uid,
    required this.name,
    required this.studentId,
    required this.role,
    required this.joinCode,
  });

  bool get isAdmin => role == 'admin';

  /// Officers and the admin can take attendance (CLAUDE.md roles table).
  bool get canTakeAttendance => role == 'admin' || role == 'officer';

  factory Member.fromMap(String uid, Map<String, dynamic> map) {
    return Member(
      uid: uid,
      name: map['name'] ?? '',
      studentId: map['studentId'] ?? '',
      // Default to the role with the least access if the field is missing.
      role: map['role'] ?? 'member',
      joinCode: map['joinCode'],
    );
  }

  /// The fields saved to Firestore. uid is the document ID, and joinedAt is
  /// added by OrgService with a server timestamp.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'studentId': studentId,
      'role': role,
      if (joinCode != null) 'joinCode': joinCode,
    };
  }
}
