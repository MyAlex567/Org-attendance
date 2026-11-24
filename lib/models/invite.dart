/// An officer invitation, stored at users/{uid}/invites/{orgId}.
class Invite {
  final String orgId; // document ID
  final String orgName;
  final String invitedBy; // uid of the admin who sent it

  const Invite({
    required this.orgId,
    required this.orgName,
    required this.invitedBy,
  });

  factory Invite.fromMap(String orgId, Map<String, dynamic> map) {
    return Invite(
      orgId: orgId,
      orgName: map['orgName'] ?? '',
      invitedBy: map['invitedBy'] ?? '',
    );
  }

  /// The fields saved to Firestore. orgId is the document ID, and createdAt is
  /// added by FirestoreService with a server timestamp.
  Map<String, dynamic> toMap() {
    return {
      'orgName': orgName,
      'invitedBy': invitedBy,
    };
  }
}
