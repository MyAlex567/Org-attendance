import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance.dart';
import '../models/attendance_history.dart';
import '../models/event.dart';
import '../models/member.dart';
import '../models/scan_result.dart';
import 'service_failure.dart';

/// Firestore reads and writes for attendance: sessions (events), recording
/// a scan or self check-in, attendance lists and the user's History.
class AttendanceService {
  final _db = FirebaseFirestore.instance;

  // ---------- Attendance sessions (Phase 5) ----------

  /// Starts a new attendance session. It is open right away, so scanning
  /// can begin immediately.
  /// Used in: TakeAttendancePage (via AttendanceProvider.createEvent)
  Future<Event> createEvent({
    required String orgId,
    required String title,
    required String venue,
    required DateTime startsAt,
    required String createdBy,
  }) async {
    final eventRef = _db.collection('orgs').doc(orgId).collection('events').doc();

    final event = Event(
      orgId: orgId,
      id: eventRef.id,
      title: title,
      venue: venue,
      startsAt: startsAt,
      isOpen: true,
      createdBy: createdBy,
    );

    await eventRef.set({
      ...event.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return event;
  }

  /// Live list of an org's sessions, newest first (for the Org Page).
  /// Used in: OrgPage, the sessions list (via AttendanceProvider.watchEvents)
  Stream<List<Event>> watchEvents(String orgId) {
    return _db
        .collection('orgs')
        .doc(orgId)
        .collection('events')
        .orderBy('startsAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _eventFromDoc(orgId, doc)).toList();
    });
  }

  /// Live data of one session, so a screen sees it close right away.
  /// Used in: AttendanceListPage, Open / Closed and the Scan QR button (via AttendanceProvider.watchEvent)
  Stream<Event> watchEvent(String orgId, String eventId) {
    return _db
        .collection('orgs')
        .doc(orgId)
        .collection('events')
        .doc(eventId)
        .snapshots()
        .map((doc) => _eventFromDoc(orgId, doc));
  }

  /// Closes a session. After this the rules block any new attendance.
  /// Used in: ScanPage, Close button (via AttendanceProvider.closeEvent)
  Future<void> closeEvent(String orgId, String eventId) {
    return _db
        .collection('orgs')
        .doc(orgId)
        .collection('events')
        .doc(eventId)
        .update({'isOpen': false});
  }

  // Firestore gives back a Timestamp; the Event model wants a DateTime, so the
  /// conversion happens here and the model never imports Firebase.
  /// Used in: watchEvents and watchEvent (above)
  Event _eventFromDoc(
    String orgId,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return Event.fromMap(orgId, doc.id, {
      ...data,
      'startsAt': (data['startsAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    });
  }

  // ---------- Attendance records (Phase 5) ----------

  /// Records one person's attendance (a QR scan, or "Mark me present").
  ///
  /// 1. Not a member of this org -> "Not a member", nothing is written.
  /// 2. Already has an attendance doc -> "Already scanned".
  /// 3. Otherwise writes the attendance doc and the History copy in one batch.
  /// Used in: ScanPage: scanning a QR code (via AttendanceProvider.scan) and Mark me present (via AttendanceProvider.markMePresent)
  Future<ScanResult> recordAttendance({
    required Event event,
    required String orgName,
    required String memberUid,
    required String scannedBy,
    required String method, // 'scan' or 'self'
  }) async {
    // A QR code from somewhere else could be any text. A "/" would be read as
    // a path, so treat anything that can't be a uid as "not a member".
    if (memberUid.isEmpty || memberUid.contains('/')) {
      return const ScanResult(ScanStatus.notMember, 'Not a member of this org');
    }

    final orgRef = _db.collection('orgs').doc(event.orgId);

    final memberDoc = await orgRef.collection('members').doc(memberUid).get();
    if (!memberDoc.exists) {
      return const ScanResult(ScanStatus.notMember, 'Not a member of this org');
    }
    final member = Member.fromMap(memberDoc.id, memberDoc.data()!);

    final attendanceRef = orgRef
        .collection('events')
        .doc(event.id)
        .collection('attendance')
        .doc(memberUid);

    final existing = await attendanceRef.get();
    if (existing.exists) {
      return ScanResult(
        ScanStatus.alreadyScanned,
        '${member.name} is already scanned',
      );
    }

    final attendance = Attendance(
      uid: memberUid,
      name: member.name,
      studentId: member.studentId,
      scannedBy: scannedBy,
      method: method,
      scannedAt: null,
    );

    final history = AttendanceHistory(
      eventId: event.id,
      orgId: event.orgId,
      orgName: orgName,
      eventTitle: event.title,
      scannedAt: null,
    );

    final batch = _db.batch();

    batch.set(attendanceRef, {
      ...attendance.toMap(),
      'scannedAt': FieldValue.serverTimestamp(),
    });
    batch.set(
      _db
          .collection('users')
          .doc(memberUid)
          .collection('attendance')
          .doc(event.id),
      {
        ...history.toMap(),
        'scannedAt': FieldValue.serverTimestamp(),
      },
    );

    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      // Most likely the session was closed by another officer meanwhile.
      if (e.code == 'permission-denied') {
        throw const OrgFailure(
          'Could not record attendance. The session may be closed.',
        );
      }
      rethrow;
    }

    return ScanResult(ScanStatus.recorded, '${member.name} recorded');
  }

  /// Live list of who attended a session, newest first.
  /// Used in: AttendanceListPage, the attendee list (via AttendanceProvider.watchAttendance)
  Stream<List<Attendance>> watchAttendance(String orgId, String eventId) {
    return _db
        .collection('orgs')
        .doc(orgId)
        .collection('events')
        .doc(eventId)
        .collection('attendance')
        .orderBy('scannedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Attendance.fromMap(doc.id, {
          ...data,
          // Null for a moment until the server fills in the timestamp.
          'scannedAt': (data['scannedAt'] as Timestamp?)?.toDate(),
        });
      }).toList();
    });
  }

  /// Live number of attendees in a session (count cards).
  /// Used in: OrgPage session cards (officers and admin) and ScanPage count card (via AttendanceProvider.watchAttendanceCount)
  Stream<int> watchAttendanceCount(String orgId, String eventId) {
    return _db
        .collection('orgs')
        .doc(orgId)
        .collection('events')
        .doc(eventId)
        .collection('attendance')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  /// Live true/false: is this user already marked present in the session?
  /// Used in: ScanPage, the Mark me present button (via AttendanceProvider.watchHasAttended)
  Stream<bool> watchHasAttended(String orgId, String eventId, String uid) {
    return _db
        .collection('orgs')
        .doc(orgId)
        .collection('events')
        .doc(eventId)
        .collection('attendance')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Live list of the events this user attended, newest first (History).
  /// Used in: HistoryPage (via AttendanceProvider.watchHistory)
  Stream<List<AttendanceHistory>> watchHistory(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('attendance')
        .orderBy('scannedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return AttendanceHistory.fromMap(doc.id, {
          ...data,
          'scannedAt': (data['scannedAt'] as Timestamp?)?.toDate(),
        });
      }).toList();
    });
  }  
}
