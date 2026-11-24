import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/invite.dart';
import '../models/member.dart';
import '../models/membership.dart';
import '../models/org.dart';
import '../services/firestore_service.dart';

class OrgProvider extends ChangeNotifier{
  final _firestoreService = FirestoreService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Org? _createdOrg;
  Org? get createdOrg => _createdOrg;

  Stream<List<Membership>> myOrgs(String uid){
    return _firestoreService.watchMemberships(uid);
  }

  Stream<Org> watchOrg(String orgId){
    return _firestoreService.watchOrg(orgId);
  }

  Future<String?> createOrg(String name, AppUser? user) async {
    if(user == null) return 'Your profile is still loading. Please try again later';

    _isLoading = true;
    notifyListeners();

    try{
      _createdOrg = await _firestoreService.createOrg(name, user);
      return null;
    } catch (e) {
      debugPrint('Create org error: $e');
      return 'Could not create the organization. Please try again';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> joinOrg(String code, AppUser? user) async {
    if(user == null) return 'Your profile is still loading. Please try again later';

    _isLoading = true;
    notifyListeners();

    try{
      await _firestoreService.joinOrg(code, user);
      return null;
    } on OrgFailure catch (e) {
      return e.message;
    } catch (e) {
      debugPrint('Join org error: $e');
      return 'Could not Join the organization. Please try again';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

  }

  /// Live list of an org's members (Members page, admin only).
  Stream<List<Member>> watchMembers(String orgId) {
    return _firestoreService.watchMembers(orgId);
  }

  /// Live list of the officer invites waiting for the user.
  Stream<List<Invite>> watchInvites(String uid) {
    return _firestoreService.watchInvites(uid);
  }

  /// The admin invites a member to become an officer.
  /// Returns null on success, or a friendly error message.
  Future<String?> inviteOfficer(
    String orgId,
    String orgName,
    AppUser? admin,
    String memberUid,
  ) {
    if (admin == null) {
      return Future.value('Your profile is still loading. Please try again later');
    }
    return _run(
      () => _firestoreService.inviteOfficer(orgId, orgName, admin.uid, memberUid),
      'Could not send the invitation. Please try again',
    );
  }

  /// The member accepts an officer invite. Returns null on success.
  Future<String?> acceptInvite(String orgId, AppUser? user) {
    if (user == null) {
      return Future.value('Your profile is still loading. Please try again later');
    }
    return _run(
      () => _firestoreService.respondToInvite(orgId, user.uid, accept: true),
      'Could not accept the invitation. Please try again',
    );
  }

  /// The member declines an officer invite. Returns null on success.
  Future<String?> declineInvite(String orgId, AppUser? user) {
    if (user == null) {
      return Future.value('Your profile is still loading. Please try again later');
    }
    return _run(
      () => _firestoreService.respondToInvite(orgId, user.uid, accept: false),
      'Could not decline the invitation. Please try again',
    );
  }

  /// The admin turns an officer back into a normal member.
  Future<String?> removeOfficer(String orgId, String memberUid) {
    return _run(
      () => _firestoreService.removeOfficer(orgId, memberUid),
      'Could not remove the officer. Please try again',
    );
  }

  /// The admin removes someone from the org. Returns null on success.
  Future<String?> removeMember(String orgId, String memberUid) {
    return _run(
      () => _firestoreService.removeMember(orgId, memberUid),
      'Could not remove the member. Please try again',
    );
  }

  /// The user leaves an org (members and officers only; the rules block
  /// the admin). It's the same three deletes as removeMember, done for the
  /// user's own uid, so no new service method is needed.
  /// Returns null on success, or a friendly error message.
  Future<String?> leaveOrg(String orgId, AppUser? user) {
    // The profile loads on Home; without it we don't know whose uid to use.
    if (user == null) {
      return Future.value('Your profile is still loading. Please try again later');
    }

    // Reuse the service's removeMember with MY uid, through the shared
    // _run helper (loading flag + friendly error message).
    return _run(
      () => _firestoreService.removeMember(orgId, user.uid),
      'Could not leave the organization. Please try again',
    );
  }


  /// Runs one service call with the same loading and error handling every
  /// time. Returns null on success, or the message to show in a SnackBar.
  Future<String?> _run(
    Future<void> Function() action,
    String fallbackMessage,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await action();
      return null;
    } on OrgFailure catch (e) {
      return e.message;
    } catch (e) {
      debugPrint('OrgProvider error: $e');
      return fallbackMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}
