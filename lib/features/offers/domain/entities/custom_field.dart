import 'package:equatable/equatable.dart';

class CustomField extends Equatable {
  const CustomField({
    required this.key,
    required this.label,
    required this.type,
    required this.required,
    required this.options,
  });

  final String key;
  final String label;
  final String type;
  final bool required;
  final List<String> options;

  @override
  List<Object?> get props => [key, label, type, required, options];
}
