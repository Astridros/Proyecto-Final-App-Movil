import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';

class CompleteProfilePlaceholderScreen extends StatefulWidget {
  const CompleteProfilePlaceholderScreen({super.key});

  @override
  State<CompleteProfilePlaceholderScreen> createState() =>
      _CompleteProfilePlaceholderScreenState();
}

class _CompleteProfilePlaceholderScreenState
    extends State<CompleteProfilePlaceholderScreen> {
  DateTime? _birthDate;
  String? _gender;

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
              Text('Completar perfil', style: AppTextStyles.headingLarge),
              const SizedBox(height: AppDimensions.spacing8),
              Text(
                'Campos visuales provisionales basados en el módulo de perfil. '
                'Todavía no se guarda información ni se consulta GET /me.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing24),
              AppCard(
                child: Column(
                  children: [
                    const AppTextField(
                      label: 'Cédula',
                      hint: 'Documento de identidad',
                      prefixIcon: Icons.credit_card_rounded,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    const AppTextField(
                      label: 'Nombre',
                      hint: 'Nombre del usuario',
                      prefixIcon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    const AppTextField(
                      label: 'Apellido',
                      hint: 'Apellido del usuario',
                      prefixIcon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: const InputDecoration(
                        labelText: 'Género',
                        prefixIcon: Icon(Icons.wc_rounded),
                      ),
                      hint: const Text('Selecciona una opción'),
                      items: const [
                        // Valores temporales; los definitivos dependerán del contrato Swagger.
                        DropdownMenuItem(
                          value: 'Masculino',
                          child: Text('Masculino'),
                        ),
                        DropdownMenuItem(
                          value: 'Femenino',
                          child: Text('Femenino'),
                        ),
                        DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                      ],
                      onChanged: (value) => setState(() => _gender = value),
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    AppTextField(
                      label: 'Fecha de nacimiento',
                      hint: _birthDate == null
                          ? 'Selecciona una fecha'
                          : _formatDate(_birthDate!),
                      prefixIcon: Icons.calendar_today_outlined,
                      readOnly: true,
                      onTap: _selectBirthDate,
                      suffixIcon: IconButton(
                        tooltip: 'Seleccionar fecha',
                        onPressed: _selectBirthDate,
                        icon: const Icon(Icons.edit_calendar_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacing24),
              AppButton(
                label: 'Vista sin guardado',
                icon: Icons.check_circle_outline_rounded,
                onPressed: () {},
                width: double.infinity,
              ),
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

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() => _birthDate = selectedDate);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
