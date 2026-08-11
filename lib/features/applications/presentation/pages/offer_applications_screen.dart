import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/entities/application.dart';
import '../controllers/offer_applications_provider.dart';

class OfferApplicationsScreen extends ConsumerStatefulWidget {
  const OfferApplicationsScreen({
    super.key,
    required this.offerId,
  });

  final String offerId;

  @override
  ConsumerState<OfferApplicationsScreen> createState() =>
      _OfferApplicationsScreenState();
}

class _OfferApplicationsScreenState
    extends ConsumerState<OfferApplicationsScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) {
        return;
      }

      ref
          .read(
        offerApplicationsControllerProvider(
          widget.offerId,
        ).notifier,
      )
          .load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider =
    offerApplicationsControllerProvider(
      widget.offerId,
    );

    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Postulantes',
        ),
      ),
      body: SafeArea(
        child: state.isLoading &&
            state.applications.isEmpty
            ? const AppLoading(
          message:
          'Cargando postulantes...',
        )
            : RefreshIndicator(
          onRefresh: controller.refresh,
          child: _buildContent(
            context,
            state.applications,
            state.error?.message,
            state.isUpdating,
            state.updatingApplicationId,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      List<Application> applications,
      String? errorMessage,
      bool isUpdating,
      String? updatingApplicationId,
      ) {
    if (errorMessage != null &&
        applications.isEmpty) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        children: [
          AppErrorView(
            title:
            'No fue posible cargar los postulantes',
            message: errorMessage,
          ),
        ],
      );
    }

    if (applications.isEmpty) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding:
        const EdgeInsets.symmetric(
          horizontal:
          AppDimensions
              .screenHorizontalPadding,
        ),
        children: const [
          AppEmptyState(
            icon: Icons.people_outline,
            title:
            'Aún no hay postulantes',
            description:
            'Cuando alguien aplique a esta oferta aparecerá aquí.',
          ),
        ],
      );
    }

    return ListView.separated(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding:
      const EdgeInsets.symmetric(
        horizontal:
        AppDimensions
            .screenHorizontalPadding,
        vertical:
        AppDimensions.spacing16,
      ),
      itemCount: applications.length,
      separatorBuilder: (_, _) =>
      const SizedBox(
        height:
        AppDimensions.spacing16,
      ),
      itemBuilder: (
          context,
          index,
          ) {
        final application =
        applications[index];

        return _ApplicationCard(
          offerId: widget.offerId,
          application: application,
          isUpdating:
          isUpdating &&
              updatingApplicationId ==
                  application.id,
        );
      },
    );
  }
}

class _ApplicationCard
    extends ConsumerWidget {
  const _ApplicationCard({
    required this.offerId,
    required this.application,
    required this.isUpdating,
  });

  final String offerId;
  final Application application;
  final bool isUpdating;

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final controller = ref.read(
      offerApplicationsControllerProvider(
        offerId,
      ).notifier,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.spacing16,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(
                    Icons.person_outline,
                  ),
                ),
                const SizedBox(
                  width:
                  AppDimensions
                      .spacing12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      const Text(
                        'Postulante',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        'ID: ${application.applicantId}',
                        maxLines: 1,
                        overflow:
                        TextOverflow
                            .ellipsis,
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    _statusLabel(
                      application.status,
                    ),
                  ),
                ),
              ],
            ),

            if (application.comment
                .trim()
                .isNotEmpty) ...[
              const SizedBox(
                height:
                AppDimensions
                    .spacing16,
              ),
              const Text(
                'Comentario',
                style: TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                application.comment,
              ),
            ],

            if (application.answers
                .isNotEmpty) ...[
              const SizedBox(
                height:
                AppDimensions
                    .spacing16,
              ),
              const Text(
                'Respuestas',
                style: TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
              const SizedBox(
                height:
                AppDimensions
                    .spacing8,
              ),
              ...application.answers.map(
                    (answer) => Padding(
                  padding:
                  const EdgeInsets.only(
                    bottom: 4,
                  ),
                  child: Text(
                    '${answer.questionId}: ${answer.value}',
                  ),
                ),
              ),
            ],

            const SizedBox(
              height:
              AppDimensions
                  .spacing16,
            ),

            const Text(
              'Calificación',
              style: TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),

            Row(
              children: List.generate(
                5,
                    (index) {
                  final rating =
                      index + 1;

                  final currentRating =
                  application.rating
                  is num
                      ? (application.rating
                  as num)
                      .toInt()
                      : 0;

                  return IconButton(
                    tooltip:
                    '$rating estrellas',
                    onPressed:
                    isUpdating
                        ? null
                        : () async {
                      await controller
                          .updateRating(
                        applicationId:
                        application
                            .id,
                        rating:
                        rating,
                      );
                    },
                    icon: Icon(
                      rating <=
                          currentRating
                          ? Icons.star
                          : Icons.star_border,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(
              height:
              AppDimensions
                  .spacing12,
            ),

            if (isUpdating)
              const Center(
                child:
                CircularProgressIndicator(),
              )
            else
              Wrap(
                spacing:
                AppDimensions.spacing8,
                runSpacing:
                AppDimensions.spacing8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      _changeStatus(
                        context,
                        controller,
                        'discarded',
                      );
                    },
                    icon: const Icon(
                      Icons.person_remove_outlined,
                    ),
                    label: const Text(
                      'Descartar',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      _changeStatus(
                        context,
                        controller,
                        'finalist',
                      );
                    },
                    icon: const Icon(
                      Icons.star_outline,
                    ),
                    label: const Text(
                      'Finalista',
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      _changeStatus(
                        context,
                        controller,
                        'winner',
                      );
                    },
                    icon: const Icon(
                      Icons.emoji_events_outlined,
                    ),
                    label: const Text(
                      'Ganador',
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeStatus(
      BuildContext context,
      dynamic controller,
      String status,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (
          dialogContext,
          ) {
        return AlertDialog(
          title: const Text(
            'Confirmar acción',
          ),
          content: Text(
            '¿Deseas marcar este postulante como ${_statusLabel(status)}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancelar',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Confirmar',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final success =
    await controller.updateStatus(
      applicationId: application.id,
      status: status,
    );

    if (!context.mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Postulante actualizado a ${_statusLabel(status)}.',
          ),
        ),
      );
    }
  }

  String _statusLabel(
      String status,
      ) {
    switch (
    status.trim().toLowerCase()) {
      case 'winner':
        return 'Ganador';

      case 'finalist':
        return 'Finalista';

      case 'discarded':
        return 'Descartado';

      case 'applied':
        return 'Aplicado';

      default:
        return status;
    }
  }
}