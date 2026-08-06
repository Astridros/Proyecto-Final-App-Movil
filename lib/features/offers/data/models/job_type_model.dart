import '../../domain/entities/job_type.dart';
import 'custom_field_model.dart';
import 'json_parse_utils.dart';

class JobTypeModel extends JobType {
  const JobTypeModel({
    required super.id,
    required super.key,
    required super.name,
    required super.active,
    required super.customFields,
    required super.createdAt,
    super.updatedAt,
  });

  factory JobTypeModel.fromJson(Object? json) {
    final map = requireJsonMap(json, 'El tipo de empleo');

    return JobTypeModel(
      id: requiredString(map, 'id', 'El tipo de empleo'),
      key: requiredString(map, 'key', 'El tipo de empleo'),
      name: requiredString(map, 'name', 'El tipo de empleo'),
      active: boolValue(map, 'active'),
      customFields: parseList(
        map['customFields'],
        CustomFieldModel.fromJson,
        context: 'customFields',
      ),
      createdAt: requiredDate(map, 'createdAt', 'El tipo de empleo'),
      updatedAt: optionalDate(map, 'updatedAt'),
    );
  }
}
