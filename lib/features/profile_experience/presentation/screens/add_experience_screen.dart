import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/experience.dart';
import '../providers/experience_presentation_providers.dart';

class AddExperienceScreen extends ConsumerStatefulWidget {
  const AddExperienceScreen({super.key});

  @override
  ConsumerState<AddExperienceScreen> createState() =>
      _AddExperienceScreenState();
}

class _AddExperienceScreenState extends ConsumerState<AddExperienceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _jobTypeController = TextEditingController();
  final _certificateController = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _certificateController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _jobTypeController.dispose();
    _certificateController.dispose();
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
      final experience = Experience(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        jobTypeKey: _jobTypeController.text.trim(),
        certificateImage: _certificateController.text.trim(),
      );

      await ref
          .read(experienceControllerProvider.notifier)
          .createExperience(experience);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Experiencia guardada correctamente.')),
      );

      context.pop();
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
      appBar: AppBar(title: const Text("Agregar experiencia")),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: ListView(
            padding: const EdgeInsets.all(20),

            children: [
              AppTextField(
                label: "Título",
                controller: _titleController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Ingrese un título";
                  }

                  if (value.trim().length < 3) {
                    return "Debe tener al menos 3 caracteres";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              AppTextField(
                label: "Descripción",
                controller: _descriptionController,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Ingrese una descripción";
                  }

                  if (value.trim().length < 10) {
                    return "La descripción es muy corta";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              AppTextField(
                label: "Tipo de trabajo",
                controller: _jobTypeController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Campo obligatorio";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              AppTextField(
                label: "Imagen del certificado",
                hint: "https://...",
                controller: _certificateController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Ingrese la URL";
                  }

                  final uri = Uri.tryParse(value.trim());

                  if (uri == null ||
                      !(uri.scheme == 'http' || uri.scheme == 'https')) {
                    return "URL inválida";
                  }

                  return null;
                },
              ),

              if (_certificateController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),

                    child: Image.network(
                      _certificateController.text,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return const SizedBox();
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              AppButton(
                label: "Guardar experiencia",
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
