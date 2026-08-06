import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/auth_form_providers.dart';
import '../widgets/forgot_password_form.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key, this.onBackToLogin});

  final VoidCallback? onBackToLogin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authFormControllerProvider);
    final controller = ref.read(authFormControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppDimensions.screenHorizontalPadding,
            AppDimensions.spacing24,
            AppDimensions.screenHorizontalPadding,
            AppDimensions.spacing24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ocupa2',
                    style: AppTextStyles.headingMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                  Text(
                    'Solicita una clave temporal para volver a acceder a tu cuenta.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing20),
                  ForgotPasswordForm(
                    isRecoveringPassword: state.isRecoveringPassword,
                    errorMessage: state.error?.message,
                    successMessage: state.successMessage,
                    onBackToLogin: onBackToLogin,
                    onSubmit:
                        ({
                          required String email,
                          required String referralMatricula,
                        }) {
                          return controller.forgotPassword(
                            email: email,
                            referralMatricula: referralMatricula,
                          );
                        },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
