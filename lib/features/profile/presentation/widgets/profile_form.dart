import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/profile.dart';

typedef ProfileSubmitCallback =
    Future<bool> Function({
      required String firstName,
      required String lastName,
      required String cedula,
      required String gender,
      required DateTime birthDate,
    });

class ProfileForm extends StatefulWidget {
  const ProfileForm({
    super.key,
    required this.profile,
    required this.isSubmitting,
    required this.onSubmit,
    this.errorMessage,
  });

  final Profile profile;
  final bool isSubmitting;
  final ProfileSubmitCallback onSubmit;
  final String? errorMessage;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _cedulaController;
  late final TextEditingController _birthDateController;
  String? _gender;
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _cedulaController = TextEditingController();
    _birthDateController = TextEditingController();
    _applyProfile(widget.profile);
  }

  @override
  void didUpdateWidget(covariant ProfileForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _applyProfile(widget.profile);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cedulaController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Completar perfil', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              'Estos datos se usarán para completar tu información laboral.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (widget.errorMessage != null) ...[
              const SizedBox(height: AppDimensions.spacing16),
              Text(
                widget.errorMessage!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.spacing20),
            AppTextField(
              label: 'Nombre',
              prefixIcon: Icons.person_outline,
              controller: _firstNameController,
              enabled: !widget.isSubmitting,
              validator: _requiredText('Nombre requerido'),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            AppTextField(
              label: 'Apellido',
              prefixIcon: Icons.badge_outlined,
              controller: _lastNameController,
              enabled: !widget.isSubmitting,
              validator: _requiredText('Apellido requerido'),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            AppTextField(
              label: 'Cédula',
              prefixIcon: Icons.credit_card_outlined,
              keyboardType: TextInputType.number,
              controller: _cedulaController,
              enabled: !widget.isSubmitting,
              validator: _validateCedula,
            ),
            const SizedBox(height: AppDimensions.spacing16),
            DropdownButtonFormField<String>(
              key: ValueKey(_gender),
              initialValue: _gender,
              decoration: const InputDecoration(
                labelText: 'Género',
                prefixIcon: Icon(Icons.wc_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'masculino', child: Text('Masculino')),
                DropdownMenuItem(value: 'femenino', child: Text('Femenino')),
              ],
              onChanged: widget.isSubmitting
                  ? null
                  : (value) => setState(() => _gender = value),
              validator: (value) => value == null ? 'Género requerido' : null,
            ),
            const SizedBox(height: AppDimensions.spacing16),
            AppTextField(
              label: 'Fecha de nacimiento',
              prefixIcon: Icons.calendar_today_outlined,
              suffixIcon: const Icon(Icons.expand_more_rounded),
              controller: _birthDateController,
              enabled: !widget.isSubmitting,
              readOnly: true,
              onTap: widget.isSubmitting ? null : _pickBirthDate,
              validator: (_) => _validateBirthDate(_birthDate),
            ),
            const SizedBox(height: AppDimensions.spacing24),
            AppButton(
              label: 'Guardar perfil',
              icon: Icons.save_outlined,
              width: double.infinity,
              isLoading: widget.isSubmitting,
              onPressed: widget.isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  void _applyProfile(Profile profile) {
    _firstNameController.text = profile.firstName ?? '';
    _lastNameController.text = profile.lastName ?? '';
    _cedulaController.text = profile.cedula ?? '';
    _gender = _normalizeGender(profile.gender);
    _birthDate = profile.birthDate;
    _birthDateController.text = _formatDate(_birthDate);
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _birthDate = DateTime(selected.year, selected.month, selected.day);
      _birthDateController.text = _formatDate(_birthDate);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await widget.onSubmit(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      cedula: _cedulaController.text.trim(),
      gender: _gender!,
      birthDate: _birthDate!,
    );
  }

  FormFieldValidator<String> _requiredText(String message) {
    return (value) {
      final normalized = value?.trim();
      if (normalized == null || normalized.isEmpty) {
        return message;
      }

      return null;
    };
  }

  String? _validateCedula(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return 'Cédula requerida';
    }

    if (!RegExp(r'^\d+$').hasMatch(normalized)) {
      return 'Cédula solo numérica';
    }

    if (normalized.length != 11) {
      return 'Cédula debe tener 11 dígitos';
    }

    return null;
  }

  String? _validateBirthDate(DateTime? value) {
    if (value == null) {
      return 'Fecha de nacimiento requerida';
    }

    final today = _dateOnly(DateTime.now());
    final birthDate = _dateOnly(value);
    if (birthDate.isAfter(today)) {
      return 'Fecha de nacimiento no puede ser futura';
    }

    if (!_isAdult(birthDate, today)) {
      return 'Debes tener al menos 18 años';
    }

    return null;
  }

  bool _isAdult(DateTime birthDate, DateTime today) {
    final adultDate = DateTime(
      birthDate.year + 18,
      birthDate.month,
      birthDate.day,
    );
    return !adultDate.isAfter(today);
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String? _normalizeGender(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == 'masculino' || normalized == 'femenino') {
      return normalized;
    }

    return null;
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '';
    }

    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }
}
