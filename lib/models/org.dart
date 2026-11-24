/// An organization, stored in Firestore at orgs/{orgId}.
class Org {
  final String id;
  final String name;
  final String joinCode; // 6 characters, e.g. "K7M2QX"
  final String createdBy; // uid of the user who created it (its admin)

  const Org({
    required this.id,
    required this.name,
    required this.joinCode,
    required this.createdBy,
  });

  /// Builds an Org from a Firestore document. The id is the document ID.
  factory Org.fromMap(String id, Map<String, dynamic> map) {
    return Org(
      id: id,
      name: map['name'] ?? '',
      joinCode: map['joinCode'] ?? '',
      createdBy: map['createdBy'] ?? '',
    );
  }

  /// The fields saved to Firestore. id is the document ID, and createdAt is
  /// added by OrgService with a server timestamp.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'joinCode': joinCode,
      'createdBy': createdBy,
    };
  }
}
