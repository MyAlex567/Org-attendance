import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../organisms/login_form.dart';
import '../templates/auth_template.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_text.dart';
import 'register_page.dart';
import '../organisms/forgot_password_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  Future<void> _showForgotPasswordDialog() async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        // watch: the dialog rebuilds when isLoading changes (spinner).
        final isLoading = dialogContext.watch<AuthProvider>().isLoading;

        return ForgotPasswordForm(
          isLoading: isLoading,
          onSubmit: (email) async {
            // Ask Firebase (through the provider) to send the email.
            final error =
                await context.read<AuthProvider>().sendPasswordReset(email);

            // The page may have closed while we waited.
            if (!mounted) return;

            // Error: show it and keep the dialog open to try again.
            if (error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error)),
              );
              return;
            }

            // Success: close the dialog (if the user hasn't already).
            if (!dialogContext.mounted) return;
            Navigator.pop(dialogContext);

            // Same message whether or not the email has an account,
            // so nobody can use this to find out who is registered.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'If that email has an account, we sent a reset link. '
                  'Check your inbox and spam folder.',
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthTemplate(
      form: LoginForm(
        isLoading: context.watch<AuthProvider>().isLoading,
        onForgotPassword: _showForgotPasswordDialog,
        onSubmit: (email, password) async{
          final error = await context.read<AuthProvider>().login(email, password);

          if(!context.mounted) return;

          if(error != null){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error))
            );
            return;            
          }

        }
      ),
      footer: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              text: "Don't have an account yet?", 
              variant: AppTextVariant.caption,
              size: 15,
            ),
            TextButton(
              onPressed: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              }, 
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const AppText(
                text: "Register", 
                variant: AppTextVariant.caption, 
                fontWeight: FontWeight.bold,
                size: 16,
                color: AppColors.green,
              ),
            )
          ],
        ),
      ),
    );
  }
}