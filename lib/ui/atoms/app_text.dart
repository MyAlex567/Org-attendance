import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// The text styles used across the app.
enum AppTextVariant { title, subtitle, body, caption, section }

/// Text that picks its style from [variant], so screens don't set font sizes by hand.
class AppText extends StatelessWidget {
  final String text;
  final AppTextVariant variant;
  final Color? color;
  final FontWeight? fontWeight;
  final double? size;

  const AppText({
    super.key,
    required this.text,
    required this.variant,
    this.color,
    this.fontWeight,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = switch (variant) {
      AppTextVariant.title => TextStyle(
        fontSize: size ?? 20,
        fontWeight: fontWeight ?? FontWeight.bold,
        color: color ?? AppColors.text,
      ),
      AppTextVariant.subtitle => TextStyle(
        fontSize: size ?? 16,
        fontWeight: fontWeight ?? FontWeight.w600,
        color: color ?? AppColors.text,
      ),
      AppTextVariant.body => TextStyle(
        fontSize: size ?? 14,
        fontWeight: fontWeight ?? FontWeight.normal,
        color: color ?? AppColors.text,
      ),
      AppTextVariant.caption => TextStyle(
        fontSize: size ?? 13,
        fontWeight: fontWeight,
        color: color ?? AppColors.muted,
      ),
      AppTextVariant.section => TextStyle(
        fontSize: size ?? 12,
        fontWeight: fontWeight ?? FontWeight.w600,
        color: color ?? AppColors.muted,
        letterSpacing: 1,
      ),
    };

    // Section headers are always capitals ("UPCOMING" in the design),
    // even if the caller types them in lowercase.
    final displayText = variant == AppTextVariant.section ? text.toUpperCase() : text;

    return Text(displayText, style: textStyle);
  }
}
