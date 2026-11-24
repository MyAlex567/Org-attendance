import 'package:flutter/material.dart';
import 'package:org_attendance_qr/theme/app_theme.dart';
import '../atoms/app_text.dart';
import '../../utils/validators.dart';
import '../atoms/app_button.dart';
import '../molecules/app_text_field.dart';

class OrgForm extends StatefulWidget {
  final void Function(String name) onSubmit;
  final bool isLoading;

  const OrgForm({
    super.key,
    required this.onSubmit,
    required this.isLoading,  
  });

  @override
  State<OrgForm> createState() => _OrgFormState();
}

class _OrgFormState extends State<OrgForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose(){
    _nameController.dispose();
    super.dispose();
  }

  void _submit(){
    if(_formKey.currentState!.validate()){
      widget.onSubmit(_nameController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      title: AppText(text: "Create Organization", variant: AppTextVariant.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: _nameController, 
              label: 'Organization name',
              validator: (value) => Validators.requiredField(value, 'Organization name'),  
            ),
            const SizedBox(height: 24,),
            AppButton(
              label: "Create organization", 
              onPressed: _submit,
              isLoading: widget.isLoading,
            ),
          ],
        ),
      ),
    ); 
    
  }
}