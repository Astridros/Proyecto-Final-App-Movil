import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class LoginPlaceholderScreen extends StatelessWidget {
  const LoginPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenHorizontalPadding,
            vertical: AppDimensions.spacing16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Acceso a Ocupa2', style: AppTextStyles.headingLarge),
              const SizedBox(height: AppDimensions.spacing8),
              Text(
                'Vista temporal para validar campos y botones. La autenticación '
                'real se conectará a Swagger en otro paso.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing24),
              const AppTextField(
                label: 'Correo',
                hint: 'persona@correo.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppDimensions.spacing16),
              const AppTextField(
                label: 'Clave',
                hint: 'Mínimo 6 caracteres',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
              ),
              const SizedBox(height: AppDimensions.spacing24),
              AppButton(
                label: 'Continuar',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {},
                width: double.infinity,
              ),
              const SizedBox(height: AppDimensions.spacing12),
              AppButton.outlined(
                label: 'Volver al inicio',
                icon: Icons.home_outlined,
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
