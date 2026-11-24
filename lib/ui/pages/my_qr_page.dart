import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_loader.dart';
import '../atoms/app_text.dart';
import '../molecules/qr_card.dart';

/// My QR: the code officers scan. It contains only the user's uid.
class MyQrPage extends StatelessWidget {
  const MyQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        toolbarHeight: 72,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: 'My QR',
              variant: AppTextVariant.title,
              color: AppColors.white,
            ),
            AppText(
              text: 'Show this at the event',
              variant: AppTextVariant.caption,
              color: AppColors.white,
            ),
          ],
        ),
      ),
      // The profile loads on Home; show a spinner until it's ready.
      body: user == null
          ? const AppLoader()
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: QrCard(
                  data: user.uid,
                  name: user.fullName,
                  studentId: user.studentId,
                ),
              ),
            ),
    );
  }
}
