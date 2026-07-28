import '../../../../core/errors/api_exception.dart';

typedef JsonMap = Map<String, Object?>;

JsonMap requireJsonMap(Object? value, String context) {
  if (value is Map<String, Object?>) {
    return value;
  }

  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  throw ApiException(message: '$context debe ser un objeto JSON valido.');
}

String requiredString(JsonMap json, String key, String context) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }

  throw ApiException(message: '$context requiere el campo "$key".');
}

String? nullableString(JsonMap json, String key) {
  final value = json[key];
  if (value is! String) {
    return null;
  }

  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

bool boolValue(JsonMap json, String key, {bool fallback = false}) {
  final value = json[key];
  if (value is bool) {
    return value;
  }

  return fallback;
}

DateTime? optionalDate(JsonMap json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    return null;
  }

  return DateTime.tryParse(value);
}
