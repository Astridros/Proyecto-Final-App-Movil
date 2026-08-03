import 'package:equatable/equatable.dart';

class OfferQuestion extends Equatable {
  const OfferQuestion({
    required this.id,
    required this.label,
    required this.type,
    required this.required,
    required this.options,
  });

  final String id;
  final String label;
  final String type;
  final bool required;
  final List<String> options;

  @override
  List<Object?> get props => [id, label, type, required, options];
}
