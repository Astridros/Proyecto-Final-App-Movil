import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/payment.dart';

// Yeison Familia - modulo Mis Pagos.
class PaymentCard extends StatelessWidget {
  const PaymentCard({super.key, required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context) {
    final status = _StatusLabel.fromRaw(payment.status);
    final declineReason = payment.declineReason;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  payment.concept,
                  style: AppTextStyles.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing12),
              Text(
                '${payment.amount.toStringAsFixed(2)} ${payment.currency}',
                style: AppTextStyles.title,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing12),
          Wrap(
            spacing: AppDimensions.spacing8,
            runSpacing: AppDimensions.spacing8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _StatusChip(status: status),
              if (payment.cardLast4.isNotEmpty)
                _IconLabel(
                  icon: Icons.credit_card_outlined,
                  label: '•••• ${payment.cardLast4}',
                ),
            ],
          ),
          if (payment.createdAt != null) ...[
            const SizedBox(height: AppDimensions.spacing8),
            Text(_formatDate(payment.createdAt!), style: AppTextStyles.caption),
          ],
          if (declineReason != null && declineReason.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              declineReason,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }

  // Se arma a mano en vez de usar intl con locale, porque cargar los datos de
  // localizacion requiere inicializacion extra y aqui no hace falta.
  String _formatDate(DateTime date) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'a. m.' : 'p. m.';

    return '${date.day} de ${months[date.month - 1]} de ${date.year}, '
        '$hour12:$minute $period';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final _StatusLabel status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing12,
        vertical: AppDimensions.spacing4,
      ),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.caption.copyWith(color: status.color),
      ),
    );
  }
}

class _IconLabel extends StatelessWidget {
  const _IconLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppDimensions.iconSmall, color: AppColors.textSecondary),
        const SizedBox(width: AppDimensions.spacing4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _StatusLabel {
  const _StatusLabel(this.label, this.color);

  // El backend puede devolver el estado en ingles o en espanol; si llega algo
  // desconocido se muestra tal cual en vez de ocultarlo.
  factory _StatusLabel.fromRaw(String raw) {
    final normalized = raw.trim().toLowerCase();

    if (normalized.isEmpty) {
      return const _StatusLabel('Sin estado', AppColors.textSecondary);
    }

    if (['approved', 'aprobado', 'success', 'paid'].contains(normalized)) {
      return const _StatusLabel('Aprobado', AppColors.success);
    }

    if ([
      'declined',
      'rejected',
      'rechazado',
      'failed',
    ].contains(normalized)) {
      return const _StatusLabel('Rechazado', AppColors.error);
    }

    if (['pending', 'pendiente', 'processing'].contains(normalized)) {
      return const _StatusLabel('Pendiente', AppColors.warning);
    }

    return _StatusLabel(raw.trim(), AppColors.textSecondary);
  }

  final String label;
  final Color color;
}
