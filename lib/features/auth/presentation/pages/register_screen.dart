import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/auth_form_providers.dart';
import '../widgets/register_form.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key, this.onBackToLogin});

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
              constraints: const BoxConstraints(maxWidth: 560),
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
                    'Crea tu cuenta para acceder a ofertas temporales y gestionar tus postulaciones.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing20),
                  RegisterForm(
                    isRegistering: state.isRegistering,
                    errorMessage: state.error?.message,
                    onBackToLogin: onBackToLogin,
                    onSubmit:
                        ({
                          required String email,
                          required String firstName,
                          required String lastName,
                          required String password,
                          required String referralMatricula,
                        }) {
                          return controller.register(
                            email: email,
                            firstName: firstName,
                            lastName: lastName,
                            password: password,
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
