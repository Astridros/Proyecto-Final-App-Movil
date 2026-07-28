import '../../domain/entities/custom_field.dart';
import 'json_parse_utils.dart';

class CustomFieldModel extends CustomField {
  const CustomFieldModel({
    required super.key,
    required super.label,
    required super.type,
    required super.required,
    required super.options,
  });

  factory CustomFieldModel.fromJson(Object? json) {
    final map = requireJsonMap(json, 'El campo personalizado');
    final optionsValue = map['options'];
    final options = optionsValue is List
        ? optionsValue.whereType<String>().toList(growable: false)
        : const <String>[];

    return CustomFieldModel(
      key: requiredString(map, 'key', 'El campo personalizado'),
      label: requiredString(map, 'label', 'El campo personalizado'),
      type: requiredString(map, 'type', 'El campo personalizado'),
      required: boolValue(map, 'required'),
      options: options,
    );
  }
}
