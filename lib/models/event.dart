class Event {
  final String orgId; // the org this session belongs to (part of the path)
  final String id;
  final String title;
  final String venue;
  final DateTime startsAt;
  final bool isOpen;
  final String createdBy; // uid of the officer or admin who started it

  const Event({
    required this.orgId,
    required this.id,
    required this.title,
    required this.venue,
    required this.startsAt,
    required this.isOpen,
    required this.createdBy,
  });

  /// Builds an Event from a Firestore document at orgs/{orgId}/events/{id}.
  /// Both IDs come from the path, not from fields. AttendanceService converts
  /// startsAt from a Firestore Timestamp to a DateTime before calling this,
  /// so this model doesn't need to import Firebase.
  factory Event.fromMap(String orgId, String id, Map<String, dynamic> map) {
    return Event(
      orgId: orgId,
      id: id,
      title: map['title'] ?? '',
      venue: map['venue'] ?? '',
      startsAt: map['startsAt'] as DateTime,
      // A missing value counts as closed, so nobody can scan into a broken event.
      isOpen: map['isOpen'] ?? false,
      createdBy: map['createdBy'] ?? '',
    );
  }

  /// The fields saved to Firestore. Firestore stores startsAt as a Timestamp
  /// automatically. orgId and id are in the path, and createdAt is added by
  /// AttendanceService with a server timestamp.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'venue': venue,
      'startsAt': startsAt,
      'isOpen': isOpen,
      'createdBy': createdBy,
    };
  }
}
