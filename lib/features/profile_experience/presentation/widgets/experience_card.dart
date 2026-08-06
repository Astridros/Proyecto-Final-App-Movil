import 'package:flutter/material.dart';

import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/experience.dart';

class ExperienceCard extends StatelessWidget{
  const ExperienceCard({
    super.key,
    required this.experience,
  });

  final Experience experience;

  @override
  Widget build(BuildContext context){
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            experience.title,
            style: Theme.of(context).textTheme.titleMedium,
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

              Text(experience.jobTypeKey),
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
          ]
        ],
      ),
    );
  }
}