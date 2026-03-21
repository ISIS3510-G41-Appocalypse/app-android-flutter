import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';

class LoginEmailField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const LoginEmailField({
    super.key,
    required this.controller,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Correo electrónico',
            style: TextStyle(
              color: AppColors.slate800,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            TextFormField(
              controller: controller,
              validator: validator,
              keyboardType: TextInputType.emailAddress,
              inputFormatters: [LengthLimitingTextInputFormatter(50)],
              style: const TextStyle(color: AppColors.slate800),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.gray50,
                hintText: 'ejemplo@uniandes.edu.co',
                hintStyle: const TextStyle(color: AppColors.slate400),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 48),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(
                    color: AppColors.slate400,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(
                    color: AppColors.slate400,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(
                    color: AppColors.errorRed,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(
                    color: AppColors.errorRed,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Icon(Icons.mail, color: AppColors.slate400),
            ),
          ],
        ),
      ],
    );
  }
}