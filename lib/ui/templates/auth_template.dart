import 'package:flutter/material.dart';
import '../atoms/app_text.dart';

class AuthTemplate extends StatelessWidget {
  final Widget form;
  final Widget? footer;

  const AuthTemplate({
    super.key,
    required this.form,
    this.footer
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/images/org_attendance_logo.png',
                width: 72,
                height: 72,
              ),
              AppText(text: "Org Attendance", variant: AppTextVariant.title, size: 30,),
              AppText(text: "Scan in at org events. No Paper Sheets.", variant: AppTextVariant.caption, size: 18,),
              SizedBox(height: 20,),
              Container(
                width: 300,
                decoration: BoxDecoration(),
                child: form,
              ),
              footer ?? SizedBox(height: 0,),
            ],
          ),
        ),
      ),
    );
  }
}