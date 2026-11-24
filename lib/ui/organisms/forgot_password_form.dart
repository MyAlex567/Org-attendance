import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../atoms/app_button.dart';
import '../atoms/app_text.dart';
import '../molecules/app_text_field.dart';

/// Dialog with one email field and a "Send reset link" button. The page
/// decides what happens on submit, so this form never talks to Firebase.
class ForgotPasswordForm extends StatefulWidget {
  final void Function(String email) onSubmit;
  final bool isLoading;

  const ForgotPasswordForm({
    super.key,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  // The key connects the Form so validate() can check the field.
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  // Free the controller when the dialog closes.
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Only send the email up if the validator passes.
  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(_emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    // A white dialog (like OrgForm) so the field's outline is visible.
    return AlertDialog(
      backgroundColor: AppColors.white,
      title: const AppText(
        text: 'Reset password',
        variant: AppTextVariant.title,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          // Only as tall as its content, not the whole screen.
          mainAxisSize: MainAxisSize.min,
          children: [
            // Short explanation of what will happen.
            const AppText(
              text: "Enter your account's email and we'll send you a link "
                  'to set a new password.',
              variant: AppTextVariant.caption,
            ),
            const SizedBox(height: 16),

            // The same email validator the Login form uses.
            AppTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
            const SizedBox(height: 24),

            // Shows a spinner while Firebase is sending the email.
            AppButton(
              label: 'Send reset link',
              onPressed: _submit,
              isLoading: widget.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}