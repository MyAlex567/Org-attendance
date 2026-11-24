import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../models/org.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/org_provider.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_button.dart';
import '../atoms/app_loader.dart';
import '../atoms/app_text.dart';
import '../molecules/event_card.dart';
import '../molecules/join_code_card.dart';
import '../molecules/status_message.dart';
import 'attendance_list_page.dart';
import 'members_page.dart';
import 'take_attendance_page.dart';

/// Org Page: the org's name and my role, the join code and Members (admin),
/// Take attendance (officers and admin) and the list of sessions.
class OrgPage extends StatelessWidget {
  final String orgId;
  final String orgName;
  final String role;

  const OrgPage({
    super.key,
    required this.orgId,
    required this.orgName,
    required this.role,
  });

  bool get _isAdmin => role == 'admin';
  bool get _isStaff => role == 'admin' || role == 'officer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.white, // colors the back arrow
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: orgName,
              variant: AppTextVariant.title,
              color: AppColors.white,
            ),
            AppText(
              text: role,
              variant: AppTextVariant.caption,
              color: AppColors.white,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Only the admin may see and share the join code, and manage members.
          if (_isAdmin) ...[
            StreamBuilder<Org>(
              stream: context.read<OrgProvider>().watchOrg(orgId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint('Org error: ${snapshot.error}');
                  return const StatusMessage(
                    icon: Icons.error_outline,
                    message: 'Something went wrong',
                  );
                }
                if (!snapshot.hasData) {
                  return const AppLoader();
                }

                final org = snapshot.data!;
                return JoinCodeCard(
                  code: org.joinCode,
                  onCopy: () {
                    Clipboard.setData(ClipboardData(text: org.joinCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Join code copied')),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Members',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MembersPage(orgId: orgId, orgName: orgName),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Officers and the admin can start a session.
          if (_isStaff) ...[
            AppButton(
              label: 'Take attendance',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      TakeAttendancePage(orgId: orgId, orgName: orgName),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 12),
          const AppText(text: 'Sessions', variant: AppTextVariant.section),
          const SizedBox(height: 8),
          StreamBuilder<List<Event>>(
            stream: context.read<AttendanceProvider>().watchEvents(orgId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                debugPrint('Events error: ${snapshot.error}');
                return const StatusMessage(
                  icon: Icons.error_outline,
                  message: 'Something went wrong',
                );
              }
              if (!snapshot.hasData) {
                return const AppLoader();
              }

              final events = snapshot.data!;
              if (events.isEmpty) {
                return const StatusMessage(
                  icon: Icons.event_outlined,
                  message: 'No attendance sessions yet',
                );
              }

              return Column(
                children: [
                  for (final event in events)
                    _SessionCard(
                      event: event,
                      orgName: orgName,
                      isStaff: _isStaff,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// One session on the Org Page. Officers and the admin also see the live
/// attendee count and can open the attendance list; members can't read
/// attendance (security rules), so their card shows no count.
class _SessionCard extends StatelessWidget {
  final Event event;
  final String orgName;
  final bool isStaff;

  const _SessionCard({
    required this.event,
    required this.orgName,
    required this.isStaff,
  });

  @override
  Widget build(BuildContext context) {
    if (!isStaff) {
      return EventCard(
        title: event.title,
        venue: event.venue,
        startsAt: event.startsAt,
        isOpen: event.isOpen,
      );
    }

    return StreamBuilder<int>(
      stream: context
          .read<AttendanceProvider>()
          .watchAttendanceCount(event.orgId, event.id),
      builder: (context, snapshot) {
        return EventCard(
          title: event.title,
          venue: event.venue,
          startsAt: event.startsAt,
          isOpen: event.isOpen,
          attendeeCount: snapshot.data ?? 0,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AttendanceListPage(event: event, orgName: orgName),
            ),
          ),
        );
      },
    );
  }
}
