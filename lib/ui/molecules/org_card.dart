import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_chip.dart';
import '../atoms/app_text.dart';

class OrgCard extends StatelessWidget {
  final String orgName;
  final String role;
  final VoidCallback? onTap;

  const OrgCard({
    super.key,
    required this.orgName,
    required this.role,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    final chipVariant = switch (role) {
      'admin' => AppChipVariant.solid,
      'officer' => AppChipVariant.green,
      _ => AppChipVariant.gray
    };

    return Card(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: AppText(text: orgName, variant: AppTextVariant.subtitle),
              ),
              AppChip(text: role, variant: chipVariant,)
            ],
          ),
        ),
      ),
    );
  }
}