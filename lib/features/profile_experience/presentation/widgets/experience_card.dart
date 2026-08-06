import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/experience.dart';
import '../providers/experience_presentation_providers.dart';

class ExperienceCard extends ConsumerWidget {
  const ExperienceCard({
    super.key,
    required this.experience,
  });

  final Experience experience;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  experience.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                tooltip: 'Eliminar experiencia',
                onPressed: () async {
                  final confirmar = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Eliminar experiencia'),
                        content: const Text(
                          '¿Deseas eliminar esta experiencia?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text('Eliminar'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmar != true) return;

                  try {
                    await ref
                        .read(
                          experienceControllerProvider.notifier,
                        )
                        .deleteExperience(
                          experience.id,
                        );

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Experiencia eliminada correctamente.',
                        ),
                      ),
                    );
                  } catch (_) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No se pudo eliminar la experiencia.',
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(experience.description),

          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(
                Icons.work_outline,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(experience.jobTypeKey),
              ),
            ],
          ),

          if (experience.certificateImage.isNotEmpty) ...[
            const SizedBox(height: 16),

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                experience.certificateImage,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    height: 180,
                    alignment: Alignment.center,
                    child: const Text(
                      'No se pudo cargar la imagen',
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}