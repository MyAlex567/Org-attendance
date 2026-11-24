import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_text.dart';

/// A centered icon and message for empty and error states in live lists.
class StatusMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const StatusMessage({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.muted),
            const SizedBox(height: 8),
            AppText(text: message, color: AppColors.muted, variant: AppTextVariant.body,),
          ],
        ),
      ),
    );
  }
}
