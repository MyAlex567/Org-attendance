import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_text.dart';

/// A yes/no dialog. It closes itself and returns true (confirm) or false
/// (cancel), so the page decides what to do with the answer.
///
/// Usage: `final ok = await showDialog<bool>(context: context, builder: (_) => ConfirmDialog(...));`
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      title: AppText(text: title, variant: AppTextVariant.title),
      content: AppText(text: message, variant: AppTextVariant.body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(foregroundColor: AppColors.muted),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: AppColors.green),
          child: Text(
            confirmLabel,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
