import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_text.dart';

/// The green card with the live number of attendees on the Scan QR screen.
class AttendanceCountCard extends StatelessWidget {
  final int count;

  const AttendanceCountCard({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.people_outline, color: AppColors.white),
          const SizedBox(width: 12),
          const Expanded(
            child: AppText(
              text: 'Attended so far',
              variant: AppTextVariant.body,
              color: AppColors.white,
            ),
          ),
          AppText(
            text: '$count',
            variant: AppTextVariant.title,
            color: AppColors.white,
          ),
        ],
      ),
    );
  }
}
