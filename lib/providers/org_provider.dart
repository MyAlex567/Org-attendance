import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/invite.dart';
import '../models/member.dart';
import '../models/membership.dart';
import '../models/org.dart';
import '../services/org_service.dart';
import '../services/service_failure.dart';

class OrgProvider extends ChangeNotifier{
  final _orgService = OrgService();

  bool _isLoading = false;
  /// True while an org action is saving (button spinners).
  /// Used in: HomePage (Add and Join dialogs), InvitationsPage
  bool get isLoading => _isLoading;

  Org? _createdOrg;
  /// The org created last.
  /// Used in: nothing yet (the join code is shown on OrgPage instead)
  Org? get createdOrg => _createdOrg;

  /// Live list of the orgs the user belongs to.
  /// Used in: HomePage, the list of my orgs
  Stream<List<Membership>> myOrgs(String uid){
    return _orgService.watchMemberships(uid);
  }

  /// Live data of one org.
  /// Used in: OrgPage, the admin's join code card
  Stream<Org> watchOrg(String orgId){
    return _orgService.watchOrg(orgId);
  }

  /// Creates an org with the user as admin. Returns null on success, or a friendly error message.
  /// Used in: HomePage, Add organization dialog
  Future<String?> createOrg(String name, AppUser? user) async {
    if(user == null) return 'Your profile is still loading. Please try again later';

    _isLoading = true;
    notifyListeners();

    try{
      _createdOrg = await _orgService.createOrg(name, user);
      return null;
    } catch (e) {
      debugPrint('Create org error: $e');
      return 'Could not create the organization. Please try again';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Joins an org with a join code. Returns null on success, or a friendly error message.
  /// Used in: HomePage, Join organization dialog
  Future<String?> joinOrg(String code, AppUser? user) async {
    if(user == null) return 'Your profile is still loading. Please try again later';

    _isLoading = true;
    notifyListeners();

    try{
      await _orgService.joinOrg(code, user);
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
  /// Used in: MembersPage
  Stream<List<Member>> watchMembers(String orgId) {
    return _orgService.watchMembers(orgId);
  }

  /// Live list of the officer invites waiting for the user.
  /// Used in: HomePage invite badge and InvitationsPage
  Stream<List<Invite>> watchInvites(String uid) {
    return _orgService.watchInvites(uid);
  }

  /// The admin invites a member to become an officer.
  /// Returns null on success, or a friendly error message.
  /// Used in: MembersPage, tap a member then Send invite
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
      () => _orgService.inviteOfficer(orgId, orgName, admin.uid, memberUid),
      'Could not send the invitation. Please try again',
    );
  }

  /// The member accepts an officer invite. Returns null on success.
  /// Used in: InvitationsPage, Accept button
  Future<String?> acceptInvite(String orgId, AppUser? user) {
    if (user == null) {
      return Future.value('Your profile is still loading. Please try again later');
    }
    return _run(
      () => _orgService.respondToInvite(orgId, user.uid, accept: true),
      'Could not accept the invitation. Please try again',
    );
  }

  /// The member declines an officer invite. Returns null on success.
  /// Used in: InvitationsPage, Decline button
  Future<String?> declineInvite(String orgId, AppUser? user) {
    if (user == null) {
      return Future.value('Your profile is still loading. Please try again later');
    }
    return _run(
      () => _orgService.respondToInvite(orgId, user.uid, accept: false),
      'Could not decline the invitation. Please try again',
    );
  }

  /// The admin turns an officer back into a normal member.
  /// Used in: MembersPage, tap an officer then Remove
  Future<String?> removeOfficer(String orgId, String memberUid) {
    return _run(
      () => _orgService.removeOfficer(orgId, memberUid),
      'Could not remove the officer. Please try again',
    );
  }

  /// The admin removes someone from the org. Returns null on success.
  /// Used in: MembersPage, remove icon
  Future<String?> removeMember(String orgId, String memberUid) {
    return _run(
      () => _orgService.removeMember(orgId, memberUid),
      'Could not remove the member. Please try again',
    );
  }

  /// The user leaves an org (members and officers only; the rules block
  /// the admin). It's the same three deletes as removeMember, done for the
  /// user's own uid, so no new service method is needed.
  /// Returns null on success, or a friendly error message.
  /// Used in: OrgPage, Leave button (members and officers)
  Future<String?> leaveOrg(String orgId, AppUser? user) {
    // The profile loads on Home; without it we don't know whose uid to use.
    if (user == null) {
      return Future.value('Your profile is still loading. Please try again later');
    }

    // Reuse the service's removeMember with MY uid, through the shared
    // _run helper (loading flag + friendly error message).
    return _run(
      () => _orgService.removeMember(orgId, user.uid),
      'Could not leave the organization. Please try again',
    );
  }


  /// Runs one service call with the same loading and error handling every
  /// time. Returns null on success, or the message to show in a SnackBar.
  /// Used in: inviteOfficer, acceptInvite, declineInvite, removeOfficer, removeMember and leaveOrg (above)
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
