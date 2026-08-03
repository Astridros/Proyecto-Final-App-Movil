import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/change_password_presentation_providers.dart';
import '../widgets/change_password_form.dart';

class ChangePasswordScreen extends ConsumerWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(changePasswordControllerProvider);
    final controller = ref.read(changePasswordControllerProvider.notifier);

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
                  TextButton.icon(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                        return;
                      }

                      context.goNamed(RouteNames.initial);
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Volver'),
                  ),
                  const SizedBox(height: AppDimensions.spacing12),
                  Text(
                    'Ocupa2',
                    style: AppTextStyles.headingMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                  Text(
                    'Actualiza la clave de acceso de tu cuenta de forma segura.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing20),
                  ChangePasswordForm(
                    isSubmitting: state.isSubmitting,
                    errorMessage: state.error?.message,
                    successMessage: state.successMessage,
                    onSubmit: ({required String password}) {
                      return controller.changePassword(password: password);
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
