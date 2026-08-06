import '../../../../core/errors/api_exception.dart';

typedef JsonMap = Map<String, Object?>;

JsonMap requireJsonMap(Object? value, String context) {
  if (value is Map<String, Object?>) {
    return value;
  }

  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  throw ApiException(message: '$context debe ser un objeto JSON válido.');
}

String requiredString(JsonMap json, String key, String context) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }

  throw ApiException(message: '$context requiere el campo "$key".');
}

String optionalString(JsonMap json, String key, {String fallback = ''}) {
  final value = json[key];
  if (value is String) {
    return value;
  }

  return fallback;
}

bool boolValue(JsonMap json, String key, {bool fallback = false}) {
  final value = json[key];
  if (value is bool) {
    return value;
  }

  return fallback;
}

int intValue(JsonMap json, String key, {int fallback = 0}) {
  final value = json[key];
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }

  return fallback;
}

double doubleValue(JsonMap json, String key, {double fallback = 0}) {
  final value = json[key];
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value) ?? fallback;
  }

  return fallback;
}

DateTime requiredDate(JsonMap json, String key, String context) {
  final value = json[key];
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return parsed;
    }
  }

  throw ApiException(message: '$context requiere una fecha válida en "$key".');
}

DateTime? optionalDate(JsonMap json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    return null;
  }

  return DateTime.tryParse(value);
}

List<T> parseList<T>(
  Object? value,
  T Function(JsonMap item) parseItem, {
  required String context,
}) {
  if (value == null) {
    return const [];
  }

  if (value is! List) {
    throw ApiException(message: '$context debe ser una lista.');
  }

  final items = <T>[];
  for (final item in value) {
    if (item is Map) {
      items.add(parseItem(requireJsonMap(item, context)));
    }
  }

  return List.unmodifiable(items);
}

Map<String, Object?> stringObjectMap(Object? value, String context) {
  if (value == null) {
    return const {};
  }

  if (value is List && value.isEmpty) {
    return const {};
  }

  if (value is Map) {
    return Map.unmodifiable(
      value.map((key, item) => MapEntry(key.toString(), item)),
    );
  }

  throw ApiException(message: '$context debe ser un objeto JSON.');
}
