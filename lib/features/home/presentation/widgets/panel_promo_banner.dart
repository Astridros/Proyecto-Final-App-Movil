import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';

// Yeison Familia - modulo Inicio.
// El modelo de diseno traia un banner "Premium Insight" vendiendo una
// suscripcion que no existe en Ocupa2. Se cambia por el mensaje de
// bienvenida (antes era la primera lamina del slider de Inicio) mas la
// invitacion directa a explorar ofertas.
class PanelPromoBanner extends StatelessWidget {
  const PanelPromoBanner({super.key, required this.onExploreOffers});

  final VoidCallback onExploreOffers;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacing20),
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
          const SizedBox(height: AppDimensions.spacing12),
          Text(
            'Bienvenido a Ocupa2',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.surface,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing4),
          Text(
            'La plataforma donde se conectan quienes necesitan resolver un '
            'trabajo y quienes saben hacerlo.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.surface.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.primaryDark,
            ),
            onPressed: onExploreOffers,
            child: const Text('Ver ofertas'),
          ),
        ],
      ),
    );
  }
}
