import 'package:flutter/material.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';

class CreateOfferScreen extends StatefulWidget {
  const CreateOfferScreen({super.key});

  @override
  State<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobTypeKeyController = TextEditingController();
  final _contractTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _photoController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _amountController = TextEditingController();
  final _currencyController = TextEditingController(text: 'DOP');
  final _deadlineController = TextEditingController();
  final _customAnswerKeyController = TextEditingController();
  final _customAnswerValueController = TextEditingController();
  final _questions = <_QuestionDraft>[];
  DateTime? _deadline;

  @override
  void dispose() {
    _jobTypeKeyController.dispose();
    _contractTypeController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _photoController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _amountController.dispose();
    _currencyController.dispose();
    _deadlineController.dispose();
    _customAnswerKeyController.dispose();
    _customAnswerValueController.dispose();
    for (final question in _questions) {
      question.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publicar oferta')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _section(
                title: 'Información de la oferta',
                children: [
                  AppTextField(
                    label: 'Tipo de trabajo',
                    hint: 'Ej.: chofer',
                    controller: _jobTypeKeyController,
                    validator: _required('El tipo de trabajo es obligatorio.'),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Tipo de contrato',
                    hint: 'Ej.: temporal',
                    controller: _contractTypeController,
                    validator: _required('El tipo de contrato es obligatorio.'),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Descripción',
                    controller: _descriptionController,
                    maxLines: 4,
                    validator: _required('La descripción es obligatoria.'),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Dirección',
                    controller: _addressController,
                    validator: _required('La dirección es obligatoria.'),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Foto (URL opcional)',
                    controller: _photoController,
                    keyboardType: TextInputType.url,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _section(
                title: 'Ubicación y pago al trabajador',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Latitud',
                          hint: '18.4861',
                          controller: _latitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          validator: _latitudeValidator,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'Longitud',
                          hint: '-69.9312',
                          controller: _longitudeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          validator: _longitudeValidator,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Monto a pagar',
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            final amount = double.tryParse(value ?? '');
                            return amount != null && amount > 0
                                ? null
                                : 'Monto inválido.';
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'Moneda',
                          hint: 'DOP',
                          controller: _currencyController,
                          validator: _required('La moneda es obligatoria.'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Fecha límite',
                    hint: 'Selecciona una fecha',
                    controller: _deadlineController,
                    readOnly: true,
                    onTap: _selectDeadline,
                    validator: (_) => _deadline == null
                        ? 'La fecha límite es obligatoria.'
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _section(
                title: 'Respuesta personalizada',
                children: [
                  AppTextField(
                    label: 'Clave',
                    hint: 'Ej.: categoria_licencia',
                    controller: _customAnswerKeyController,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Respuesta',
                    hint: 'Ej.: 03',
                    controller: _customAnswerValueController,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildQuestionsSection(),
              const SizedBox(height: 24),
              AppButton(label: 'Continuar al pago', onPressed: _validateForm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section({required String title, required List<Widget> children}) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildQuestionsSection() {
    return _section(
      title: 'Preguntas para postulantes',
      children: [
        for (var index = 0; index < _questions.length; index++) ...[
          _buildQuestion(index, _questions[index]),
          if (index < _questions.length - 1) const Divider(height: 32),
        ],
        OutlinedButton.icon(
          onPressed: _addQuestion,
          icon: const Icon(Icons.add),
          label: const Text('Agregar pregunta'),
        ),
      ],
    );
  }

  Widget _buildQuestion(int index, _QuestionDraft question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Pregunta ${index + 1}')),
            IconButton(
              onPressed: () => _removeQuestion(index),
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Eliminar pregunta',
            ),
          ],
        ),
        AppTextField(
          label: 'Enunciado',
          controller: question.labelController,
          validator: _required('El enunciado de la pregunta es obligatorio.'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: question.type,
          decoration: const InputDecoration(labelText: 'Tipo de respuesta'),
          items: const [
            DropdownMenuItem(value: 'text', child: Text('Texto')),
            DropdownMenuItem(value: 'select', child: Text('Selección')),
            DropdownMenuItem(value: 'check', child: Text('Sí / No')),
          ],
          onChanged: (value) => setState(() => question.type = value ?? 'text'),
        ),
        if (question.type == 'select') ...[
          const SizedBox(height: 12),
          AppTextField(
            label: 'Opciones',
            hint: 'Separadas por coma',
            controller: question.optionsController,
            validator: (value) => (value ?? '').trim().isNotEmpty
                ? null
                : 'Agrega al menos una opción.',
          ),
        ],
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: question.required,
          onChanged: (value) =>
              setState(() => question.required = value ?? true),
          title: const Text('Respuesta obligatoria'),
        ),
      ],
    );
  }

  FormFieldValidator<String> _required(String message) {
    return (value) => (value ?? '').trim().isEmpty ? message : null;
  }

  String? _latitudeValidator(String? value) {
    final latitude = double.tryParse(value ?? '');
    return latitude != null && latitude >= -90 && latitude <= 90
        ? null
        : 'Latitud inválida.';
  }

  String? _longitudeValidator(String? value) {
    final longitude = double.tryParse(value ?? '');
    return longitude != null && longitude >= -180 && longitude <= 180
        ? null
        : 'Longitud inválida.';
  }

  Future<void> _selectDeadline() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _deadline = selected;
      _deadlineController.text =
          '${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
    });
  }

  void _addQuestion() {
    setState(() => _questions.add(_QuestionDraft()));
  }

  void _removeQuestion(int index) {
    setState(() {
      final question = _questions.removeAt(index);
      question.dispose();
    });
  }

  void _validateForm() {
    _formKey.currentState?.validate();
  }
}

class _QuestionDraft {
  _QuestionDraft()
    : labelController = TextEditingController(),
      optionsController = TextEditingController();

  final TextEditingController labelController;
  final TextEditingController optionsController;
  String type = 'text';
  bool required = true;

  void dispose() {
    labelController.dispose();
    optionsController.dispose();
  }
}
