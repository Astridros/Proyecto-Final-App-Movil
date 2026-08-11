import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RememberedCredentials {
  const RememberedCredentials({required this.email, required this.password});

  final String email;
  final String password;
}

abstract interface class RememberedCredentialsStorage {
  Future<RememberedCredentials?> read();

  Future<void> save({required String email, required String password});

  Future<void> clear();
}

// Guarda el correo y la clave del login en el almacenamiento seguro del
// sistema (Keystore en Android), nunca en SharedPreferences ni en un archivo
// del proyecto. Solo se escribe cuando la persona marca la casilla, y se borra
// en cuanto la desmarca.
class SecureRememberedCredentialsStorage
    implements RememberedCredentialsStorage {
  const SecureRememberedCredentialsStorage(this._storage);

  static const _emailKey = 'ocupa2.remembered_email';
  static const _passwordKey = 'ocupa2.remembered_password';

  final FlutterSecureStorage _storage;

  @override
  Future<RememberedCredentials?> read() async {
    final email = (await _storage.read(key: _emailKey))?.trim();
    final password = await _storage.read(key: _passwordKey);

    if (email == null || email.isEmpty || password == null || password.isEmpty) {
      return null;
    }

    return RememberedCredentials(email: email, password: password);
  }

  @override
  Future<void> save({required String email, required String password}) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      await clear();
      return;
    }

    await _storage.write(key: _emailKey, value: normalizedEmail);
    await _storage.write(key: _passwordKey, value: password);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _passwordKey);
  }
}
