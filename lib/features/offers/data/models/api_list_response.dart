import '../../../../core/errors/api_exception.dart';
import 'json_parse_utils.dart';

class ApiListResponse<T> {
  const ApiListResponse({required this.ok, required this.data});

  final bool ok;
  final List<T> data;

  factory ApiListResponse.fromJson(
    Object? json,
    T Function(JsonMap item) parseItem,
  ) {
    final map = requireJsonMap(json, 'La respuesta');
    final ok = map['ok'];
    if (ok is! bool) {
      throw const ApiException(
        message: 'La respuesta no contiene un estado válido.',
      );
    }

    if (!ok) {
      final message = _extractBackendMessage(map);
      throw ApiException(message: message ?? 'La operación no fue exitosa.');
    }

    final data = map['data'];
    if (data is! List) {
      throw const ApiException(
        message: 'La respuesta no contiene una lista de datos válida.',
      );
    }

    final items = <T>[];
    for (final item in data) {
      if (item is Map) {
        items.add(parseItem(requireJsonMap(item, 'Elemento de la respuesta')));
      } else {
        throw const ApiException(
          message: 'La respuesta contiene un elemento inválido.',
        );
      }
    }

    return ApiListResponse<T>(ok: ok, data: List.unmodifiable(items));
  }

  static String? _extractBackendMessage(JsonMap map) {
    for (final key in const ['message', 'detail', 'error']) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return null;
  }
}
