import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading.dart';

class OffersPlaceholderScreen extends StatefulWidget {
  const OffersPlaceholderScreen({super.key});

  @override
  State<OffersPlaceholderScreen> createState() =>
      _OffersPlaceholderScreenState();
}

class _OffersPlaceholderScreenState extends State<OffersPlaceholderScreen> {
  _OfferDemoMode _mode = _OfferDemoMode.examples;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenHorizontalPadding,
            vertical: AppDimensions.spacing16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Explorar ofertas', style: AppTextStyles.headingLarge),
              const SizedBox(height: AppDimensions.spacing8),
              Text(
                'Ejemplos visuales temporales. Estos datos no provienen del API.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing16),
              _OfferModeChips(
                selectedMode: _mode,
                onSelected: (mode) => setState(() => _mode = mode),
              ),
              const SizedBox(height: AppDimensions.spacing20),
              Expanded(child: _OffersDemoContent(mode: _mode)),
              const SizedBox(height: AppDimensions.spacing12),
              AppButton.outlined(
                label: 'Volver',
                icon: Icons.arrow_back_rounded,
                onPressed: context.pop,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferModeChips extends StatelessWidget {
  const _OfferModeChips({required this.selectedMode, required this.onSelected});

  final _OfferDemoMode selectedMode;
  final ValueChanged<_OfferDemoMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.spacing8,
      runSpacing: AppDimensions.spacing8,
      children: _OfferDemoMode.values
          .map((mode) {
            final selected = mode == selectedMode;

            return ChoiceChip(
              label: Text(mode.label),
              avatar: Icon(mode.icon, size: AppDimensions.iconSmall),
              selected: selected,
              onSelected: (_) => onSelected(mode),
              showCheckmark: true,
            );
          })
          .toList(growable: false),
    );
  }
}

class _OffersDemoContent extends StatelessWidget {
  const _OffersDemoContent({required this.mode});

  final _OfferDemoMode mode;

  @override
  Widget build(BuildContext context) {
    return switch (mode) {
      _OfferDemoMode.examples => ListView.separated(
        itemCount: _demoOffers.length,
        separatorBuilder: (_, _) =>
            const SizedBox(height: AppDimensions.spacing12),
        itemBuilder: (context, index) =>
            _OfferDemoCard(offer: _demoOffers[index]),
      ),
      _OfferDemoMode.loading => const AppLoading(
        message: 'Estado de carga demostrativo.',
      ),
      _OfferDemoMode.empty => const AppEmptyState(
        icon: Icons.work_off_outlined,
        title: 'Sin ofertas para mostrar',
        description: 'Estado vacío provisional para validar el componente.',
      ),
    };
  }
}

class _OfferDemoCard extends StatelessWidget {
  const _OfferDemoCard({required this.offer});

  final _OfferDemo offer;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy').format(offer.date);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(offer.title, style: AppTextStyles.title)),
              const SizedBox(width: AppDimensions.spacing12),
              Chip(label: Text(offer.badge)),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            offer.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          Wrap(
            spacing: AppDimensions.spacing8,
            runSpacing: AppDimensions.spacing8,
            children: [
              _MetaChip(icon: Icons.place_outlined, label: offer.location),
              _MetaChip(icon: Icons.calendar_today_outlined, label: date),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: AppDimensions.iconSmall),
      label: Text(label),
    );
  }
}

enum _OfferDemoMode {
  examples('Ejemplos', Icons.view_agenda_outlined),
  loading('Carga', Icons.hourglass_empty_rounded),
  empty('Vacío', Icons.inbox_outlined);

  const _OfferDemoMode(this.label, this.icon);

  final String label;
  final IconData icon;
}

// Datos temporales de diseño; se eliminarán cuando se integren ofertas desde Swagger.
class _OfferDemo {
  const _OfferDemo({
    required this.title,
    required this.description,
    required this.location,
    required this.badge,
    required this.date,
  });

  final String title;
  final String description;
  final String location;
  final String badge;
  final DateTime date;
}

final _demoOffers = [
  _OfferDemo(
    title: 'Asistencia en evento universitario',
    description: 'Tarjeta de ejemplo para revisar jerarquía visual y espacio.',
    location: 'Ejemplo visual',
    badge: 'Demo',
    date: DateTime(2026, 7, 22),
  ),
  _OfferDemo(
    title: 'Soporte temporal en inventario',
    description: 'Segundo ejemplo visual para comparar tarjetas y chips.',
    location: 'Ejemplo visual',
    badge: 'Demo',
    date: DateTime(2026, 7, 24),
  ),
];
