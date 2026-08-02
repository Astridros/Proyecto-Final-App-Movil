// Angel Daniel Genao 2024-1169
// Caché genérico en memoria con expiración (TTL). Se usa en los
// repositorios de Noticias y Videos para no repetir llamadas de red
// cuando el usuario entra y sale de la pantalla en poco tiempo.
// No persiste en disco: vive solo mientras la app está abierta.

class TtlCache<T> {
  TtlCache({this.ttl = const Duration(minutes: 10)});

  final Duration ttl;
  T? _value;
  DateTime? _cachedAt;

  bool get isValid {
    final cachedAt = _cachedAt;
    if (cachedAt == null) {
      return false;
    }

    return DateTime.now().difference(cachedAt) < ttl;
  }

  // Devuelve el valor guardado solo si todavía no expiró.
  T? get value => isValid ? _value : null;

  void set(T value) {
    _value = value;
    _cachedAt = DateTime.now();
  }

  void invalidate() {
    _value = null;
    _cachedAt = null;
  }
}
