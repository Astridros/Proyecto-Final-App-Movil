import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenHorizontalPadding,
            vertical: AppDimensions.spacing24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BrandHeader(),
              const SizedBox(height: AppDimensions.spacing24),
              const _GradientPanel(),
              const SizedBox(height: AppDimensions.spacing24),
              Text('Base provisional', style: AppTextStyles.headingSmall),
              const SizedBox(height: AppDimensions.spacing12),
              Text(
                'Esta pantalla permite revisar el tema, los componentes '
                'compartidos y la navegación inicial del proyecto.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing24),
              AppButton.outlined(
                label: 'Explorar ofertas',
                icon: Icons.work_outline_rounded,
                onPressed: () => context.pushNamed(RouteNames.offers),
                width: double.infinity,
              ),
              const SizedBox(height: AppDimensions.spacing12),
              // Angel Daniel Genao 2024-1169: accesos a Noticias y Videos.
              AppButton.outlined(
                label: 'Ver noticias',
                icon: Icons.newspaper_outlined,
                onPressed: () => context.pushNamed(RouteNames.news),
                width: double.infinity,
              ),
              const SizedBox(height: AppDimensions.spacing12),
              AppButton.outlined(
                label: 'Ver videos',
                icon: Icons.smart_display_outlined,
                onPressed: () => context.pushNamed(RouteNames.videos),
                width: double.infinity,
              ),
              const SizedBox(height: AppDimensions.spacing12),
              AppButton.outlined(
                label: 'Cambiar contraseña',
                icon: Icons.admin_panel_settings_outlined,
                onPressed: () => context.pushNamed(RouteNames.changePassword),
                width: double.infinity,
              ),
              const SizedBox(height: AppDimensions.spacing24),
              const AppCard(
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.secondary,
                      size: AppDimensions.iconMedium,
                    ),
                    SizedBox(width: AppDimensions.spacing12),
                    Expanded(
                      child: Text(
                        'No se están consumiendo endpoints en esta etapa.',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ocupa2', style: AppTextStyles.display),
        const SizedBox(height: AppDimensions.spacing8),
        Text(
          'Trabajos temporales organizados en una experiencia móvil limpia '
          'y consistente para el equipo.',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _GradientPanel extends StatelessWidget {
  const _GradientPanel();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Panel visual provisional de Ocupa2',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing20,
          vertical: AppDimensions.spacing16,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.handshake_outlined,
              color: AppColors.surface,
              size: AppDimensions.iconLarge,
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              'Arquitectura lista para crecer',
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.surface,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              'Features separadas, tema compartido y rutas centralizadas.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.surface.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
