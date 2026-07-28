import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/profile.dart';
import 'profile_json_parse_utils.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.email,
    required super.profileCompleted,
    super.firstName,
    super.lastName,
    super.nombre,
    super.referralMatricula,
    super.role,
    super.createdAt,
    super.updatedAt,
    super.lastLoginAt,
    super.birthDate,
    super.cedula,
    super.gender,
  });

  factory ProfileModel.fromJson(Object? json) {
    final map = requireJsonMap(json, 'El perfil');

    return ProfileModel(
      id: requiredString(map, 'id', 'El perfil'),
      email: requiredString(map, 'email', 'El perfil'),
      firstName: nullableString(map, 'firstName'),
      lastName: nullableString(map, 'lastName'),
      nombre: nullableString(map, 'nombre'),
      referralMatricula: nullableString(map, 'referralMatricula'),
      role: nullableString(map, 'role'),
      createdAt: optionalDate(map, 'createdAt'),
      updatedAt: optionalDate(map, 'updatedAt'),
      lastLoginAt: optionalDate(map, 'lastLoginAt'),
      birthDate: optionalDate(map, 'birthDate'),
      cedula: nullableString(map, 'cedula'),
      gender: nullableString(map, 'gender'),
      profileCompleted: boolValue(map, 'profileCompleted'),
    );
  }

  static ProfileModel fromApiResponse(Object? json) {
    final map = requireJsonMap(json, 'La respuesta');
    final ok = map['ok'];
    if (ok is! bool) {
      throw const ApiException(
        message: 'La respuesta no contiene un estado valido.',
      );
    }

    if (!ok) {
      throw ApiException(message: _extractBackendMessage(map));
    }

    return ProfileModel.fromJson(map['data']);
  }

  static String _extractBackendMessage(JsonMap map) {
    for (final key in const ['message', 'detail', 'error']) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return 'La operacion no fue exitosa.';
  }
}
