import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_text.dart';

/// One event in the logged-in user's own attendance history.
class AttendanceHistoryTile extends StatelessWidget {
  final String eventTitle;
  final String orgName;

  // Null for a moment right after a "Mark me present" on this phone, until
  // Firestore's server fills in the serverTimestamp.
  final DateTime? scannedAt;

  const AttendanceHistoryTile({
    super.key,
    required this.eventTitle,
    required this.orgName,
    required this.scannedAt,
  });

  @override
  Widget build(BuildContext context) {
    final date = scannedAt == null
        ? 'Just now'
        : DateFormat('MMM d, y, h:mm a').format(scannedAt!);

    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: AppColors.lightGreen,
        child: Icon(Icons.check, color: AppColors.green),
      ),
      title: AppText(text: eventTitle, variant: AppTextVariant.subtitle),
      subtitle: AppText(text: '$orgName · $date', variant: AppTextVariant.caption),
    );
  }
}
