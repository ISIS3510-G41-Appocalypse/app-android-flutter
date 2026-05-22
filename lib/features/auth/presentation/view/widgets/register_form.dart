import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/validators/form_validators.dart';
import '../../../../home/presentation/view/widgets/brand_header_section.dart';
import 'primary_action_button.dart';
import 'register_password_field.dart';
import 'register_text_field.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    _formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const BrandHeaderSection(),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withAlpha(26),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Registrate',
                  style: AppTextStyles.secondary.copyWith(
                    color: AppColors.slate800,
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Crea tu cuenta para comenzar esta experiencia',
                  style: AppTextStyles.primary.copyWith(
                    color: AppColors.slate400,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                RegisterTextField(
                  label: 'Nombre',
                  hintText: 'Tu nombre',
                  icon: Icons.person_outline,
                  controller: _nameController,
                  maxLength: 25,
                  validator: (value) =>
                      nameValidator(value, fieldName: 'Nombre'),
                ),
                const SizedBox(height: 16),
                RegisterTextField(
                  label: 'Apellido',
                  hintText: 'Tu apellido',
                  icon: Icons.badge_outlined,
                  controller: _lastNameController,
                  maxLength: 25,
                  validator: (value) =>
                      nameValidator(value, fieldName: 'Apellido'),
                ),
                const SizedBox(height: 16),
                RegisterTextField(
                  label: 'Correo electronico',
                  hintText: 'ejemplo@uniandes.edu.co',
                  icon: Icons.mail_outline,
                  controller: _emailController,
                  maxLength: 50,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    final empty = emptyFieldValidator(
                      value,
                      fieldName: 'Correo',
                    );
                    if (empty != null) return empty;
                    return uniandesEmailValidator(value);
                  },
                ),
                const SizedBox(height: 16),
                RegisterPasswordField(
                  label: 'Contrasena',
                  hintText: 'Minimo 8 caracteres',
                  controller: _passwordController,
                  validator: (value) {
                    final empty = emptyFieldValidator(
                      value,
                      fieldName: 'Contrasena',
                    );
                    if (empty != null) return empty;
                    return passwordStrengthValidator(value);
                  },
                ),
                const SizedBox(height: 16),
                RegisterPasswordField(
                  label: 'Validar contrasena',
                  hintText: 'Repite tu contrasena',
                  controller: _confirmPasswordController,
                  validator: (value) => confirmPasswordValidator(
                    value,
                    originalPassword: _passwordController.text,
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryActionButton(
                  label: 'Crear cuenta',
                  onPressed: _validateForm,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
