import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';

class Ocupa2Logo extends StatelessWidget {
  const Ocupa2Logo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const logoSize = AppDimensions.buttonHeight;

    return Semantics(
      label: 'Logo Ocupa2',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: logoSize,
            height: logoSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.18),
                  blurRadius: AppDimensions.spacing16,
                  offset: const Offset(0, AppDimensions.spacing8),
                ),
              ],
            ),
            child: Text(
              'O',
              style: AppTextStyles.headingMedium.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacing12),
          Text(
            'Ocupa2',
            style: AppTextStyles.headingMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
