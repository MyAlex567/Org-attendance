import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_text.dart';
import '../organisms/event_form.dart';
import 'scan_page.dart';

/// Take Attendance (officers and admin): event name, venue, date and time.
/// Creating it starts the session and opens the Scan QR screen.
class TakeAttendancePage extends StatelessWidget {
  final String orgId;
  final String orgName;

  const TakeAttendancePage({
    super.key,
    required this.orgId,
    required this.orgName,
  });

  Future<void> _create(
    BuildContext context,
    String title,
    String venue,
    DateTime startsAt,
  ) async {
    final attendance = context.read<AttendanceProvider>();
    final user = context.read<AuthProvider>().user;

    final error = await attendance.createEvent(
      orgId: orgId,
      title: title,
      venue: venue,
      startsAt: startsAt,
      user: user,
    );

    if (!context.mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    // Replace this form with the scanner, so Back goes to the Org Page.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ScanPage(
          event: attendance.createdEvent!,
          orgName: orgName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AttendanceProvider>().isLoading;

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
              text: 'Take attendance',
              variant: AppTextVariant.title,
              color: AppColors.white,
            ),
            AppText(
              text: orgName,
              variant: AppTextVariant.caption,
              color: AppColors.white,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: EventForm(
          isLoading: isLoading,
          onSubmit: (title, venue, startsAt) =>
              _create(context, title, venue, startsAt),
        ),
      ),
    );
  }
}
