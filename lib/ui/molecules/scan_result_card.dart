import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_text.dart';

/// The message under the camera after a scan: green for "recorded",
/// gray for "Not a member", "Already scanned" and errors.
class ScanResultCard extends StatelessWidget {
  final String message;
  final bool isSuccess;

  const ScanResultCard({
    super.key,
    required this.message,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? AppColors.green : AppColors.muted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSuccess ? AppColors.lightGreen : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSuccess ? AppColors.green : AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.info_outline,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppText(
              text: message,
              variant: AppTextVariant.subtitle,
              color: isSuccess ? AppColors.darkGreen : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
