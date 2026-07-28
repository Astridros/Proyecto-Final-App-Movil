import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/constants/contract_types.dart';
import '../../domain/entities/offer.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer, this.onTap});

  final Offer offer;

  /// Callback externo para reutilizar la tarjeta en listados con navegación futura.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final location = _cleanText(offer.address);
    final salary = _salaryLabel;
    final deadline = _deadlineLabel;
    final description = _cleanText(offer.description);

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OfferImage(photo: offer.photo),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        offer.jobTypeName,
                        style: AppTextStyles.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacing12),
                    Chip(label: Text(_contractTypeLabel)),
                  ],
                ),
                if (location != null) ...[
                  const SizedBox(height: AppDimensions.spacing12),
                  _InfoRow(
                    icon: Icons.place_outlined,
                    label: location,
                    maxLines: 1,
                  ),
                ],
                if (salary != null) ...[
                  const SizedBox(height: AppDimensions.spacing8),
                  _InfoRow(icon: Icons.payments_outlined, label: salary),
                ],
                if (deadline != null) ...[
                  const SizedBox(height: AppDimensions.spacing8),
                  _InfoRow(
                    icon: Icons.event_available_outlined,
                    label: deadline,
                  ),
                ],
                if (description != null) ...[
                  const SizedBox(height: AppDimensions.spacing12),
                  Text(
                    description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _contractTypeLabel {
    return ContractTypes.labelFor(offer.contractType) ??
        (offer.contractType.trim().isEmpty ? 'Contrato' : offer.contractType);
  }

  String? get _salaryLabel {
    final currency = _cleanText(offer.payment.currency);
    final period = _cleanText(offer.payment.period);
    final amount = offer.payment.amount;
    if (amount <= 0 || currency == null) {
      return null;
    }

    final formattedAmount = NumberFormat('#,##0.##').format(amount);
    if (period == null) {
      return '$currency $formattedAmount';
    }

    return '$currency $formattedAmount · $period';
  }

  String? get _deadlineLabel {
    final deadline = offer.deadline;
    if (deadline == null) {
      return null;
    }

    return 'Fecha límite ${DateFormat('dd/MM/yyyy').format(deadline)}';
  }

  String? _cleanText(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') {
      return null;
    }

    return trimmed;
  }
}

class _OfferImage extends StatelessWidget {
  const _OfferImage({required this.photo});

  final String photo;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _validImageUrl(photo);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusLarge),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: imageUrl == null
            ? const _ImagePlaceholder()
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const _ImagePlaceholder();
                },
              ),
      ),
    );
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

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.surfaceSoft),
      child: Center(
        child: Icon(
          Icons.work_outline_rounded,
          color: AppColors.primary,
          size: AppDimensions.iconLarge,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, this.maxLines = 1});

  final IconData icon;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppDimensions.iconSmall,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppDimensions.spacing8),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
