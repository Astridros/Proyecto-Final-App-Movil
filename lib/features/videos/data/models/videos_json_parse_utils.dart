// Angel Daniel Genao 2024-1169
// Funciones de ayuda para leer el JSON de un video (respuesta del
// backend propio de Ocupa2, GET /videos) de forma segura, igual que en
// el módulo de noticias.

import '../../../../core/errors/api_exception.dart';

typedef JsonMap = Map<String, Object?>;

// Verifica que el valor sea un objeto JSON (Map) y lo entrega listo para usar.
JsonMap requireJsonMap(Object? value, String context) {
  if (value is Map<String, Object?>) {
    return value;
  }

  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  throw ApiException(message: '$context debe ser un objeto JSON válido.');
}

// Lee un texto obligatorio; si falta, lanza un error.
String requiredString(JsonMap json, String key, String context) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }

  throw ApiException(message: '$context requiere el campo "$key".');
}

// Lee un texto opcional; si no viene, devuelve el valor por defecto.
String optionalString(JsonMap json, String key, {String fallback = ''}) {
  final value = json[key];
  if (value is String) {
    return value.trim();
  }

  return fallback;
}

// Lee un número entero opcional (acepta int, double o texto numérico).
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
