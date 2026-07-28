import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/config/dev_auth_bootstrap.dart';
import 'package:ocupa2/core/storage/token_storage.dart';

void main() {
  group('bootstrapDevAuthToken', () {
    test('sin token definido no intenta guardar nada', () async {
      final storage = _FakeTokenStorage();

      await bootstrapDevAuthToken(tokenStorage: storage);

      expect(storage.savedTokens, isEmpty);
    });

    test('token vacio no intenta guardar nada', () async {
      final storage = _FakeTokenStorage();

      await bootstrapDevAuthToken(devToken: '   ', tokenStorage: storage);

      expect(storage.savedTokens, isEmpty);
    });

    test('en modo permitido guarda el token usando TokenStorage', () async {
      final storage = _FakeTokenStorage();

      await bootstrapDevAuthToken(
        devToken: 'real-token',
        tokenStorage: storage,
      );

      expect(storage.savedTokens, ['real-token']);
    });

    test('el token se normaliza con trim', () async {
      final storage = _FakeTokenStorage();

      await bootstrapDevAuthToken(
        devToken: '  real-token  ',
        tokenStorage: storage,
      );

      expect(storage.savedTokens, ['real-token']);
    });

    test('no se expone el valor del token en logs', () async {
      final storage = _FakeTokenStorage();
      final logs = <String>[];

      await runZoned(
        () => bootstrapDevAuthToken(
          devToken: 'super-secret-token',
          tokenStorage: storage,
        ),
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) => logs.add(line),
        ),
      );

      expect(logs.join('\n'), isNot(contains('super-secret-token')));
    });

    test('fuera de modo debug no intenta guardar nada', () async {
      final storage = _FakeTokenStorage();

      await bootstrapDevAuthToken(
        devToken: 'real-token',
        isDebugMode: false,
        tokenStorage: storage,
      );

      expect(storage.savedTokens, isEmpty);
    });
  });
}

class _FakeTokenStorage implements TokenStorage {
  final savedTokens = <String>[];

  @override
  Future<void> saveAccessToken(String token) async {
    savedTokens.add(token);
  }

  @override
  Future<String?> readAccessToken() async {
    if (savedTokens.isEmpty) {
      return null;
    }

    return savedTokens.last;
  }

  @override
  Future<bool> hasAccessToken() async => savedTokens.isNotEmpty;

  @override
  Future<void> deleteAccessToken() async {
    savedTokens.clear();
  }

  @override
  Future<void> clearSession() async {
    savedTokens.clear();
  }
}
