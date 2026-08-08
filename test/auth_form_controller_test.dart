import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/errors/api_exception.dart';
import 'package:ocupa2/core/errors/unknown_exception.dart';
import 'package:ocupa2/core/storage/secure_storage_provider.dart';
import 'package:ocupa2/core/storage/token_storage.dart';
import 'package:ocupa2/features/auth/data/providers/auth_data_providers.dart';
import 'package:ocupa2/features/auth/domain/entities/auth_session_result.dart';
import 'package:ocupa2/features/auth/domain/repositories/auth_repository.dart';
import 'package:ocupa2/features/auth/presentation/providers/auth_form_controller.dart';
import 'package:ocupa2/features/auth/presentation/providers/auth_form_providers.dart';
import 'package:ocupa2/features/auth/presentation/providers/auth_form_state.dart';
import 'package:ocupa2/features/auth/presentation/providers/auth_session_providers.dart';
import 'package:ocupa2/features/profile/data/providers/profile_data_providers.dart';
import 'package:ocupa2/features/profile/domain/entities/profile.dart';
import 'package:ocupa2/features/profile/domain/repositories/profile_repository.dart';

void main() {
  test('estado inicial', () {
    final setup = _setup();

    final state = setup.state;

    expect(state.isRegistering, isFalse);
    expect(state.isLoggingIn, isFalse);
    expect(state.isRecoveringPassword, isFalse);
    expect(state.error, isNull);
    expect(state.successMessage, isNull);
  });

  test('register activa y desactiva isRegistering', () async {
    final setup = _setup();
    final completer = Completer<AuthSessionResult>();
    setup.repository.registerCompleters.add(completer);

    final future = setup.notifier.register(
      email: 'user@example.com',
      firstName: 'Ana',
      lastName: 'Perez',
      password: 'secret',
      referralMatricula: '99999999',
    );

    expect(setup.state.isRegistering, isTrue);
    completer.complete(_result(profileCompleted: false));
    await future;

    expect(setup.state.isRegistering, isFalse);
  });

  test('register exitoso devuelve true', () async {
    final setup = _setup();

    final result = await _register(setup);

    expect(result, isTrue);
  });

  test('register actualiza AuthSessionController', () async {
    final setup = _setup();

    await _register(setup);

    final session = setup.container.read(authSessionControllerProvider);
    expect(session.isAuthenticated, isTrue);
    expect(session.profile?.email, 'user@example.com');
  });

  test(
    'register con profileCompleted false deja sesion que requiere perfil',
    () async {
      final setup = _setup(registerResult: _result(profileCompleted: false));

      await _register(setup);

      expect(
        setup.container
            .read(authSessionControllerProvider)
            .requiresProfileCompletion,
        isTrue,
      );
    },
  );

  test('register con profileCompleted true permite flujo normal', () async {
    final setup = _setup(registerResult: _result(profileCompleted: true));

    await _register(setup);

    expect(
      setup.container
          .read(authSessionControllerProvider)
          .canAccessAuthenticatedRoutes,
      isTrue,
    );
  });

  test('register fallido devuelve false', () async {
    final setup = _setup();
    setup.repository.registerError = const ApiException(message: 'Fallo');

    final result = await _register(setup);

    expect(result, isFalse);
  });

  test('register fallido guarda AppException', () async {
    final setup = _setup();
    setup.repository.registerError = const ApiException(message: 'Fallo');

    await _register(setup);

    expect(setup.state.error, isA<ApiException>());
  });

  test('register duplicado se evita', () async {
    final setup = _setup();
    final completer = Completer<AuthSessionResult>();
    setup.repository.registerCompleters.add(completer);

    final firstFuture = _register(setup);
    final secondFuture = _register(setup);

    expect(setup.repository.registerCalls, 1);
    completer.complete(_result(profileCompleted: true));
    final results = await Future.wait([firstFuture, secondFuture]);

    expect(results, [true, false]);
  });

  test('login activa y desactiva isLoggingIn', () async {
    final setup = _setup();
    final completer = Completer<AuthSessionResult>();
    setup.repository.loginCompleters.add(completer);

    final future = setup.notifier.login(
      email: 'user@example.com',
      password: 'secret',
    );

    expect(setup.state.isLoggingIn, isTrue);
    completer.complete(_result(profileCompleted: true));
    await future;

    expect(setup.state.isLoggingIn, isFalse);
  });

  test('login exitoso devuelve true', () async {
    final setup = _setup();

    final result = await _login(setup);

    expect(result, isTrue);
  });

  test('login actualiza sesion sin reiniciar la app', () async {
    final setup = _setup();

    await _login(setup);

    final session = setup.container.read(authSessionControllerProvider);
    expect(session.isAuthenticated, isTrue);
    expect(session.hasCheckedSession, isTrue);
  });

  test('login respeta profileCompleted false', () async {
    final setup = _setup(loginResult: _result(profileCompleted: false));

    await _login(setup);

    expect(
      setup.container
          .read(authSessionControllerProvider)
          .requiresProfileCompletion,
      isTrue,
    );
  });

  test('login respeta profileCompleted true', () async {
    final setup = _setup(loginResult: _result(profileCompleted: true));

    await _login(setup);

    expect(
      setup.container
          .read(authSessionControllerProvider)
          .canAccessAuthenticatedRoutes,
      isTrue,
    );
  });

  test('login fallido conserva estado no autenticado previo', () async {
    final setup = _setup();
    setup.repository.loginError = const ApiException(message: 'Fallo');

    await _login(setup);

    expect(
      setup.container.read(authSessionControllerProvider).isAuthenticated,
      isFalse,
    );
  });

  test('login duplicado se evita', () async {
    final setup = _setup();
    final completer = Completer<AuthSessionResult>();
    setup.repository.loginCompleters.add(completer);

    final firstFuture = _login(setup);
    final secondFuture = _login(setup);

    expect(setup.repository.loginCalls, 1);
    completer.complete(_result(profileCompleted: true));
    final results = await Future.wait([firstFuture, secondFuture]);

    expect(results, [true, false]);
  });

  test('forgotPassword activa y desactiva loading', () async {
    final setup = _setup();
    final completer = Completer<void>();
    setup.repository.forgotPasswordCompleters.add(completer);

    final future = _forgotPassword(setup);

    expect(setup.state.isRecoveringPassword, isTrue);
    completer.complete();
    await future;

    expect(setup.state.isRecoveringPassword, isFalse);
  });

  test('forgotPassword exitoso devuelve true', () async {
    final setup = _setup();

    final result = await _forgotPassword(setup);

    expect(result, isTrue);
  });

  test('forgotPassword guarda mensaje de exito', () async {
    final setup = _setup();

    await _forgotPassword(setup);

    expect(
      setup.state.successMessage,
      'Si los datos coinciden, recibirás una clave temporal en tu correo.',
    );
  });

  test('forgotPassword no modifica AuthSessionController', () async {
    final setup = _setup();

    await _forgotPassword(setup);

    expect(
      setup.container.read(authSessionControllerProvider).isAuthenticated,
      isFalse,
    );
  });

  test('forgotPassword fallido devuelve false', () async {
    final setup = _setup();
    setup.repository.forgotPasswordError = const ApiException(message: 'Fallo');

    final result = await _forgotPassword(setup);

    expect(result, isFalse);
  });

  test('forgotPassword guarda AppException', () async {
    final setup = _setup();
    setup.repository.forgotPasswordError = const ApiException(message: 'Fallo');

    await _forgotPassword(setup);

    expect(setup.state.error, isA<ApiException>());
  });

  test('clearError elimina error', () async {
    final setup = _setup();
    setup.repository.loginError = const ApiException(message: 'Fallo');
    await _login(setup);

    setup.notifier.clearError();

    expect(setup.state.error, isNull);
  });

  test('clearSuccessMessage elimina mensaje', () async {
    final setup = _setup();
    await _forgotPassword(setup);

    setup.notifier.clearSuccessMessage();

    expect(setup.state.successMessage, isNull);
  });

  test(
    'errores inesperados se convierten con ErrorMapper.fromObject',
    () async {
      final setup = _setup();
      setup.repository.loginError = StateError('boom');

      await _login(setup);

      expect(setup.state.error, isA<UnknownException>());
    },
  );
}

