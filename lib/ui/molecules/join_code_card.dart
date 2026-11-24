import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_text.dart';

/// Shows an org's join code with a Copy button. The page decides what
/// "copy" does, so this card stays simple.
class JoinCodeCard extends StatelessWidget {
  final String code;
  final VoidCallback onCopy;

  const JoinCodeCard({
    super.key,
    required this.code,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    text: 'Join code',
                    variant: AppTextVariant.caption,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    text: code,
                    variant: AppTextVariant.title,
                    color: AppColors.darkGreen,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy, color: AppColors.green),
              tooltip: 'Copy code',
            ),
          ],
        ),
      ),
    );
  }
}