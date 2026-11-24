import 'package:flutter/material.dart';
import 'package:org_attendance_qr/ui/atoms/app_button.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_text.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.green,
        toolbarHeight: 72,
        title: AppText(
          text: "Profile", 
          variant: AppTextVariant.title, 
          color: AppColors.white,),
        ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 24,),
          AppButton(label: "Log out", onPressed: () => context.read<AuthProvider>().logout())
        ],
      ),
    );
  }
}