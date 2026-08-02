// Angel Daniel Genao 2024-1169
// Lista de tarjetas "esqueleto" (skeleton loading) que se muestra mientras
// se espera la primera respuesta de una API. Da la sensación de carga
// moderna en vez de solo un spinner. Reutilizable por cualquier feature
// que liste tarjetas de imagen + texto (Noticias, Videos, etc.).

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';

class AppSkeletonList extends StatelessWidget {
  const AppSkeletonList({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceSoft,
      highlightColor: AppColors.surface,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) => const _SkeletonCard(),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusLarge),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonLine(width: double.infinity),
                const SizedBox(height: AppDimensions.spacing8),
                _SkeletonLine(width: 160),
                const SizedBox(height: AppDimensions.spacing12),
                _SkeletonLine(width: double.infinity),
                const SizedBox(height: AppDimensions.spacing8),
                _SkeletonLine(width: 220),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
    );
  }
}
