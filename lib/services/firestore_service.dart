import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import 'dart:math';
import '../models/member.dart';
import '../models/membership.dart';
import '../models/org.dart';
import '../models/invite.dart';
import '../models/event.dart';
import '../models/attendance.dart';
import '../models/attendance_history.dart';
import '../models/scan_result.dart';

class OrgFailure implements Exception{
  final String message;
  const OrgFailure(this.message);
}

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> createUser(AppUser user){
    final data = user.toMap();

    data['createdAt'] = FieldValue.serverTimestamp();
    return _db.collection('users').doc(user.uid).set(data);
  }

  Future<AppUser> getUser(String uid) async{
    final doc = await _db.collection('users').doc(uid).get();

    return AppUser.fromMap(doc.id, doc.data() ?? {});
  }

  static const char = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  Future<String> _generateJoinCode() async {
    final random = Random();

    while(true){
      final code = List.generate(6,
        (index) => char[random.nextInt(char.length)],
      ).join();

      final doc = await _db.collection('joinCodes').doc(code).get();

      if(!doc.exists) return code; 
    }

  }

  Future<Org> createOrg(String name, AppUser creator) async{
    final code = await _generateJoinCode();
    final orgRef = _db.collection('orgs').doc();


    final org = Org(
      id: orgRef.id,
      name: name,
      joinCode: code,
      createdBy: creator.uid,
    );

    final member = Member(
      uid: creator.uid, 
      name: creator.fullName, 
      studentId: creator.studentId, 
      role: 'admin', 
      joinCode: null
    );

    final membership = Membership(orgId: orgRef.id, orgName: name, role: 'admin');

    // Batch is like a transaction in MySQL
    final batch = _db.batch();

    // Create the Organization Collection
    batch.set(orgRef, {
      ...org.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Creates the Sub Collection of members inside the collection of organization
    batch.set(orgRef.collection('members').doc(creator.uid), {
      ...member.toMap(),
      'joinedAt': FieldValue.serverTimestamp(),
    });

    // Creates the sub Collection of membership inside the collection of users
    batch.set(_db.collection('users').doc(creator.uid).collection('memberships').doc(org.id), {
      ...membership.toMap(),
      'joinedAt': FieldValue.serverTimestamp(),
    });

    batch.set(_db.collection('joinCodes').doc(code),{
      'orgId': org.id,
      'orgName': name
    });

    await batch.commit();

    return org;
  }

  Future<void> joinOrg(String joinCode, AppUser user) async {
    final code = joinCode.trim().toUpperCase();

    final codeDoc = await _db.collection('joinCodes').doc(code).get();
    if(!codeDoc.exists){
      throw const OrgFailure('Join code does not exist, please make sure the join code is correct');
    }

    final orgId = codeDoc.data()!['orgId'] as String;
    final orgName = codeDoc.data()!['orgName'] as String;

    // path to the orgs members
    final memberRef = _db.collection('orgs').doc(orgId).collection('members').doc(user.uid);
    final memberDoc = await memberRef.get();

    // if the user already join the orgs it will throw an error
    if(memberDoc.exists){
      throw const OrgFailure('You are already a member of this organization.');
    }

    final member = Member(
      uid: user.uid, 
      name: user.fullName, 
      studentId: user.studentId, 
      role: 'member', 
      joinCode: code
    );

    final membership = Membership(orgId: orgId, orgName: orgName, role: 'member');

    final batch = _db.batch();

    batch.set(memberRef, {
      ...member.toMap(),
      'joinedAt': FieldValue.serverTimestamp(),
    });

    batch.set(_db.collection('users').doc(user.uid).collection('memberships').doc(orgId), {
      ...membership.toMap(),
      'joinedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // Live list of the orgs the user belongs to (for the home screen)
  Stream<List<Membership>> watchMemberships(String uid){
    return _db
      .collection('users').doc(uid)
      .collection('memberships')
      .orderBy('joinedAt', descending: true)
      .snapshots()
      .map((snapshot){
        return snapshot.docs.map((doc) => Membership.fromMap(doc.id, doc.data())).toList();
      });
  }

  /// Live data of one org (for the Org Page).
  Stream<Org> watchOrg(String orgId) {
    return _db
        .collection('orgs')
        .doc(orgId)
        .snapshots()
        .map((doc) => Org.fromMap(doc.id, doc.data() ?? {}));
  }  

  /// Live list of an org's members, sorted by name (for the Members page).
  Stream<List<Member>> watchMembers(String orgId) {
    return _db
        .collection('orgs')
        .doc(orgId)
        .collection('members')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {

        return snapshot.docs
            .map((doc) => Member.fromMap(doc.id, doc.data()))
            .toList();
    });
  }  

  /// The admin invites a member to become an officer. The invite is stored
  /// under the member's own user document, where they can read it.
  Future<void> inviteOfficer(
    String orgId,
    String orgName,
    String adminUid,
    String memberUid,
  ) async {
    final invite = Invite(orgId: orgId, orgName: orgName, invitedBy: adminUid);

    try {
      await _db
          .collection('users')
          .doc(memberUid)
          .collection('invites')
          .doc(orgId)
          .set({
        ...invite.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      // The rules reject a second invite while the first is still pending.
      if (e.code == 'permission-denied') {
        throw const OrgFailure(
          'This member may already have a pending invite.',
        );
      }
      rethrow;
    }
  }

  /// Live list of the officer invites waiting for this user.
  Stream<List<Invite>> watchInvites(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('invites')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Invite.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// Accept turns the member into an officer in both places and deletes the
  /// invite (one batch). Decline only deletes the invite.
  Future<void> respondToInvite(
    String orgId,
    String uid, {
    required bool accept,
  }) async {
    final inviteRef =
        _db.collection('users').doc(uid).collection('invites').doc(orgId);

    if (!accept) {
      await inviteRef.delete();
      return;
    }

    final batch = _db.batch();

    // update (not set) changes only the role and keeps name, studentId, etc.
    batch.update(
      _db.collection('orgs').doc(orgId).collection('members').doc(uid),
      {'role': 'officer'},
    );
    batch.update(
      _db.collection('users').doc(uid).collection('memberships').doc(orgId),
      {'role': 'officer'},
    );
    batch.delete(inviteRef);

    await batch.commit();
  }

  /// The admin sets an officer back to a normal member in both places.
  Future<void> removeOfficer(String orgId, String memberUid) async {
    final batch = _db.batch();

    batch.update(
      _db.collection('orgs').doc(orgId).collection('members').doc(memberUid),
      {'role': 'member'},
    );
    batch.update(
      _db
          .collection('users')
          .doc(memberUid)
          .collection('memberships')
          .doc(orgId),
      {'role': 'member'},
    );

    await batch.commit();
  }

  /// The admin removes someone from the org (never the admin; the rules block
  /// that). Their past attendance and History stay, because the rules make
  /// attendance records permanent.
  Future<void> removeMember(String orgId, String memberUid) async {
    final userRef = _db.collection('users').doc(memberUid);
    final batch = _db.batch();

    batch.delete(
      _db.collection('orgs').doc(orgId).collection('members').doc(memberUid),
    );
    // The Home copy, so the org disappears from their list.
    batch.delete(userRef.collection('memberships').doc(orgId));
    // A pending officer invite would be useless now. Deleting a document that
    // doesn't exist is fine, so we don't need to check first.
    batch.delete(userRef.collection('invites').doc(orgId));

    await batch.commit();
  }

  // ---------- Attendance sessions (Phase 5) ----------

  /// Starts a new attendance session. It is open right away, so scanning
  /// can begin immediately.
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
  Future<void> closeEvent(String orgId, String eventId) {
    return _db
        .collection('orgs')
        .doc(orgId)
        .collection('events')
        .doc(eventId)
        .update({'isOpen': false});
  }

  // Firestore gives back a Timestamp; the Event model wants a DateTime, so the
  // conversion happens here and the model never imports Firebase.
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