import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/constants/contract_types.dart';
import '../../domain/entities/offer.dart';
import '../../domain/entities/offer_question.dart';
import '../providers/offer_detail_providers.dart';
import '../providers/offer_like_providers.dart';
import '../widgets/apply_offer_form.dart';

class OfferDetailScreen extends ConsumerStatefulWidget {
  const OfferDetailScreen({super.key, required this.offerId});

  final String offerId;

  @override
  ConsumerState<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends ConsumerState<OfferDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Se ejecuta una sola vez por instancia para evitar recargas al reconstruir.
    Future.microtask(() {
      if (!mounted) {
        return;
      }

      ref
          .read(offerDetailControllerProvider(widget.offerId).notifier)
          .loadOffer();
    });
  }

  @override
  void didUpdateWidget(covariant OfferDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offerId == widget.offerId) {
      return;
    }

    Future.microtask(() {
      if (!mounted) {
        return;
      }

      ref
          .read(offerDetailControllerProvider(widget.offerId).notifier)
          .loadOffer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = offerDetailControllerProvider(widget.offerId);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final offer = state.offer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de oferta'),
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (state.isInitialLoading && offer == null) {
              return const AppLoading(message: 'Cargando oferta...');
            }

            if (state.error != null && offer == null) {
              return AppErrorView(
                title: 'No fue posible cargar la oferta',
                message: state.error!.message,
                onRetry: () => controller.loadOffer(widget.offerId),
              );
            }

            if (offer == null) {
              return AppErrorView(
                title: 'Oferta no disponible',
                message: 'No encontramos informacion para esta oferta.',
                onRetry: () => controller.loadOffer(widget.offerId),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(
                AppDimensions.screenHorizontalPadding,
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _OfferHeader(offer: offer),
                  const SizedBox(height: AppDimensions.spacing16),
                  _OfferInfoSection(offer: offer),
                  const SizedBox(height: AppDimensions.spacing16),
                  _OfferQuestionsPreview(questions: offer.questions),
                  const SizedBox(height: AppDimensions.spacing16),
                  ApplyOfferForm(
                    key: ValueKey<String>(offer.id),
                    offer: offer,
                    isSubmitting: state.isSubmitting,
                    error: state.error,
                    successMessage: state.successMessage,
                    hasAlreadyApplied: state.hasAlreadyApplied,
                    existingApplicationStatus:
                        state.existingApplication?.status,
                    onSubmit: (comment, answers) {
                      return controller.apply(
                        comment: comment,
                        answers: answers,
                      );
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacing24),
                  AppButton.outlined(
                    label: 'Volver',
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OfferHeader extends StatelessWidget {
  const _OfferHeader({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
                Wrap(
                  spacing: AppDimensions.spacing8,
                  runSpacing: AppDimensions.spacing8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Chip(label: Text(_contractTypeLabel(offer.contractType))),
                    Chip(label: Text(_cleanText(offer.status) ?? 'Estado')),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacing12),
                Text(offer.jobTypeName, style: AppTextStyles.headingMedium),
                const SizedBox(height: AppDimensions.spacing12),
                Text(
                  offer.description,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (_isExpired(offer.deadline)) ...[
                  const SizedBox(height: AppDimensions.spacing16),
                  const _WarningBanner(
                    message: 'La fecha limite de esta oferta ya vencio.',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferInfoSection extends StatelessWidget {
  const _OfferInfoSection({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final address = _cleanText(offer.address);
    final payment = _paymentLabel(offer);
    final deadline = offer.deadline == null
        ? null
        : DateFormat('dd/MM/yyyy').format(offer.deadline!);
    final customAnswers = _usefulCustomAnswers(offer.customAnswers);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.info_outline_rounded,
            title: 'Informacion',
          ),
          if (address != null) ...[
            const SizedBox(height: AppDimensions.spacing12),
            _InfoRow(icon: Icons.place_outlined, label: address),
          ],
          if (payment != null) ...[
            const SizedBox(height: AppDimensions.spacing12),
            _InfoRow(icon: Icons.payments_outlined, label: payment),
          ],
          if (deadline != null) ...[
            const SizedBox(height: AppDimensions.spacing12),
            _InfoRow(
              icon: Icons.event_available_outlined,
              label: 'Fecha limite $deadline',
            ),
          ],
          const SizedBox(height: AppDimensions.spacing12),
          _InfoRow(
            icon: Icons.group_outlined,
            label: '${offer.applicantsCount} aplicantes',
          ),
          const SizedBox(height: AppDimensions.spacing12),
          _OfferLikeInfoRow(offer: offer),
          if (customAnswers.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacing16),
            ...customAnswers.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacing8),
                child: _InfoRow(
                  icon: Icons.notes_outlined,
                  label: '${entry.key}: ${entry.value}',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OfferQuestionsPreview extends StatelessWidget {
  const _OfferQuestionsPreview({required this.questions});

  final List<OfferQuestion> questions;

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              icon: Icons.quiz_outlined,
              title: 'Preguntas adicionales',
            ),
            SizedBox(height: AppDimensions.spacing12),
            Text(
              'Esta oferta no tiene preguntas adicionales.',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.quiz_outlined,
            title: 'Preguntas adicionales',
          ),
          const SizedBox(height: AppDimensions.spacing12),
          ...questions.map(
            (question) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacing8),
              child: Text(
                question.required ? '${question.label} *' : question.label,
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
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
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: AppColors.surfaceSoft),
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

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing12),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            const SizedBox(width: AppDimensions.spacing8),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: AppDimensions.spacing8),
        Expanded(child: Text(title, style: AppTextStyles.title)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _OfferLikeInfoRow extends ConsumerStatefulWidget {
  const _OfferLikeInfoRow({required this.offer});

  final Offer offer;

  @override
  ConsumerState<_OfferLikeInfoRow> createState() => _OfferLikeInfoRowState();
}

class _OfferLikeInfoRowState extends ConsumerState<_OfferLikeInfoRow> {
  @override
  void initState() {
    super.initState();
    _syncFromOffer();
  }

  @override
  void didUpdateWidget(covariant _OfferLikeInfoRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offer.id != widget.offer.id ||
        oldWidget.offer.likedByMe != widget.offer.likedByMe ||
        oldWidget.offer.likesCount != widget.offer.likesCount) {
      _syncFromOffer();
    }
  }

  void _syncFromOffer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ref
          .read(offerLikeControllerProvider(widget.offer.id).notifier)
          .syncFromOffer(
            likedByMe: widget.offer.likedByMe,
            likesCount: widget.offer.likesCount,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = offerLikeControllerProvider(widget.offer.id);
    final likeState = ref.watch(provider);
    final tooltip = likeState.liked ? 'Quitar me gusta' : 'Dar me gusta';

    ref.listen(provider, (previous, next) {
      final error = next.error;
      if (error == null || previous?.error == error) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    });

    return Row(
      children: [
        Tooltip(
          message: tooltip,
          child: IconButton(
            onPressed: likeState.isSubmitting
                ? null
                : () => ref.read(provider.notifier).toggleLike(),
            icon: Icon(
              likeState.liked
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: likeState.liked
                  ? AppColors.error
                  : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacing8),
        Expanded(
          child: Text(
            '${likeState.likesCount.clamp(0, 1 << 31)} me gusta',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

String _contractTypeLabel(String value) {
  return ContractTypes.labelFor(value) ??
      (value.trim().isEmpty ? 'Contrato' : value.trim());
}

String? _paymentLabel(Offer offer) {
  final amount = offer.payment.amount;
  final currency = _cleanText(offer.payment.currency);
  final period = _cleanText(offer.payment.period);
  if (amount <= 0 || currency == null) {
    return null;
  }

  final formattedAmount = NumberFormat('#,##0.##').format(amount);
  if (period == null) {
    return '$currency $formattedAmount';
  }

  return '$currency $formattedAmount - $period';
}

Map<String, String> _usefulCustomAnswers(Map<String, Object?> values) {
  final result = <String, String>{};
  for (final entry in values.entries) {
    final key = _cleanText(entry.key);
    final value = _cleanText(entry.value?.toString() ?? '');
    if (key != null && value != null) {
      result[key] = value;
    }
  }

  return result;
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

String? _cleanText(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') {
    return null;
  }

  return trimmed;
}

bool _isExpired(DateTime? deadline) {
  if (deadline == null) {
    return false;
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final limit = DateTime(deadline.year, deadline.month, deadline.day);
  return limit.isBefore(today);
}
