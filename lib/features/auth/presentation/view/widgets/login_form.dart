import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/validators/form_validators.dart';
import '../../view_model/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../home/presentation/view/widgets/brand_header_section.dart';
import 'primary_action_button.dart';
import 'login_email_field.dart';
import 'login_password_field.dart';
import '../../view_model/auth_state.dart';
import '../../../../../../app/routes.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.rideOffers, (route) => false);
        }
      },
      builder: (context, state) {
        String? errorMessage;
        if (state.status == AuthStatus.error && state.errorMessage != null) {
          errorMessage = state.errorMessage;
        }
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
                      'Iniciar sesión',
                      style: AppTextStyles.secondary.copyWith(
                        color: AppColors.slate800,
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bienvenido de nuevo',
                      style: AppTextStyles.primary.copyWith(
                        color: AppColors.slate400,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    LoginEmailField(
                      controller: _emailController,
                      validator: (value) {
                        final empty = emptyFieldValidator(value, fieldName: 'Correo');
                        if (empty != null) return empty;
                        return uniandesEmailValidator(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    LoginPasswordField(
                      controller: _passwordController,
                      validator: (value) => emptyFieldValidator(value, fieldName: 'Contraseña'),
                    ),
                    const SizedBox(height: 24),
                    PrimaryActionButton(
                      label: state.status == AuthStatus.loading ? 'Ingresando...' : 'Ingresar',
                      onPressed: state.status == AuthStatus.loading ? () {} : _submit,
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMessage,
                        style: const TextStyle(color: AppColors.errorRed, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}