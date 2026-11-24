import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/member.dart';
import '../../providers/auth_provider.dart';
import '../../providers/org_provider.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_loader.dart';
import '../atoms/app_text.dart';
import '../molecules/member_tile.dart';
import '../molecules/status_message.dart';
import '../organisms/confirm_dialog.dart';

/// Members (admin only): everyone in the org. Tap a member to invite them as
/// an officer, or tap an officer to remove the role.
class MembersPage extends StatefulWidget {
  final String orgId;
  final String orgName;

  const MembersPage({
    super.key,
    required this.orgId,
    required this.orgName,
  });

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  // Created once, so rebuilds don't restart the Firestore listener.
  late final Stream<List<Member>> _members;

  @override
  void initState() {
    super.initState();
    _members = context.read<OrgProvider>().watchMembers(widget.orgId);
  }

  Future<void> _onMemberTap(Member member) async {
    final isOfficer = member.role == 'officer';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: isOfficer ? 'Remove officer' : 'Make officer',
        message: isOfficer
            ? 'Remove the officer role from ${member.name}? They will become a regular member.'
            : 'Invite ${member.name} to become an officer? They must accept the invitation in the app.',
        confirmLabel: isOfficer ? 'Remove' : 'Send invite',
      ),
    );
    if (confirmed != true || !mounted) return;

    final orgProvider = context.read<OrgProvider>();
    final admin = context.read<AuthProvider>().user;

    final error = isOfficer
        ? await orgProvider.removeOfficer(widget.orgId, member.uid)
        : await orgProvider.inviteOfficer(
            widget.orgId, widget.orgName, admin, member.uid);

    if (!mounted) return;

    final message = error ??
        (isOfficer
            ? '${member.name} is now a member'
            : 'Invitation sent to ${member.name}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _onRemoveTap(Member member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Remove member',
        message: 'Remove ${member.name} from ${widget.orgName}? '
            'Their past attendance stays in the records.',
        confirmLabel: 'Remove',
      ),
    );
    if (confirmed != true || !mounted) return;

    final error = await context
        .read<OrgProvider>()
        .removeMember(widget.orgId, member.uid);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? '${member.name} was removed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.white,
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              text: 'Members',
              variant: AppTextVariant.title,
              color: AppColors.white,
            ),
            AppText(
              text: widget.orgName,
              variant: AppTextVariant.caption,
              color: AppColors.white,
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Member>>(
        stream: _members,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Members error: ${snapshot.error}');
            return const StatusMessage(
              icon: Icons.error_outline,
              message: 'Something went wrong',
            );
          }
          if (!snapshot.hasData) {
            return const AppLoader();
          }

          final members = snapshot.data!;
          if (members.isEmpty) {
            return const StatusMessage(
              icon: Icons.groups_outlined,
              message: 'No members yet',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const AppText(
                text: 'Tap a member to make or remove an officer',
                variant: AppTextVariant.caption,
              ),
              const SizedBox(height: 8),
              for (final member in members)
                MemberTile(
                  name: member.name,
                  studentId: member.studentId,
                  role: member.role,
                  // The admin can't be made an officer or removed.
                  onTap: member.isAdmin ? null : () => _onMemberTap(member),
                  onRemove:
                      member.isAdmin ? null : () => _onRemoveTap(member),
                ),
            ],
          );
        },
      ),
    );
  }
}
