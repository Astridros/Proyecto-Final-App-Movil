import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';

typedef LoginSubmitCallback =
    Future<bool> Function({required String email, required String password});

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.isLoggingIn,
    required this.onSubmit,
    this.errorMessage,
    this.onForgotPassword,
    this.onRegister,
  });

  final bool isLoggingIn;
  final LoginSubmitCallback onSubmit;
  final String? errorMessage;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onRegister;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Iniciar sesión',
              textAlign: TextAlign.center,
              style: AppTextStyles.headingSmall,
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              'Bienvenido de vuelta. Accede para continuar con Ocupa2.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (widget.errorMessage != null) ...[
              const SizedBox(height: AppDimensions.spacing16),
              Text(
                widget.errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.spacing20),
            AppTextField(
              label: 'Correo',
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              enabled: !widget.isLoggingIn,
              validator: _validateEmail,
            ),
            const SizedBox(height: AppDimensions.spacing16),
            AppTextField(
              label: 'Contraseña',
              prefixIcon: Icons.lock_outline,
              controller: _passwordController,
              enabled: !widget.isLoggingIn,
              obscureText: _obscurePassword,
              validator: _validatePassword,
              suffixIcon: IconButton(
                tooltip: _obscurePassword
                    ? 'Mostrar contraseña'
                    : 'Ocultar contraseña',
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: widget.isLoggingIn ? null : _togglePassword,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.isLoggingIn ? null : widget.onForgotPassword,
                child: const Text('¿Olvidaste tu contraseña?'),
              ),
            ),
            const SizedBox(height: AppDimensions.spacing12),
            AppButton(
              label: 'Entrar',
              icon: Icons.login_outlined,
              width: double.infinity,
              isLoading: widget.isLoggingIn,
              onPressed: widget.isLoggingIn ? null : _submit,
            ),
            const SizedBox(height: AppDimensions.spacing12),
            Center(
              child: TextButton(
                onPressed: widget.isLoggingIn ? null : widget.onRegister,
                child: const Text('¿No tienes cuenta? Regístrate'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await widget.onSubmit(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _togglePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  String? _validateEmail(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return 'Correo requerido';
    }

    final isValid = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(normalized);
    if (!isValid) {
      return 'Correo inválido';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contraseña requerida';
    }

    if (value.trim().isEmpty) {
      return 'La contraseña no puede contener solo espacios';
    }

    return null;
  }
}
