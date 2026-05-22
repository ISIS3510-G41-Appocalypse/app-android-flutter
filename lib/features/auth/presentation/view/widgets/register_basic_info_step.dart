import 'package:flutter/material.dart';
import '../../../../../core/validators/form_validators.dart';
import 'primary_action_button.dart';
import 'register_password_field.dart';
import 'register_step_header.dart';
import 'register_text_field.dart';

class RegisterBasicInfoStep extends StatelessWidget {
  const RegisterBasicInfoStep({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onNext,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          const RegisterStepHeader(
            title: 'Registrate',
            subtitle: 'Completa tus datos basicos para continuar',
            currentStep: 0,
            totalSteps: 2,
          ),
          const SizedBox(height: 24),
          RegisterTextField(
            label: 'Nombres',
            hintText: 'Tus nombres',
            icon: Icons.person_outline,
            controller: nameController,
            maxLength: 32,
            validator: (value) => nameValidator(value, fieldName: 'Nombres'),
          ),
          const SizedBox(height: 16),
          RegisterTextField(
            label: 'Apellidos',
            hintText: 'Tus apellidos',
            icon: Icons.badge_outlined,
            controller: lastNameController,
            maxLength: 32,
            validator: (value) => nameValidator(value, fieldName: 'Apellidos'),
          ),
          const SizedBox(height: 16),
          RegisterTextField(
            label: 'Correo electronico',
            hintText: 'ejemplo@uniandes.edu.co',
            icon: Icons.mail_outline,
            controller: emailController,
            maxLength: 50,
            keyboardType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
            validator: (value) {
              final empty = emptyFieldValidator(value, fieldName: 'Correo');
              if (empty != null) return empty;
              return uniandesEmailValidator(value);
            },
          ),
          const SizedBox(height: 16),
          RegisterPasswordField(
            label: 'Contrasena',
            hintText: 'Minimo 8 caracteres',
            controller: passwordController,
            validator: (value) {
              final empty = emptyFieldValidator(value, fieldName: 'Contrasena');
              if (empty != null) return empty;
              return passwordStrengthValidator(value);
            },
          ),
          const SizedBox(height: 16),
          RegisterPasswordField(
            label: 'Validar contrasena',
            hintText: 'Repite tu contrasena',
            controller: confirmPasswordController,
            validator: (value) => confirmPasswordValidator(
              value,
              originalPassword: passwordController.text,
            ),
          ),
          const SizedBox(height: 24),
          PrimaryActionButton(label: 'Siguiente', onPressed: onNext),
        ],
      ),
    );
  }
}
