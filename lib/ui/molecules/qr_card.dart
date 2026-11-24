import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_text.dart';

/// The My QR card: the user's QR code, name, student ID and a tip.
class QrCard extends StatelessWidget {
  final String data; // what the QR code contains (the user's uid)
  final String name;
  final String studentId;

  const QrCard({
    super.key,
    required this.data,
    required this.name,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: data,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: AppColors.white,
            ),
            const SizedBox(height: 16),
            AppText(text: name, variant: AppTextVariant.title),
            const SizedBox(height: 4),
            AppText(text: studentId, variant: AppTextVariant.caption),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const AppText(
                text: 'Show this code to an officer at the event. '
                    'Turn up your screen brightness so it scans faster.',
                variant: AppTextVariant.caption,
                color: AppColors.darkGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
