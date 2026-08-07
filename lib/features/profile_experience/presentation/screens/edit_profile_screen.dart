import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

import '../../domain/entities/profile.dart';
import '../providers/profile_presentation_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.profile,
  });

  final Profile profile;

  @override
  ConsumerState<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends ConsumerState<EditProfileScreen> {

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _cedulaController;
  late final TextEditingController _genderController;
  late final TextEditingController _birthDateController;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _firstNameController =
        TextEditingController(text: widget.profile.firstName);

    _lastNameController =
        TextEditingController(text: widget.profile.lastName);

    _cedulaController =
        TextEditingController(text: widget.profile.cedula);

    _genderController =
        TextEditingController(text: widget.profile.gender);

    _birthDateController =
        TextEditingController(text: widget.profile.birthDate);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cedulaController.dispose();
    _genderController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _save() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {

      final updatedProfile = widget.profile.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        cedula: _cedulaController.text.trim(),
        gender: _genderController.text.trim(),
        birthDate: _birthDateController.text.trim(),
      );

      await ref.read(profileControllerProvider.notifier).updateProfile(updatedProfile);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Perfil actualizado correctamente"),
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Editar perfil"),
      ),

      body: SafeArea(

        child: Form(

          key: _formKey,

          child: ListView(

            padding: const EdgeInsets.all(20),

            children: [

              AppTextField(
                label: "Nombre",
                controller: _firstNameController,
              ),

              const SizedBox(height: 20),

              AppTextField(
                label: "Apellido",
                controller: _lastNameController,
              ),

              const SizedBox(height: 20),

              AppTextField(
                label: "Cédula",
                controller: _cedulaController,
              ),

              const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _genderController.text,

              decoration: const InputDecoration(
                labelText: "Género",
              ),

              items: const [
                DropdownMenuItem(
                  value: "masculino",
                  child: Text("Masculino"),
                ),
                DropdownMenuItem(
                  value: "femenino",
                  child: Text("Femenino"),
                ),
              ],

              onChanged: (value) {
                _genderController.text = value!;
              },
            ),

              const SizedBox(height: 20),

              AppTextField(
                label: "Fecha de nacimiento",
                controller: _birthDateController,
                readOnly: true,
                onTap: () async {

                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.tryParse(
                          _birthDateController.text,
                        ) ??
                        DateTime(2000),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );

                  if (date == null) return;

                  _birthDateController.text =
                      "${date.year}-"
                      "${date.month.toString().padLeft(2, '0')}-"
                      "${date.day.toString().padLeft(2, '0')}";
                },
              ),

              const SizedBox(height: 30),

              AppButton(
                label: "Guardar cambios",
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}