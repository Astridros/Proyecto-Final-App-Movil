import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_button.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: AppDimensions.iconLarge,
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.title,
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.spacing24),
              AppButton(label: 'Reintentar', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
