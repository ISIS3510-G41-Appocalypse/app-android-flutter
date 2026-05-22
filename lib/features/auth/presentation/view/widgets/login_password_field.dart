import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';

class LoginPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const LoginPasswordField({
    super.key,
    required this.controller,
    required this.validator,
  });

  @override
  State<LoginPasswordField> createState() => _LoginPasswordFieldState();
}

class _LoginPasswordFieldState extends State<LoginPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Contrasena',
            style: TextStyle(
              color: Color(0xFF1e293b),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: _obscureText,
          inputFormatters: [LengthLimitingTextInputFormatter(32)],
          style: const TextStyle(color: Color(0xFF1e293b)),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.gray50,
            hintText: '••••••••',
            hintStyle: const TextStyle(color: AppColors.slate400),
            prefixIcon: const Icon(Icons.lock, color: AppColors.slate400),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: AppColors.slate400,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