Future<bool> _register(_Setup setup) {
  return setup.notifier.register(
    email: 'user@example.com',
    firstName: 'Ana',
    lastName: 'Perez',
    password: 'secret',
    referralMatricula: '99999999',
  );
}

Future<bool> _login(_Setup setup) {
  return setup.notifier.login(email: 'user@example.com', password: 'secret');
}

Future<bool> _forgotPassword(_Setup setup) {
  return setup.notifier.forgotPassword(
    email: 'user@example.com',
    referralMatricula: '99999999',
  );
}

_Setup _setup({
  AuthSessionResult? registerResult,
  AuthSessionResult? loginResult,
}) {
  final repository = _FakeAuthRepository(
    registerResult: registerResult ?? _result(profileCompleted: true),
    loginResult: loginResult ?? _result(profileCompleted: true),
  );
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
      profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
    ],
  );
  addTearDown(container.dispose);

  return _Setup(container: container, repository: repository);
}

AuthSessionResult _result({required bool profileCompleted}) {
  return AuthSessionResult(
    token: 'token',
    tokenType: 'Bearer',
    user: Profile(
      id: 'profile-id',
      email: 'user@example.com',
      firstName: 'Ana',
      lastName: 'Perez',
      profileCompleted: profileCompleted,
    ),
  );
}

