import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../offers/domain/entities/offer.dart';

// Yeison Familia - modulo Inicio.
// Version compacta de la oferta para la lista del panel. La tarjeta completa
// (con descripcion, like, etc.) es de Astrid y vive en Explorar ofertas;
// aqui solo se necesita lo justo para reconocerla.
class OfferPreviewCard extends StatelessWidget {
  const OfferPreviewCard({super.key, required this.offer, this.onTap});

  final Offer offer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _validImageUrl(offer.photo);
    final salary = _salaryLabel;

    return Semantics(
      button: true,
      label: '${offer.jobTypeName}. ${salary ?? 'Sin salario indicado'}',
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.radiusLarge),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: imageUrl == null
                        ? const _PreviewPlaceholder(
                            icon: Icons.work_outline_rounded,
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const _PreviewPlaceholder(
                                icon: Icons.work_outline_rounded,
                              );
                            },
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacing12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.jobTypeName,
                        style: AppTextStyles.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.spacing4),
                      Text(
                        salary ?? 'Salario no indicado',
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? get _salaryLabel {
    final currency = offer.payment.currency.trim();
    final amount = offer.payment.amount;
    if (amount <= 0 || currency.isEmpty) {
      return null;
    }

    return '$currency ${NumberFormat('#,##0.##').format(amount)}';
  }

  String? _validImageUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'string') {
      return null;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return null;
    }

    return trimmed;
  }
}

class _PreviewPlaceholder extends StatelessWidget {
  const _PreviewPlaceholder({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.surfaceSoft),
      child: Center(
        child: Icon(icon, color: AppColors.primary, size: AppDimensions.iconLarge),
      ),
    );
  }
}
