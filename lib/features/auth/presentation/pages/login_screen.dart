import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/widgets/ocupa2_logo.dart';
import '../providers/auth_form_providers.dart';
import '../widgets/login_form.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key, this.onForgotPassword, this.onRegister});

  final VoidCallback? onForgotPassword;
  final VoidCallback? onRegister;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authFormControllerProvider);
    final controller = ref.read(authFormControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: _LoginBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.screenHorizontalPadding,
                AppDimensions.spacing24,
                AppDimensions.screenHorizontalPadding,
                AppDimensions.spacing24 +
                    MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Ocupa2Logo(key: Key('loginLogoHeader')),
                      ),
                      const SizedBox(height: AppDimensions.spacing20),
                      LoginForm(
                        isLoggingIn: state.isLoggingIn,
                        errorMessage: state.error?.message,
                        onForgotPassword: onForgotPassword,
                        onRegister: onRegister,
                        onSubmit:
                            ({
                              required String email,
                              required String password,
                            }) {
                              return controller.login(
                                email: email,
                                password: password,
                              );
                            },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            left: -90,
            child: _SoftGradientShape(color: AppColors.primary, size: 230),
          ),
          Positioned(
            right: -110,
            bottom: 120,
            child: _SoftGradientShape(color: AppColors.accent, size: 260),
          ),
          Positioned(
            right: 36,
            top: 72,
            child: _SoftGradientShape(color: AppColors.secondary, size: 120),
          ),
        ],
      ),
    );
  }
}

class _SoftGradientShape extends StatelessWidget {
  const _SoftGradientShape({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.16), color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
