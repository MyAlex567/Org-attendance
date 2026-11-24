import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/invite.dart';
import '../../providers/auth_provider.dart';
import '../../providers/org_provider.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_loader.dart';
import '../atoms/app_text.dart';
import '../molecules/invite_card.dart';
import '../molecules/status_message.dart';

/// Invitations: officer invites waiting for me, with Accept and Decline.
class InvitationsPage extends StatefulWidget {
  const InvitationsPage({super.key});

  @override
  State<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends State<InvitationsPage> {
  Stream<List<Invite>>? _invites;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _invites = context.read<OrgProvider>().watchInvites(user.uid);
    }
  }

  Future<void> _respond(Invite invite, {required bool accept}) async {
    final orgProvider = context.read<OrgProvider>();
    final user = context.read<AuthProvider>().user;

    final error = accept
        ? await orgProvider.acceptInvite(invite.orgId, user)
        : await orgProvider.declineInvite(invite.orgId, user);

    if (!mounted) return;

    final message = error ??
        (accept
            ? 'You are now an officer of ${invite.orgName}'
            : 'Invitation declined');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<OrgProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.white,
        title: const AppText(
          text: 'Invitations',
          variant: AppTextVariant.title,
          color: AppColors.white,
        ),
      ),
      body: StreamBuilder<List<Invite>>(
        stream: _invites,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Invites error: ${snapshot.error}');
            return const StatusMessage(
              icon: Icons.error_outline,
              message: 'Something went wrong',
            );
          }
          if (!snapshot.hasData) {
            return const AppLoader();
          }

          final invites = snapshot.data!;
          if (invites.isEmpty) {
            return const StatusMessage(
              icon: Icons.mail_outline,
              message: 'No invitations right now',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final invite in invites)
                InviteCard(
                  orgName: invite.orgName,
                  isLoading: isLoading,
                  onAccept: () => _respond(invite, accept: true),
                  onDecline: () => _respond(invite, accept: false),
                ),
            ],
          );
        },
      ),
    );
  }
}
