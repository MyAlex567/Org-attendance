import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_text.dart';

/// The text box used in every form (Login, Register, Create Event).
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isHidden = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(text: widget.label, fontWeight: FontWeight.w500, variant: AppTextVariant.body,),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: _isHidden,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            suffixIcon: widget.obscureText ? 
              IconButton(
                onPressed: () => setState(() {
                  _isHidden = !_isHidden;
                }), 
                icon: Icon(
                  _isHidden ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.muted,
                ),
              ) : null,
            filled: true,
            fillColor: const Color.fromARGB(49, 224, 224, 224),
            // Sets the shape for every state; error states reuse it with the
            // theme's red, so we don't hard-code an error color.
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.green, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
