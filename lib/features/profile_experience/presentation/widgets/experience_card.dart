import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/experience.dart';
import '../providers/experience_presentation_providers.dart';

class ExperienceCard extends ConsumerWidget {
  const ExperienceCard({super.key, required this.experience});

  final Experience experience;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      onTap: () => _showExperienceDetails(context, experience),
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
                icon: const Icon(Icons.delete, color: Colors.red),
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
                        .read(experienceControllerProvider.notifier)
                        .deleteExperience(experience.id);

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Experiencia eliminada correctamente.'),
                      ),
                    );
                  } catch (_) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No se pudo eliminar la experiencia.'),
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
              const Icon(Icons.work_outline, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(experience.jobTypeKey)),
            ],
          ),

          if (experience.certificateImage.isNotEmpty) ...[
            const SizedBox(height: 16),

            Semantics(
              button: true,
              label: 'Ver certificado de ${experience.title}',
              child: GestureDetector(
                onTap: () => _showImageViewer(
                  context,
                  imageUrl: experience.certificateImage,
                  title: experience.title,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    experience.certificateImage,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) {
                      return Container(
                        height: 180,
                        alignment: Alignment.center,
                        child: const Text('No se pudo cargar la imagen'),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> _showExperienceDetails(
  BuildContext context,
  Experience experience,
) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(experience.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(experience.description),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.work_outline, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(experience.jobTypeKey)),
              ],
            ),
            if (experience.certificateImage.isNotEmpty) ...[
              const SizedBox(height: 20),
              InkWell(
                onTap: () => _showImageViewer(
                  context,
                  imageUrl: experience.certificateImage,
                  title: experience.title,
                ),
                borderRadius: BorderRadius.circular(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    experience.certificateImage,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox(
                      height: 120,
                      child: Center(child: Text('No se pudo cargar la imagen')),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Toca la imagen para ampliarla.'),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}

Future<void> _showImageViewer(
  BuildContext context, {
  required String imageUrl,
  required String title,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (context) => Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Text(
                  'No se pudo cargar la imagen',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                tooltip: 'Cerrar imagen',
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
