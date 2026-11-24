import 'package:flutter/material.dart';
import 'package:org_attendance_qr/ui/atoms/app_text.dart';
import 'package:provider/provider.dart';
import '../organisms/register_form.dart';
import '../templates/auth_template.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  @override
  Widget build(BuildContext context) {
    return AuthTemplate(
      form: RegisterForm(
        isLoading: context.watch<AuthProvider>().isLoading,
        onSubmit: (fullName, studentId, email, password) async{
          final error = await context.read<AuthProvider>()
            .register(fullName, studentId, email, password);

          if (!context.mounted) return;

          if(error != null){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error)),
            );
            return;
          }

          Navigator.pop(context);
        }
      ),
      footer: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              text: "Already have an account?",
              variant: AppTextVariant.caption,
              size: 15,
            ),
            TextButton(
              // Register is opened on top of Login, so going back returns to it.
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const AppText(
                text: "Log in",
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
