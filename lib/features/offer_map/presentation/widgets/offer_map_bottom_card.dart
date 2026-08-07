import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../offers/domain/entities/offer.dart';

class OfferMapBottomCard extends StatelessWidget {
  const OfferMapBottomCard({
    super.key,
    required this.offer,
    required this.onViewOffer,
    required this.onClose,
  });

  final Offer offer;
  final VoidCallback onViewOffer;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(offer.jobTypeName, style: AppTextStyles.title),
                ),
                IconButton(
                  tooltip: 'Cerrar',
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: AppDimensions.iconMedium,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppDimensions.spacing8),
                Expanded(
                  child: Text(
                    offer.address.trim().isEmpty
                        ? 'Ubicación no especificada'
                        : offer.address,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  size: AppDimensions.iconMedium,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppDimensions.spacing8),
                Expanded(
                  child: Text(_paymentText(), style: AppTextStyles.bodyMedium),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Row(
              children: [
                const Icon(
                  Icons.description_outlined,
                  size: AppDimensions.iconMedium,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppDimensions.spacing8),
                Expanded(
                  child: Text(
                    _contractTypeText(offer.contractType),
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing16),
            AppButton(
              label: 'Ver oferta',
              icon: Icons.arrow_forward_rounded,
              onPressed: onViewOffer,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  String _paymentText() {
    final formatter = NumberFormat('#,##0.##');
    final amount = formatter.format(offer.payment.amount);

    return '${offer.payment.currency} $amount · '
        '${_paymentPeriodText(offer.payment.period)}';
  }

  String _paymentPeriodText(String period) {
    switch (period.toLowerCase()) {
      case 'mensual':
        return 'Mensual';
      case 'semanal':
        return 'Semanal';
      case 'diario':
        return 'Diario';
      case 'hora':
      case 'horario':
        return 'Por hora';
      case 'total':
        return 'Pago total';
      default:
        return period;
    }
  }

  String _contractTypeText(String contractType) {
    switch (contractType.toLowerCase()) {
      case 'temporal':
        return 'Contrato temporal';
      case 'fijo':
        return 'Contrato fijo';
      default:
        return contractType;
    }
  }
}
