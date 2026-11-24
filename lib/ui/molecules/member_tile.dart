import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_chip.dart';
import '../atoms/app_text.dart';

/// One person in the Members list: name, student ID and role chip.
class MemberTile extends StatelessWidget {
  final String name;
  final String studentId;
  final String role;

  // Null makes the tile not tappable (used for the admin's own row).
  final VoidCallback? onTap;

  // Null hides the remove icon (used for the admin's own row).
  final VoidCallback? onRemove;

  const MemberTile({
    super.key,
    required this.name,
    required this.studentId,
    required this.role,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // Same colors as OrgCard, so a role looks the same everywhere.
    final chipVariant = switch (role) {
      'admin' => AppChipVariant.solid,
      'officer' => AppChipVariant.green,
      _ => AppChipVariant.gray,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(text: name, variant: AppTextVariant.subtitle),
                    const SizedBox(height: 2),
                    AppText(text: studentId, variant: AppTextVariant.caption),
                  ],
                ),
              ),
              AppChip(text: role, variant: chipVariant),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(
                    Icons.person_remove_outlined,
                    color: AppColors.muted,
                  ),
                  tooltip: 'Remove from org',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
