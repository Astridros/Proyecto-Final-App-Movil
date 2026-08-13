import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/team_member.dart';
import '../widgets/team_member_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const List<TeamMember> _teamMembers = [
    TeamMember(
      name: 'Alan De León',
      studentId: '2024-1114',
      phone: '+18493712002',
      telegramUrl: 'https://t.me/AlanRicardo',
      photoAsset: 'assets/images/team/alan.jpg',
    ),
    TeamMember(
      name: 'Astrid Rondón',
      studentId: '2024-1277',
      phone: '+18494782210',
      telegramUrl: 'https://web.telegram.org/a/#5026367095',
      photoAsset: 'assets/images/team/astrid.jpeg',
    ),
    TeamMember(
      name: 'Dailyn Castro',
      studentId: '2024-41343',
      phone: '+18296632875',
      telegramUrl: 'https://t.me/carlos_ejemplo',
      photoAsset: 'assets/images/team/dailyn_castro.jpeg',
    ),
    TeamMember(
      name: 'Yeison Rojas',
      studentId: '2024-1822',
      phone: '+18298019374',
      telegramUrl: 'https://t.me/carlos_ejemplo',
      photoAsset: 'assets/images/team/yeison_rojas.jpg',
    ),

    TeamMember(
      name: 'Angel Genao',
      studentId: '2024-1169',
      phone: '+18299109251',
      telegramUrl: 'https://t.me/carlos_ejemplo',
      photoAsset: 'assets/images/team/angel.jpeg',
    ),

    TeamMember(
      name: 'Anthony Urbaez',
      studentId: '2023-1394',
      phone: '+18498627678',
      telegramUrl: 'https://t.me/+18298572510',
      photoAsset: 'assets/images/team/anthony-urbaez.jpeg',
    ),
    TeamMember(
      name: 'Mauriandys Peguero',
      studentId: '2024-1672',
      phone: '+18496269556',
      telegramUrl: 'https://t.me/+18298572510',
      photoAsset: 'assets/images/team/mauriandys-peguero.jpeg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenHorizontalPadding,
            vertical: AppDimensions.spacing24,
          ),
          children: [
            Text(
              'Equipo de desarrollo',
              style: AppTextStyles.headingSmall,
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              'Conoce a los integrantes responsables del desarrollo '
                  'de la aplicación móvil Ocupa2.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing24),

            for (var i = 0; i < _teamMembers.length; i++) ...[
              TeamMemberCard(
                member: _teamMembers[i],
              ),
              if (i < _teamMembers.length - 1)
                const SizedBox(
                  height: AppDimensions.spacing16,
                ),
            ],
          ],
        ),
      ),
    );
  }
}