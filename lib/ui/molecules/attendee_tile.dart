import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_chip.dart';
import '../atoms/app_text.dart';

/// One scanned student in the live attendee list on Event Details.
class AttendeeTile extends StatelessWidget {
  final String studentName;
  final String studentId;

  // Null for a moment right after a scan, until Firestore's server fills in
  // the serverTimestamp.
  final DateTime? scannedAt;

  // True for "Mark me present" records, which show a "Self check-in" label.
  final bool isSelfCheckIn;

  const AttendeeTile({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.scannedAt,
    this.isSelfCheckIn = false,
  });

  @override
  Widget build(BuildContext context) {
    final time = scannedAt == null
        ? 'Just now'
        : DateFormat('h:mm a').format(scannedAt!);

    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: AppColors.lightGreen,
        child: Icon(Icons.check, color: AppColors.green),
      ),
      title: AppText(text: studentName, variant: AppTextVariant.subtitle),
      subtitle: AppText(text: '$studentId · $time', variant: AppTextVariant.caption),
      trailing: isSelfCheckIn ? const AppChip(text: 'Self check-in') : null,
    );
  }
}
