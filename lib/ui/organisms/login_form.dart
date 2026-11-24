import 'package:flutter/material.dart';
import '../../utils/validators.dart';
import '../atoms/app_button.dart';
import '../molecules/app_text_field.dart';
import '../atoms/app_text.dart';
import '../../theme/app_theme.dart';

/// Email and password fields with a "Log in" button. The page decides what
/// happens on submit, so this form never talks to Firebase.
class LoginForm extends StatefulWidget {
  final void Function(String email, String password) onSubmit;
  final bool isLoading;
  final VoidCallback onForgotPassword;

  const LoginForm({
    super.key,
    required this.onSubmit,
    required this.isLoading,
    required this.onForgotPassword,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    // Only send the values up if every validator passes.
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(_emailController.text.trim(), _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _passwordController,
            label: 'Password',
            obscureText: true,
            validator: Validators.password,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onForgotPassword,
              child: const AppText(
                text: 'Forgot password?',
                variant: AppTextVariant.caption,
                fontWeight: FontWeight.w600,
                color: AppColors.green,
              ),
            ),
          ),
          const SizedBox(height: 16,),
          AppButton(
            label: 'Log in',
            onPressed: _submit,
            isLoading: widget.isLoading,
          ),
        ],
      ),
    );
  }
}
