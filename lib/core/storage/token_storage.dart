import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

abstract interface class TokenStorage {
  Future<void> saveAccessToken(String token);

  Future<String?> readAccessToken();

  Future<bool> hasAccessToken();

  Future<void> deleteAccessToken();

  Future<void> clearSession();
}

class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<void> saveAccessToken(String token) async {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) {
      await deleteAccessToken();
      return;
    }

    await _storage.write(key: StorageKeys.accessToken, value: normalizedToken);
  }

  @override
  Future<String?> readAccessToken() async {
    final token = await _storage.read(key: StorageKeys.accessToken);
    final normalizedToken = token?.trim();
    if (normalizedToken == null || normalizedToken.isEmpty) {
      return null;
    }

    return normalizedToken;
  }

  @override
  Future<bool> hasAccessToken() async {
    return (await readAccessToken()) != null;
  }

  @override
  Future<void> deleteAccessToken() async {
    await _storage.delete(key: StorageKeys.accessToken);
  }

  @override
  Future<void> clearSession() async {
    await deleteAccessToken();
  }
}
