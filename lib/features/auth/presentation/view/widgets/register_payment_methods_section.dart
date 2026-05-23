import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../models/register_payment_method.dart';
import 'register_text_field.dart';

class RegisterPaymentMethodsSection extends StatelessWidget {
  const RegisterPaymentMethodsSection({
    super.key,
    required this.selectedMethods,
    required this.controllers,
    required this.onMethodToggled,
    this.errorText,
  });

  final Set<RegisterPaymentMethod> selectedMethods;
  final Map<RegisterPaymentMethod, TextEditingController> controllers;
  final ValueChanged<RegisterPaymentMethod> onMethodToggled;
  final String? errorText;

  String? _valueValidator(
    String? value,
    RegisterPaymentMethod method,
    bool isSelected,
  ) {
    if (!isSelected || !method.requiresValue) {
      return null;
    }

    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return '${method.label} es obligatorio';
    }

    if (method == RegisterPaymentMethod.nequi ||
        method == RegisterPaymentMethod.daviplata) {
      if (!RegExp(r'^[0-9]{10}$').hasMatch(normalized)) {
        return 'Debe ser un numero colombiano de 10 digitos';
      }
    }

    if (method == RegisterPaymentMethod.llave && normalized.length > 32) {
      return 'La llave no puede superar 32 caracteres';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    const methods = [
      RegisterPaymentMethod.efectivo,
      RegisterPaymentMethod.nequi,
      RegisterPaymentMethod.daviplata,
      RegisterPaymentMethod.llave,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configura tus metodos de pago',
          style: AppTextStyles.secondary.copyWith(
            color: AppColors.slate900,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Selecciona todos los metodos de pago que deseas aceptar.',
          style: AppTextStyles.primary.copyWith(
            color: AppColors.slate400,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        ...methods.map((method) {
          final isSelected = selectedMethods.contains(method);
          final isLlave = method == RegisterPaymentMethod.llave;
          final isRequiredCash = method == RegisterPaymentMethod.efectivo;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFF7ED) : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.amber700 : AppColors.slate200,
                ),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: isRequiredCash ? null : () => onMethodToggled(method),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            method.label,
                            style: AppTextStyles.secondary.copyWith(
                              color: AppColors.slate900,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? AppColors.amber700
                              : AppColors.slate300,
                        ),
                      ],
                    ),
                  ),
                  if (isRequiredCash)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Obligatorio',
                          style: AppTextStyles.primary.copyWith(
                            color: AppColors.slate400,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  if (method.requiresValue && isSelected) ...[
                    const SizedBox(height: 12),
                    RegisterTextField(
                      label: method.hintText,
                      hintText: method.hintText,
                      icon: Icons.account_balance_wallet_outlined,
                      controller: controllers[method]!,
                      maxLength: isLlave ? 32 : 10,
                      keyboardType:
                          isLlave ? TextInputType.text : TextInputType.phone,
                      textCapitalization: TextCapitalization.none,
                      validator: (value) =>
                          _valueValidator(value, method, isSelected),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 2),
            child: Text(
              errorText!,
              style: const TextStyle(color: AppColors.errorRed, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
