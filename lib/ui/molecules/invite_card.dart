import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_button.dart';
import '../atoms/app_text.dart';

/// One officer invitation with Accept and Decline buttons.
class InviteCard extends StatelessWidget {
  final String orgName;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  // True while an answer is being saved, so the buttons can't be tapped twice.
  final bool isLoading;

  const InviteCard({
    super.key,
    required this.orgName,
    required this.onAccept,
    required this.onDecline,
    this.isLoading = false,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(text: orgName, variant: AppTextVariant.subtitle),
            const SizedBox(height: 4),
            const AppText(
              text: 'You are invited to be an officer.',
              variant: AppTextVariant.caption,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: isLoading ? null : onDecline,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.muted,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Accept',
                    onPressed: onAccept,
                    isLoading: isLoading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
