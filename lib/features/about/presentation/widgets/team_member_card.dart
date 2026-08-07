import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/team_member.dart';

class TeamMemberCard extends StatelessWidget {
  const TeamMemberCard({
    super.key,
    required this.member,
  });

  final TeamMember member;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 46,
              backgroundColor: AppColors.surfaceSoft,
              backgroundImage: AssetImage(member.photoAsset),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          Center(
            child: Text(
              member.name,
              textAlign: TextAlign.center,
              style: AppTextStyles.title,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Center(
            child: Text(
              'Matrícula: ${member.studentId}',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing16),
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                color: AppColors.primary,
                size: AppDimensions.iconMedium,
              ),
              const SizedBox(width: AppDimensions.spacing8),
              Expanded(
                child: Text(
                  member.phone,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing16),
          Row(
            children: [
              Expanded(
                child: AppButton.outlined(
                  label: 'Llamar',
                  icon: Icons.phone_rounded,
                  onPressed: () => _callPhone(context),
                  width: double.infinity,
                ),
              ),
              const SizedBox(width: AppDimensions.spacing12),
              Expanded(
                child: AppButton.outlined(
                  label: 'Telegram',
                  icon: Icons.send_outlined,
                  onPressed: () => _openTelegram(context),
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _callPhone(BuildContext context) async {
    final uri = Uri(
      scheme: 'tel',
      path: member.phone,
    );

    final launched = await launchUrl(uri);

    if (!launched && context.mounted) {
      _showError(
        context,
        'No fue posible abrir la aplicación de llamadas.',
      );
    }
  }

  Future<void> _openTelegram(BuildContext context) async {
    final uri = Uri.parse(member.telegramUrl);

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      _showError(
        context,
        'No fue posible abrir Telegram.',
      );
    }
  }

  void _showError(
      BuildContext context,
      String message,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}