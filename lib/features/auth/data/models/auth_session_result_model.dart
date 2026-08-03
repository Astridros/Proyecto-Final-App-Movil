import '../../../../core/errors/api_exception.dart';
import '../../../profile/data/models/profile_model.dart';
import '../../domain/entities/auth_session_result.dart';

typedef JsonMap = Map<String, Object?>;

class AuthSessionResultModel extends AuthSessionResult {
  const AuthSessionResultModel({
    required super.token,
    required super.tokenType,
    required super.user,
  });

  factory AuthSessionResultModel.fromApiResponse(Object? json) {
    final map = _requireJsonMap(json, 'La respuesta');
    final ok = map['ok'];
    if (ok is! bool) {
      throw const ApiException(
        message: 'La respuesta no contiene un estado valido.',
      );
    }

    if (!ok) {
      throw ApiException(message: _extractBackendMessage(map));
    }

    return AuthSessionResultModel.fromJson(map['data']);
  }

  factory AuthSessionResultModel.fromJson(Object? json) {
    final map = _requireJsonMap(json, 'La sesion');
    final token = _requiredString(map, 'token', 'La sesion');
    final tokenType = _requiredString(map, 'tokenType', 'La sesion');
    final user = map['user'];
    if (user is! Map) {
      throw const ApiException(
        message: 'La sesion requiere un usuario valido.',
      );
    }

    return AuthSessionResultModel(
      token: token,
      tokenType: tokenType,
      user: ProfileModel.fromJson(user),
    );
  }
}

JsonMap _requireJsonMap(Object? value, String context) {
  if (value is Map<String, Object?>) {
    return value;
  }

  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  throw ApiException(message: '$context debe ser un objeto JSON valido.');
}

String _requiredString(JsonMap json, String key, String context) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }

  throw ApiException(message: '$context requiere el campo "$key".');
}

String _extractBackendMessage(JsonMap map) {
  for (final key in const ['message', 'detail', 'error']) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }

  return 'La operacion no fue exitosa.';
}
