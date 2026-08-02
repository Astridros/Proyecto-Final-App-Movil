// Angel Daniel Genao 2024-1169
// Funciones de ayuda para leer un JSON (lo que devuelve la API) de forma segura.
// Si un campo no viene o viene con un tipo raro, aquí se decide qué hacer
// (lanzar error o poner un valor por defecto) en vez de que la app se rompa.

import '../../../../core/errors/api_exception.dart';

typedef JsonMap = Map<String, Object?>;

// Verifica que el valor sea realmente un objeto JSON (un Map) y lo entrega listo para usar.
JsonMap requireJsonMap(Object? value, String context) {
  if (value is Map<String, Object?>) {
    return value;
  }

  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  throw ApiException(message: '$context debe ser un objeto JSON válido.');
}

// Lee un texto que es obligatorio; si falta o está vacío, lanza un error claro.
String requiredString(JsonMap json, String key, String context) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }

  throw ApiException(message: '$context requiere el campo "$key".');
}

// Lee un texto opcional; si no viene, devuelve un valor por defecto (vacío por defecto).
String optionalString(JsonMap json, String key, {String fallback = ''}) {
  final value = json[key];
  if (value is String) {
    return value.trim();
  }

  return fallback;
}

// Lee una fecha opcional en formato texto (ISO8601); si no viene o es inválida, devuelve null.
DateTime? optionalDate(JsonMap json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    return null;
  }

  return DateTime.tryParse(value);
}
