import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';

typedef ForgotPasswordSubmitCallback =
    Future<bool> Function({
      required String email,
      required String referralMatricula,
    });

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({
    super.key,
    required this.isRecoveringPassword,
    required this.onSubmit,
    this.errorMessage,
    this.successMessage,
    this.onBackToLogin,
  });

  final bool isRecoveringPassword;
  final ForgotPasswordSubmitCallback onSubmit;
  final String? errorMessage;
  final String? successMessage;
  final VoidCallback? onBackToLogin;

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _referralMatriculaController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _referralMatriculaController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _referralMatriculaController.dispose();
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
            Text('Recuperar contraseña', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              'Ingresa tu correo y matrícula. Si los datos coinciden, recibirás una clave temporal.',
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
              label: 'Correo',
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              enabled: !widget.isRecoveringPassword,
              validator: _validateEmail,
            ),
            const SizedBox(height: AppDimensions.spacing16),
            AppTextField(
              label: 'Matrícula de referido',
              prefixIcon: Icons.confirmation_number_outlined,
              keyboardType: TextInputType.number,
              controller: _referralMatriculaController,
              enabled: !widget.isRecoveringPassword,
              validator: _validateReferralMatricula,
            ),
            const SizedBox(height: AppDimensions.spacing24),
            AppButton(
              label: 'Solicitar clave temporal',
              icon: Icons.key_outlined,
              width: double.infinity,
              isLoading: widget.isRecoveringPassword,
              onPressed: widget.isRecoveringPassword ? null : _submit,
            ),
            const SizedBox(height: AppDimensions.spacing12),
            Center(
              child: TextButton(
                onPressed: widget.isRecoveringPassword
                    ? null
                    : widget.onBackToLogin,
                child: const Text('Volver al login'),
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
      referralMatricula: _referralMatriculaController.text.trim(),
    );
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
}
