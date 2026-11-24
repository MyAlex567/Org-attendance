import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/invite.dart';
import '../models/member.dart';
import '../models/membership.dart';
import '../models/org.dart';
import 'service_failure.dart';

/// Firestore reads and writes for orgs: creating and joining orgs, the
/// member list, officer invites, and removing officers or members.
class OrgService {
  final _db = FirebaseFirestore.instance;

  static const char = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  /// Makes a random 6-character join code that no other org uses yet.
  /// Used in: createOrg (below)
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

  /// Creates an org and makes the creator its admin (one batch, 4 writes).
  /// Used in: HomePage, Add organization dialog (via OrgProvider.createOrg)
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

  /// Joins an org as a member using its join code.
  /// Used in: HomePage, Join organization dialog (via OrgProvider.joinOrg)
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

  /// Live list of the orgs the user belongs to (for the home screen)
  /// Used in: HomePage, the list of my orgs (via OrgProvider.myOrgs)
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
  /// Used in: OrgPage, the admin's join code card (via OrgProvider.watchOrg)
  Stream<Org> watchOrg(String orgId) {
    return _db
        .collection('orgs')
        .doc(orgId)
        .snapshots()
        .map((doc) => Org.fromMap(doc.id, doc.data() ?? {}));
  }  

  /// Live list of an org's members, sorted by name (for the Members page).
  /// Used in: MembersPage (via OrgProvider.watchMembers)
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
  /// Used in: MembersPage, tap a member then Send invite (via OrgProvider.inviteOfficer)
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
  /// Used in: HomePage invite badge and InvitationsPage (via OrgProvider.watchInvites)
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
  /// Used in: InvitationsPage, Accept / Decline (via OrgProvider.acceptInvite and declineInvite)
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
  /// Used in: MembersPage, tap an officer then Remove (via OrgProvider.removeOfficer)
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
  /// Used in: MembersPage remove icon (via OrgProvider.removeMember) and OrgPage Leave button (via OrgProvider.leaveOrg)
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
}
