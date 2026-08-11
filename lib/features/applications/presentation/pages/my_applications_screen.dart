import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/application.dart';
import '../controllers/my_applications_provider.dart';

class MyApplicationsScreen extends ConsumerStatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  ConsumerState<MyApplicationsScreen> createState() =>
      _MyApplicationsScreenState();
}

class _MyApplicationsScreenState
    extends ConsumerState<MyApplicationsScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(myApplicationsControllerProvider.notifier)
          .load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state =
    ref.watch(myApplicationsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis aplicaciones'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            return ref
                .read(
              myApplicationsControllerProvider.notifier,
            )
                .refresh();
          },
          child: Builder(
            builder: (context) {
              if (state.isLoading &&
                  state.applications.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state.error != null &&
                  state.applications.isEmpty) {
                return ListView(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(
                    AppDimensions.spacing24,
                  ),
                  children: [
                    const SizedBox(height: 100),
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 60,
                      color: AppColors.error,
                    ),
                    const SizedBox(
                      height: AppDimensions.spacing16,
                    ),
                    Text(
                      'No se pudieron cargar tus aplicaciones.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headingSmall,
                    ),
                    const SizedBox(
                      height: AppDimensions.spacing8,
                    ),
                    Text(
                      state.error!.message,
                      textAlign: TextAlign.center,
                      style:
                      AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(
                      height: AppDimensions.spacing24,
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        ref
                            .read(
                          myApplicationsControllerProvider
                              .notifier,
                        )
                            .load();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                );
              }

              if (state.applications.isEmpty) {
                return ListView(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(
                    AppDimensions.spacing24,
                  ),
                  children: [
                    const SizedBox(height: 100),
                    Icon(
                      Icons.assignment_outlined,
                      size: 70,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(
                      height: AppDimensions.spacing20,
                    ),
                    Text(
                      'Aún no tienes aplicaciones',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headingSmall,
                    ),
                    const SizedBox(
                      height: AppDimensions.spacing8,
                    ),
                    Text(
                      'Cuando te postules a una oferta, '
                          'aparecerá en esta sección.',
                      textAlign: TextAlign.center,
                      style:
                      AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(
                      height: AppDimensions.spacing24,
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        context.pushNamed(
                          RouteNames.offers,
                        );
                      },
                      icon:
                      const Icon(Icons.work_outline),
                      label:
                      const Text('Explorar ofertas'),
                    ),
                  ],
                );
              }

              return ListView.separated(
                physics:
                const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal:
                  AppDimensions.screenHorizontalPadding,
                  vertical: AppDimensions.spacing16,
                ),
                itemCount: state.applications.length,
                separatorBuilder: (_, _) =>
                const SizedBox(
                  height: AppDimensions.spacing12,
                ),
                itemBuilder: (context, index) {
                  final application =
                  state.applications[index];

                  return _ApplicationCard(
                    application: application,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.application,
  });

  final Application application;

  @override
  Widget build(BuildContext context) {
    final offer = application.offer;

    final title =
    offer?.jobTypeName.trim().isNotEmpty == true
        ? offer!.jobTypeName
        : 'Oferta de empleo';

    final address =
    offer?.address.trim().isNotEmpty == true
        ? offer!.address
        : 'Ubicación no disponible';

    final description =
    offer?.description.trim().isNotEmpty == true
        ? offer!.description
        : null;

    return InkWell(
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusLarge,
      ),
      onTap: () {
        if (application.offerId.trim().isEmpty) {
          return;
        }

        context.pushNamed(
          RouteNames.offerDetail,
          pathParameters: {
            'id': application.offerId,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(
          AppDimensions.spacing16,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusLarge,
          ),
          border: Border.all(
            color: AppColors.border,
          ),
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
                    title,
                    style:
                    AppTextStyles.headingSmall,
                  ),
                ),
                const SizedBox(
                  width: AppDimensions.spacing8,
                ),
                _StatusBadge(
                  status: application.status,
                ),
              ],
            ),

            const SizedBox(
              height: AppDimensions.spacing16,
            ),

            _InfoRow(
              icon:
              Icons.location_on_outlined,
              text: address,
            ),

            if (description != null) ...[
              const SizedBox(
                height: AppDimensions.spacing8,
              ),
              Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style:
                AppTextStyles.bodyMedium.copyWith(
                  color:
                  AppColors.textSecondary,
                ),
              ),
            ],

            if (application.comment
                .trim()
                .isNotEmpty) ...[
              const SizedBox(
                height: AppDimensions.spacing12,
              ),
              Text(
                'Tu comentario',
                style: AppTextStyles.bodyMedium
                    .copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacing4,
              ),
              Text(
                application.comment,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                AppTextStyles.bodyMedium.copyWith(
                  color:
                  AppColors.textSecondary,
                ),
              ),
            ],

            const SizedBox(
              height: AppDimensions.spacing16,
            ),

            const Divider(),

            const SizedBox(
              height: AppDimensions.spacing8,
            ),

            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color:
                  AppColors.textSecondary,
                ),
                const SizedBox(
                  width: AppDimensions.spacing8,
                ),
                Expanded(
                  child: Text(
                    _applicationDate(
                      application.createdAt,
                    ),
                    style:
                    AppTextStyles.bodySmall.copyWith(
                      color:
                      AppColors.textSecondary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color:
                  AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _applicationDate(DateTime? date) {
    if (date == null) {
      return 'Fecha de aplicación no disponible';
    }

    return 'Aplicaste el '
        '${DateFormat('dd/MM/yyyy').format(date.toLocal())}';
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
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(
          width: AppDimensions.spacing8,
        ),
        Expanded(
          child: Text(
            text,
            style:
            AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized =
    status.trim().toLowerCase();

    String label;
    IconData icon;

    switch (normalized) {
      case 'approved':
      case 'accepted':
      case 'aceptada':
      case 'aceptado':
        label = 'Aceptada';
        icon = Icons.check_circle_outline;
        break;

      case 'rejected':
      case 'rechazada':
      case 'rechazado':
        label = 'Rechazada';
        icon = Icons.cancel_outlined;
        break;

      case 'cancelled':
      case 'canceled':
      case 'cancelada':
        label = 'Cancelada';
        icon = Icons.block_outlined;
        break;

      default:
        label = 'Pendiente';
        icon = Icons.schedule_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLarge,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style:
            AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}