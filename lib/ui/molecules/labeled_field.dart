import 'package:flutter/material.dart';
import '../atoms/app_text.dart';

/// A read-only label and value pair, used on Profile and Event Details.
class LabeledField extends StatelessWidget {
  final String label;
  final String value;

  const LabeledField({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(text: label, variant: AppTextVariant.caption),
          const SizedBox(height: 4),
          AppText(text: value, variant: AppTextVariant.body,),
        ],
      ),
    );
  }
}