class _Setup {
  const _Setup({required this.container, required this.repository});

  final ProviderContainer container;
  final _FakeAuthRepository repository;

  AuthFormState get state => container.read(authFormControllerProvider);

  AuthFormController get notifier =>
      container.read(authFormControllerProvider.notifier);
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    required this.registerResult,
    required this.loginResult,
  });

  final AuthSessionResult registerResult;
  final AuthSessionResult loginResult;
  final registerCompleters = Queue<Completer<AuthSessionResult>>();
  final loginCompleters = Queue<Completer<AuthSessionResult>>();
  final forgotPasswordCompleters = Queue<Completer<void>>();
  Object? registerError;
  Object? loginError;
  Object? forgotPasswordError;
  int registerCalls = 0;
  int loginCalls = 0;
  int forgotPasswordCalls = 0;

  @override
  Future<AuthSessionResult> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String referralMatricula,
  }) async {
    registerCalls++;
    if (registerError != null) {
      throw registerError!;
    }

    if (registerCompleters.isNotEmpty) {
      return registerCompleters.removeFirst().future;
    }

    return registerResult;
  }

  @override
  Future<AuthSessionResult> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    if (loginError != null) {
      throw loginError!;
    }

    if (loginCompleters.isNotEmpty) {
      return loginCompleters.removeFirst().future;
    }

    return loginResult;
  }

  @override
  Future<void> forgotPassword({
    required String email,
    required String referralMatricula,
  }) async {
    forgotPasswordCalls++;
    if (forgotPasswordError != null) {
      throw forgotPasswordError!;
    }

    if (forgotPasswordCompleters.isNotEmpty) {
      return forgotPasswordCompleters.removeFirst().future;
    }
  }
}

class _FakeTokenStorage implements TokenStorage {
  @override
  Future<void> saveAccessToken(String token) async {}

  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<bool> hasAccessToken() async => false;

  @override
  Future<void> deleteAccessToken() async {}

  @override
  Future<void> clearSession() async {}
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<Profile> getProfile() async {
    return _result(profileCompleted: false).user;
  }

  @override
  Future<Profile> updateProfile({
    required String firstName,
    required String lastName,
    required String cedula,
    required String gender,
    required DateTime birthDate,
    String? email,
    String? referralMatricula,
  }) async {
    return _result(profileCompleted: true).user;
  }
}
