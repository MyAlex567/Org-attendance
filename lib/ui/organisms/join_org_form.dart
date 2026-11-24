import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../atoms/app_button.dart';
import '../atoms/app_text.dart';
import '../molecules/app_text_field.dart';

/// Dialog with one field for the 6-character join code. The page decides
/// what happens on submit, so this form never talks to Firebase.
class JoinOrgForm extends StatefulWidget {
  final void Function(String code) onSubmit;
  final bool isLoading;

  const JoinOrgForm({
    super.key,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<JoinOrgForm> createState() => _JoinOrgFormState();
}

class _JoinOrgFormState extends State<JoinOrgForm> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(_codeController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      title: const AppText(
        text: 'Join Organization',
        variant: AppTextVariant.title,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: _codeController,
              label: 'Join code',
              validator: Validators.joinCode,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Join organization',
              onPressed: _submit,
              isLoading: widget.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}