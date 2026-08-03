import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';

typedef ChangePasswordSubmitCallback =
    Future<bool> Function({required String password});

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({
    super.key,
    required this.isSubmitting,
    required this.onSubmit,
    this.errorMessage,
    this.successMessage,
  });

  final bool isSubmitting;
  final ChangePasswordSubmitCallback onSubmit;
  final String? errorMessage;
  final String? successMessage;

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
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
            Text('Cambiar contraseña', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              'Ingresa una nueva contraseña para tu cuenta.',
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
            if (widget.successMessage != null) ...[
              const SizedBox(height: AppDimensions.spacing16),
              Text(
                widget.successMessage!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.spacing20),
            AppTextField(
              label: 'Nueva contraseña',
              prefixIcon: Icons.lock_outline,
              controller: _passwordController,
              enabled: !widget.isSubmitting,
              obscureText: _obscurePassword,
              validator: _validatePassword,
              suffixIcon: IconButton(
                tooltip: _obscurePassword
                    ? 'Mostrar nueva contraseña'
                    : 'Ocultar nueva contraseña',
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: widget.isSubmitting ? null : _togglePassword,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            AppTextField(
              label: 'Confirmar nueva contraseña',
              prefixIcon: Icons.lock_reset_outlined,
              controller: _confirmPasswordController,
              enabled: !widget.isSubmitting,
              obscureText: _obscureConfirmPassword,
              validator: _validateConfirmPassword,
              suffixIcon: IconButton(
                tooltip: _obscureConfirmPassword
                    ? 'Mostrar confirmar nueva contraseña'
                    : 'Ocultar confirmar nueva contraseña',
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: widget.isSubmitting ? null : _toggleConfirmPassword,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing24),
            AppButton(
              label: 'Cambiar contraseña',
              icon: Icons.key_outlined,
              width: double.infinity,
              isLoading: widget.isSubmitting,
              onPressed: widget.isSubmitting ? null : _submit,
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

    final wasSuccessful = await widget.onSubmit(
      password: _passwordController.text,
    );
    if (!wasSuccessful || !mounted) {
      return;
    }

    _passwordController.clear();
    _confirmPasswordController.clear();
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nueva contraseña requerida';
    }

    if (value.trim().isEmpty) {
      return 'La contraseña no puede contener solo espacios';
    }

    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirmación requerida';
    }

    if (value != _passwordController.text) {
      return 'Las contraseñas deben coincidir';
    }

    return null;
  }
}
