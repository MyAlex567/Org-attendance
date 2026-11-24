/// One org the user belongs to, stored at users/{uid}/memberships/{orgId}.
/// A copy for the Home list; the real role is in orgs/{orgId}/members/{uid}.
class Membership {
  final String orgId; // document ID
  final String orgName;
  final String role; // 'admin', 'officer' or 'member'

  const Membership({
    required this.orgId,
    required this.orgName,
    required this.role,
  });

  factory Membership.fromMap(String orgId, Map<String, dynamic> map) {
    return Membership(
      orgId: orgId,
      orgName: map['orgName'] ?? '',
      // Default to the role with the least access if the field is missing.
      role: map['role'] ?? 'member',
    );
  }

  /// The fields saved to Firestore. orgId is the document ID, and joinedAt is
  /// added by OrgService with a server timestamp.
  Map<String, dynamic> toMap() {
    return {
      'orgName': orgName,
      'role': role,
    };
  }
}
