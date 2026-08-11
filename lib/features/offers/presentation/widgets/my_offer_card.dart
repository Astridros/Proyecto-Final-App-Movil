import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/constants/contract_types.dart';
import '../../domain/entities/offer.dart';

class MyOfferCard extends StatelessWidget {
  const MyOfferCard({
    super.key,
    required this.offer,
    this.onTap,
  });

  final Offer offer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.spacing16,
      ),
      child: AppCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _OfferImage(
              photo: offer.photo,
            ),

            Padding(
              padding: const EdgeInsets.all(
                AppDimensions.spacing16,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          offer.jobTypeName,
                          style:
                          AppTextStyles.title,
                          maxLines: 2,
                          overflow:
                          TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(
                        width:
                        AppDimensions.spacing8,
                      ),
                      _StatusChip(
                        status: offer.status,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height:
                    AppDimensions.spacing12,
                  ),

                  Wrap(
                    spacing:
                    AppDimensions.spacing8,
                    runSpacing:
                    AppDimensions.spacing8,
                    children: [
                      Chip(
                        avatar: const Icon(
                          Icons.work_outline,
                          size: 18,
                        ),
                        label: Text(
                          _contractTypeLabel,
                        ),
                      ),
                      Chip(
                        avatar: const Icon(
                          Icons.groups_outlined,
                          size: 18,
                        ),
                        label: Text(
                          '${offer.applicantsCount} postulante${offer.applicantsCount == 1 ? '' : 's'}',
                        ),
                      ),
                    ],
                  ),

                  if (_cleanText(
                    offer.address,
                  ) !=
                      null) ...[
                    const SizedBox(
                      height:
                      AppDimensions.spacing12,
                    ),
                    _InfoRow(
                      icon:
                      Icons.place_outlined,
                      text: offer.address,
                    ),
                  ],

                  if (_paymentLabel !=
                      null) ...[
                    const SizedBox(
                      height:
                      AppDimensions.spacing8,
                    ),
                    _InfoRow(
                      icon:
                      Icons.payments_outlined,
                      text: _paymentLabel!,
                    ),
                  ],

                  if (offer.deadline !=
                      null) ...[
                    const SizedBox(
                      height:
                      AppDimensions.spacing8,
                    ),
                    _InfoRow(
                      icon: Icons
                          .event_available_outlined,
                      text:
                      'Fecha límite: ${DateFormat('dd/MM/yyyy').format(offer.deadline!.toLocal())}',
                    ),
                  ],

                  if (_cleanText(
                    offer.description,
                  ) !=
                      null) ...[
                    const SizedBox(
                      height:
                      AppDimensions.spacing12,
                    ),
                    Text(
                      offer.description,
                      style: AppTextStyles
                          .bodyMedium
                          .copyWith(
                        color: AppColors
                            .textSecondary,
                      ),
                      maxLines: 3,
                      overflow:
                      TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(
                    height:
                    AppDimensions.spacing16,
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons
                            .calendar_today_outlined,
                        size: 16,
                        color:
                        AppColors.textSecondary,
                      ),
                      const SizedBox(
                        width:
                        AppDimensions.spacing8,
                      ),
                      Expanded(
                        child: Text(
                          'Publicada el ${DateFormat('dd/MM/yyyy').format(offer.createdAt.toLocal())}',
                          style: AppTextStyles
                              .bodySmall
                              .copyWith(
                            color: AppColors
                                .textSecondary,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons
                            .arrow_forward_ios_rounded,
                        size: 16,
                        color:
                        AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _contractTypeLabel {
    return ContractTypes.labelFor(
      offer.contractType,
    ) ??
        (offer.contractType.trim().isEmpty
            ? 'Contrato'
            : offer.contractType);
  }

  String? get _paymentLabel {
    final currency = _cleanText(
      offer.payment.currency,
    );

    final period = _cleanText(
      offer.payment.period,
    );

    final amount =
        offer.payment.amount;

    if (amount <= 0 ||
        currency == null) {
      return null;
    }

    final formattedAmount =
    NumberFormat(
      '#,##0.##',
    ).format(amount);

    if (period == null) {
      return '$currency $formattedAmount';
    }

    return '$currency $formattedAmount · $period';
  }

  String? _cleanText(
      String value,
      ) {
    final trimmed = value.trim();

    if (trimmed.isEmpty ||
        trimmed.toLowerCase() ==
            'null') {
      return null;
    }

    return trimmed;
  }
}

class _OfferImage extends StatelessWidget {
  const _OfferImage({
    required this.photo,
  });

  final String photo;

  @override
  Widget build(BuildContext context) {
    final imageUrl =
    _validImageUrl(photo);

    return ClipRRect(
      borderRadius:
      const BorderRadius.vertical(
        top: Radius.circular(
          AppDimensions.radiusLarge,
        ),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: imageUrl == null
            ? const _ImagePlaceholder()
            : Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (
              context,
              error,
              stackTrace,
              ) {
            return const _ImagePlaceholder();
          },
        ),
      ),
    );
  }

  String? _validImageUrl(
      String value,
      ) {
    final trimmed = value.trim();

    if (trimmed.isEmpty ||
        trimmed.toLowerCase() ==
            'string') {
      return null;
    }

    final uri =
    Uri.tryParse(trimmed);

    if (uri == null ||
        !uri.hasScheme ||
        uri.host.isEmpty) {
      return null;
    }

    return trimmed;
  }
}

class _ImagePlaceholder
    extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
      ),
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
  const _InfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size:
          AppDimensions.iconSmall,
          color:
          AppColors.textSecondary,
        ),
        const SizedBox(
          width:
          AppDimensions.spacing8,
        ),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles
                .bodySmall
                .copyWith(
              color: AppColors
                  .textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        _label,
        style: AppTextStyles
            .bodySmall
            .copyWith(
          color: _foregroundColor,
          fontWeight:
          FontWeight.w600,
        ),
      ),
    );
  }

  String get _label {
    switch (
    status.toLowerCase().trim()) {
      case 'published':
        return 'Publicada';

      case 'closed':
        return 'Cerrada';

      case 'draft':
        return 'Borrador';

      case 'cancelled':
        return 'Cancelada';

      default:
        return status.isEmpty
            ? 'Sin estado'
            : status;
    }
  }

  Color get _backgroundColor {
    switch (
    status.toLowerCase().trim()) {
      case 'published':
        return AppColors.success
            .withValues(
          alpha: 0.10,
        );

      case 'cancelled':
        return AppColors.error
            .withValues(
          alpha: 0.10,
        );

      default:
        return AppColors.primary
            .withValues(
          alpha: 0.10,
        );
    }
  }

  Color get _foregroundColor {
    switch (
    status.toLowerCase().trim()) {
      case 'published':
        return AppColors.success;

      case 'cancelled':
        return AppColors.error;

      default:
        return AppColors.primary;
    }
  }
}