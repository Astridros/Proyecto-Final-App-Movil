import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';

typedef RegisterSubmitCallback =
    Future<bool> Function({
      required String email,
      required String firstName,
      required String lastName,
      required String password,
      required String referralMatricula,
    });

class RegisterForm extends StatefulWidget {
  const RegisterForm({
    super.key,
    required this.isRegistering,
    required this.onSubmit,
    this.errorMessage,
    this.onBackToLogin,
  });

  final bool isRegistering;
  final RegisterSubmitCallback onSubmit;
  final String? errorMessage;
  final VoidCallback? onBackToLogin;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _referralMatriculaController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _referralMatriculaController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _referralMatriculaController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Crear cuenta', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              'Completa tus datos para comenzar a usar Ocupa2.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (widget.errorMessage != null) ...[
              const SizedBox(height: AppDimensions.spacing16),
              Text(
                widget.errorMessage!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.spacing20),
            AppTextField(
              label: 'Nombre',
              prefixIcon: Icons.person_outline,
              controller: _firstNameController,
              enabled: !widget.isRegistering,
              validator: _requiredText('Nombre requerido'),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            AppTextField(
              label: 'Apellido',
              prefixIcon: Icons.badge_outlined,
              controller: _lastNameController,
              enabled: !widget.isRegistering,
              validator: _requiredText('Apellido requerido'),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            AppTextField(
              label: 'Correo',
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              enabled: !widget.isRegistering,
              validator: _validateEmail,
            ),
            const SizedBox(height: AppDimensions.spacing16),
            AppTextField(
              label: 'Matrícula de referido',
              prefixIcon: Icons.confirmation_number_outlined,
              keyboardType: TextInputType.number,
              controller: _referralMatriculaController,
              enabled: !widget.isRegistering,
              validator: _validateReferralMatricula,
            ),
            const SizedBox(height: AppDimensions.spacing16),
            AppTextField(
              label: 'Contraseña',
              prefixIcon: Icons.lock_outline,
              controller: _passwordController,
              enabled: !widget.isRegistering,
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
                onPressed: widget.isRegistering ? null : _togglePassword,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            AppTextField(
              label: 'Confirmar contraseña',
              prefixIcon: Icons.lock_reset_outlined,
              controller: _confirmPasswordController,
              enabled: !widget.isRegistering,
              obscureText: _obscureConfirmPassword,
              validator: _validateConfirmPassword,
              suffixIcon: IconButton(
                tooltip: _obscureConfirmPassword
                    ? 'Mostrar confirmar contraseña'
                    : 'Ocultar confirmar contraseña',
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: widget.isRegistering ? null : _toggleConfirmPassword,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing24),
            AppButton(
              label: 'Registrarme',
              icon: Icons.person_add_alt_1_outlined,
              width: double.infinity,
              isLoading: widget.isRegistering,
              onPressed: widget.isRegistering ? null : _submit,
            ),
            const SizedBox(height: AppDimensions.spacing12),
            Center(
              child: TextButton(
                onPressed: widget.isRegistering ? null : widget.onBackToLogin,
                child: const Text('¿Ya tienes cuenta? Inicia sesión'),
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
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      password: _passwordController.text,
      referralMatricula: _referralMatriculaController.text.trim(),
    );
  }

  void _togglePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPassword() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  FormFieldValidator<String> _requiredText(String message) {
    return (value) {
      final normalized = value?.trim();
      if (normalized == null || normalized.isEmpty) {
        return message;
      }

      return null;
    };
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

  String? _validateReferralMatricula(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return 'Matrícula requerida';
    }

    if (!RegExp(r'^\d+$').hasMatch(normalized)) {
      return 'Matrícula solo numérica';
    }

    if (normalized.length != 8) {
      return 'Matrícula debe tener 8 dígitos';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contraseña requerida';
    }

    if (value.length < 8) {
      return 'Contraseña debe tener al menos 8 caracteres';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirmar contraseña requerida';
    }

    if (value != _passwordController.text) {
      return 'Las contraseñas deben coincidir';
    }

    return null;
  }
}
