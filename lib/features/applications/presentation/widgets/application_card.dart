import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/application.dart';

class ApplicationCard extends StatelessWidget {
  const ApplicationCard({
    super.key,
    required this.application,
    this.onTap,
  });

  final Application application;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final offer = application.offer;

    final title = offer?.jobTypeName.trim().isNotEmpty == true
        ? offer!.jobTypeName
        : 'Oferta';

    final description =
        offer?.description.trim() ?? '';

    final address =
        offer?.address.trim() ?? '';

    final comment =
    application.comment.trim();

    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.spacing16,
      ),
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.title,
                  ),
                ),
                const SizedBox(
                  width: AppDimensions.spacing8,
                ),
                _StatusChip(
                  status: application.status,
                ),
              ],
            ),

            if (description.isNotEmpty) ...[
              const SizedBox(
                height: AppDimensions.spacing12,
              ),
              Text(
                description,
                style: AppTextStyles.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            if (offer != null) ...[
              const SizedBox(
                height: AppDimensions.spacing12,
              ),
              _InfoRow(
                icon: Icons.payments_outlined,
                text:
                '${offer.payment.amount} '
                    '${offer.payment.currency} '
                    '• ${offer.payment.period}',
              ),
            ],

            if (address.isNotEmpty) ...[
              const SizedBox(
                height: AppDimensions.spacing8,
              ),
              _InfoRow(
                icon: Icons.location_on_outlined,
                text: address,
              ),
            ],

            if (comment.isNotEmpty) ...[
              const SizedBox(
                height: AppDimensions.spacing12,
              ),
              Text(
                'Tu comentario',
                style: AppTextStyles.labelLarge,
              ),
              const SizedBox(
                height: AppDimensions.spacing4,
              ),
              Text(
                comment,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            if (application.createdAt != null) ...[
              const SizedBox(
                height: AppDimensions.spacing12,
              ),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                text:
                'Aplicaste el ${DateFormat('dd/MM/yyyy').format(application.createdAt!.toLocal())}',
              ),
            ],

            if (application.answers.isNotEmpty) ...[
              const SizedBox(
                height: AppDimensions.spacing12,
              ),
              Text(
                '${application.answers.length} respuestas enviadas',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
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
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(
          width: AppDimensions.spacing8,
        ),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
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
    final label = _getLabel();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getLabel() {
    switch (status.toLowerCase()) {
      case 'applied':
        return 'Aplicada';

      case 'accepted':
        return 'Aceptada';

      case 'rejected':
        return 'Rechazada';

      case 'cancelled':
        return 'Cancelada';

      default:
        return status.isEmpty
            ? 'Aplicada'
            : status;
    }
  }
}