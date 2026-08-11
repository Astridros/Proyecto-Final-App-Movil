import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../auth/presentation/providers/auth_session_providers.dart';
import '../providers/profile_presentation_providers.dart';
import '../widgets/profile_form.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final sessionProfile = ref.read(authSessionControllerProvider).profile;
      final controller = ref.read(profileControllerProvider.notifier);
      if (sessionProfile != null) {
        controller.setProfile(sessionProfile);
        return;
      }

      controller.loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (state.isInitialLoading && !state.hasProfile) {
              return const AppLoading(message: 'Cargando perfil...');
            }

            if (state.error != null && !state.hasProfile) {
              return AppErrorView(
                title: 'No pudimos cargar tu perfil',
                message: state.error!.message,
                onRetry: controller.loadProfile,
              );
            }

            final profile = state.profile;
            if (profile == null) {
              return AppErrorView(
                title: 'Perfil no disponible',
                message: 'Intenta cargar tu perfil nuevamente.',
                onRetry: controller.loadProfile,
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.screenHorizontalPadding,
                AppDimensions.spacing24,
                AppDimensions.screenHorizontalPadding,
                AppDimensions.spacing24 +
                    MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Perfil',
                        style: AppTextStyles.headingMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing8),
                      Text(
                        'Completa tus datos personales para continuar.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing20),
                      ProfileForm(
                        profile: profile,
                        isSubmitting: state.isSubmitting,
                        errorMessage: state.error?.message,
                        onSubmit:
                            ({
                              required firstName,
                              required lastName,
                              required cedula,
                              required gender,
                              required birthDate,
                              email,
                              referralMatricula,
                            }) async {
                              final success = await controller.submitProfile(
                                firstName: firstName,
                                lastName: lastName,
                                cedula: cedula,
                                gender: gender,
                                birthDate: birthDate,
                              );

                              if (success && context.mounted) {
                                final updatedProfile = ref
                                    .read(profileControllerProvider)
                                    .profile;
                                if (updatedProfile != null) {
                                  ref
                                      .read(
                                        authSessionControllerProvider.notifier,
                                      )
                                      .updateAuthenticatedProfile(
                                        updatedProfile,
                                      );
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Perfil actualizado correctamente',
                                    ),
                                  ),
                                );
                                GoRouter.maybeOf(
                                  context,
                                )?.go(RouteNames.initialPath);
                              }

                              return success;
                            },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
