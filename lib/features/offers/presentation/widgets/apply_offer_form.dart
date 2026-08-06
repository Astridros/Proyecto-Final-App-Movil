import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/apply_offer_answer.dart';
import '../../domain/entities/offer.dart';
import '../../domain/entities/offer_question.dart';

typedef ApplyOfferSubmit =
    Future<bool> Function(String comment, List<ApplyOfferAnswer> answers);

class ApplyOfferForm extends StatefulWidget {
  const ApplyOfferForm({
    super.key,
    required this.offer,
    required this.isSubmitting,
    required this.error,
    required this.successMessage,
    required this.hasAlreadyApplied,
    this.existingApplicationStatus,
    required this.onSubmit,
  });

  final Offer offer;
  final bool isSubmitting;
  final AppException? error;
  final String? successMessage;
  final bool hasAlreadyApplied;
  final String? existingApplicationStatus;
  final ApplyOfferSubmit onSubmit;

  @override
  State<ApplyOfferForm> createState() => _ApplyOfferFormState();
}

class _ApplyOfferFormState extends State<ApplyOfferForm> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final _textControllers = <String, TextEditingController>{};
  final _answers = <String, String>{};
  final _explicitCheckAnswers = <String>{};
  bool _hasApplied = false;
  bool _isSubmittingLocally = false;

  @override
  void didUpdateWidget(covariant ApplyOfferForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.successMessage != null && oldWidget.successMessage == null) {
      _clearFields();
      _hasApplied = true;
    }

    if (_isAlreadyAppliedMessage(widget.error?.message)) {
      _hasApplied = true;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alreadyApplied =
        widget.hasAlreadyApplied ||
        _hasApplied ||
        widget.successMessage != null ||
        _isAlreadyAppliedMessage(widget.error?.message);

    return AppCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionTitle(
              icon: Icons.send_outlined,
              title: 'Aplicar a esta oferta',
            ),
            const SizedBox(height: AppDimensions.spacing12),
            if (widget.successMessage != null) ...[
              _StatusBanner.success(widget.successMessage!),
              const SizedBox(height: AppDimensions.spacing12),
            ],
            if (widget.error != null) ...[
              _StatusBanner.error(widget.error!.message),
              const SizedBox(height: AppDimensions.spacing12),
            ],
            if (alreadyApplied) ...[
              _StatusBanner.success(
                _alreadyAppliedMessage(widget.existingApplicationStatus),
              ),
            ] else ...[
              AppTextField(
                label: 'Comentario',
                hint: 'Cuéntanos por qué eres una buena opción',
                controller: _commentController,
                maxLines: 4,
                enabled: !widget.isSubmitting,
              ),
              if (widget.offer.questions.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacing16),
                Text('Preguntas', style: AppTextStyles.title),
                const SizedBox(height: AppDimensions.spacing12),
                ...widget.offer.questions.map(_questionField),
              ],
              const SizedBox(height: AppDimensions.spacing20),
              AppButton(
                label: 'Enviar aplicacion',
                icon: Icons.send_rounded,
                isLoading: widget.isSubmitting || _isSubmittingLocally,
                onPressed: widget.isSubmitting || _isSubmittingLocally
                    ? null
                    : _submit,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _questionField(OfferQuestion question) {
    final field = switch (question.type.trim().toLowerCase()) {
      'date' => _dateField(question),
      'select' => _selectField(question),
      'check' => _checkField(question),
      _ => _textField(question),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacing16),
      child: field,
    );
  }

  Widget _textField(OfferQuestion question) {
    final controller = _textControllers.putIfAbsent(
      question.id,
      TextEditingController.new,
    );

    return AppTextField(
      label: _questionLabel(question),
      controller: controller,
      enabled: !widget.isSubmitting,
      maxLines: 3,
      validator: (value) {
        final trimmed = value?.trim() ?? '';
        if (question.required && trimmed.isEmpty) {
          return 'Esta pregunta es obligatoria';
        }

        return null;
      },
    );
  }

  Widget _dateField(OfferQuestion question) {
    final controller = _textControllers.putIfAbsent(
      question.id,
      TextEditingController.new,
    );

    return AppTextField(
      label: _questionLabel(question),
      controller: controller,
      prefixIcon: Icons.event_outlined,
      readOnly: true,
      enabled: !widget.isSubmitting,
      onTap: widget.isSubmitting ? null : () => _pickDate(question, controller),
      validator: (value) {
        if (question.required && !_answers.containsKey(question.id)) {
          return 'Selecciona una fecha';
        }

        return null;
      },
    );
  }

  Widget _selectField(OfferQuestion question) {
    if (question.options.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputDecorator(
            decoration: InputDecoration(
              labelText: _questionLabel(question),
              enabled: false,
            ),
            child: const Text('Sin opciones disponibles'),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          const _InlineWarning(
            message: 'Esta pregunta no tiene opciones configuradas.',
          ),
          FormField<String>(
            validator: (_) {
              if (question.required) {
                return 'No hay opciones disponibles para esta pregunta requerida';
              }

              return null;
            },
            builder: (field) {
              if (field.errorText == null) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(top: AppDimensions.spacing8),
                child: Text(
                  field.errorText!,
                  style: AppTextStyles.caption.copyWith(color: AppColors.error),
                ),
              );
            },
          ),
        ],
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: _answers[question.id],
      decoration: InputDecoration(labelText: _questionLabel(question)),
      items: question.options
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(growable: false),
      onChanged: widget.isSubmitting
          ? null
          : (value) {
              setState(() {
                if (value == null) {
                  _answers.remove(question.id);
                } else {
                  _answers[question.id] = value;
                }
              });
            },
      validator: (value) {
        if (question.required && (value == null || value.trim().isEmpty)) {
          return 'Selecciona una opcion';
        }

        if (value != null && !question.options.contains(value)) {
          return 'Selecciona una opcion valida';
        }

        return null;
      },
    );
  }

  Widget _checkField(OfferQuestion question) {
    return FormField<String>(
      initialValue: _answers[question.id],
      validator: (_) {
        if (question.required && !_explicitCheckAnswers.contains(question.id)) {
          return 'Selecciona una respuesta';
        }

        return null;
      },
      builder: (field) {
        final value = _answers[question.id] == 'true';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: value,
              onChanged: widget.isSubmitting
                  ? null
                  : (checked) {
                      setState(() {
                        _explicitCheckAnswers.add(question.id);
                        _answers[question.id] = checked == true
                            ? 'true'
                            : 'false';
                        field.didChange(_answers[question.id]);
                      });
                    },
              title: Text(_questionLabel(question)),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (field.errorText != null)
              Text(
                field.errorText!,
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
          ],
        );
      },
    );
  }

  Future<void> _pickDate(
    OfferQuestion question,
    TextEditingController controller,
  ) async {
    final now = DateTime.now();
    final initial = DateTime.tryParse(_answers[question.id] ?? '') ?? now;
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 20),
    );

    if (selected == null) {
      return;
    }

    final value = DateFormat('yyyy-MM-dd').format(selected);
    setState(() {
      _answers[question.id] = value;
      controller.text = DateFormat('dd/MM/yyyy').format(selected);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmittingLocally = true;
    });

    try {
      final answers = _buildAnswers();
      await widget.onSubmit(_commentController.text.trim(), answers);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingLocally = false;
        });
      }
    }
  }

  List<ApplyOfferAnswer> _buildAnswers() {
    final result = <ApplyOfferAnswer>[];
    for (final question in widget.offer.questions) {
      final value = _valueFor(question);
      if (value == null || value.trim().isEmpty) {
        continue;
      }

      result.add(ApplyOfferAnswer(questionId: question.id, value: value));
    }

    return result;
  }

  String? _valueFor(OfferQuestion question) {
    final type = question.type.trim().toLowerCase();
    if (type == 'text' || type.isEmpty || !_knownTypes.contains(type)) {
      return _textControllers[question.id]?.text.trim();
    }

    if (type == 'date' || type == 'select' || type == 'check') {
      return _answers[question.id];
    }

    return null;
  }

  void _clearFields() {
    _commentController.clear();
    for (final controller in _textControllers.values) {
      controller.clear();
    }
    _answers.clear();
    _explicitCheckAnswers.clear();
  }

  String _questionLabel(OfferQuestion question) {
    return question.required ? '${question.label} *' : question.label;
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: AppDimensions.spacing8),
        Expanded(child: Text(title, style: AppTextStyles.title)),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner._({
    required this.message,
    required this.icon,
    required this.color,
  });

  const _StatusBanner.success(String message)
    : this._(
        message: message,
        icon: Icons.check_circle_outline_rounded,
        color: AppColors.success,
      );

  const _StatusBanner.error(String message)
    : this._(
        message: message,
        icon: Icons.error_outline_rounded,
        color: AppColors.error,
      );

  final String message;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing12),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: AppDimensions.spacing8),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineWarning extends StatelessWidget {
  const _InlineWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.info_outline_rounded,
          color: AppColors.warning,
          size: AppDimensions.iconSmall,
        ),
        const SizedBox(width: AppDimensions.spacing8),
        Expanded(
          child: Text(
            message,
            style: AppTextStyles.caption.copyWith(color: AppColors.warning),
          ),
        ),
      ],
    );
  }
}

bool _isAlreadyAppliedMessage(String? message) {
  return message?.trim() == 'Ya aplicaste a esta oferta.';
}

String _alreadyAppliedMessage(String? status) {
  final label = _statusLabel(status);
  if (label == null) {
    return 'Ya aplicaste a esta oferta.';
  }

  return 'Ya aplicaste a esta oferta. Estado: $label.';
}

String? _statusLabel(String? status) {
  final normalized = status?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  return switch (normalized) {
    'applied' => 'Aplicada',
    'pending' => 'Pendiente',
    'accepted' => 'Aceptada',
    'rejected' => 'Rechazada',
    _ => status!.trim(),
  };
}

const _knownTypes = {'text', 'date', 'select', 'check'};
