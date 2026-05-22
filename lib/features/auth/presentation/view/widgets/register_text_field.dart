import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';

class RegisterTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int maxLength;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;

  const RegisterTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.controller,
    required this.validator,
    required this.maxLength,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.words,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.slate800,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
          style: const TextStyle(color: AppColors.slate800),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppColors.gray50,
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.slate400),
            prefixIcon: Icon(icon, color: AppColors.slate400),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 16,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(
                color: AppColors.slate400,
                width: 1.5,
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(
                color: AppColors.slate400,
                width: 1.5,
              ),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(
                color: AppColors.errorRed,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(
                color: AppColors.errorRed,
                width: 1.5,
              ),
            ),
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}
