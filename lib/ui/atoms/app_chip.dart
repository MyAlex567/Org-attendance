import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// The colors a chip can have. The caller picks the text.
enum AppChipVariant { green, gray, solid }

/// A small pill label, e.g. "Open", "Closed", "Admin", "Officer", "Member".
class AppChip extends StatelessWidget {
  final String text;
  final AppChipVariant variant;

  const AppChip({
    super.key,
    required this.text,
    this.variant = AppChipVariant.gray,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = switch (variant) {
      AppChipVariant.green => AppColors.lightGreen,
      AppChipVariant.gray => AppColors.border,
      AppChipVariant.solid => AppColors.green,
    };
    final textColor = switch (variant) {
      AppChipVariant.green => AppColors.green,
      AppChipVariant.gray => AppColors.muted,
      AppChipVariant.solid => AppColors.white,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
