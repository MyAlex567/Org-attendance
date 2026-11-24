import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../organisms/login_form.dart';
import '../templates/auth_template.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_text.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {



  @override
  Widget build(BuildContext context) {
    return AuthTemplate(
      form: LoginForm(
        isLoading: context.watch<AuthProvider>().isLoading,
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