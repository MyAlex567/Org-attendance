import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../atoms/app_loader.dart';
import 'main_page.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: context.read<AuthProvider>().uidChanges, 
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Scaffold(body: AppLoader(),);
        }
        if(snapshot.data == null){
          return const LoginPage();
        }
        return const MainPage();
      },
    );
  }
}