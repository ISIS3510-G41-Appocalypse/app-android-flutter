import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';

class PrimaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: AppTextStyles.secondary.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
