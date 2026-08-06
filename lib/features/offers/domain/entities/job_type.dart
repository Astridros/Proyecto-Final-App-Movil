import 'package:equatable/equatable.dart';

import 'custom_field.dart';

class JobType extends Equatable {
  const JobType({
    required this.id,
    required this.key,
    required this.name,
    required this.active,
    required this.customFields,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String key;
  final String name;
  final bool active;
  final List<CustomField> customFields;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
    id,
    key,
    name,
    active,
    customFields,
    createdAt,
    updatedAt,
  ];
}
