import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/errors/api_exception.dart';
import 'package:ocupa2/core/errors/unknown_exception.dart';
import 'package:ocupa2/core/storage/secure_storage_provider.dart';
import 'package:ocupa2/core/storage/token_storage.dart';
import 'package:ocupa2/features/auth/presentation/providers/auth_session_providers.dart';
import 'package:ocupa2/features/change_password/data/providers/change_password_data_providers.dart';
import 'package:ocupa2/features/change_password/domain/repositories/change_password_repository.dart';
import 'package:ocupa2/features/change_password/presentation/providers/change_password_controller.dart';
import 'package:ocupa2/features/change_password/presentation/providers/change_password_presentation_providers.dart';
import 'package:ocupa2/features/change_password/presentation/providers/change_password_state.dart';
import 'package:ocupa2/features/profile/data/providers/profile_data_providers.dart';
import 'package:ocupa2/features/profile/domain/entities/profile.dart';
import 'package:ocupa2/features/profile/domain/repositories/profile_repository.dart';

void main() {
  test('estado inicial', () {
    final setup = _setup();

    final state = setup.state;

    expect(state.isSubmitting, isFalse);
    expect(state.error, isNull);
    expect(state.successMessage, isNull);
  });

  test('changePassword activa isSubmitting', () async {
    final setup = _setup();
    final completer = Completer<void>();
    setup.repository.completers.add(completer);

    final future = setup.notifier.changePassword(password: 'NuevaClave123');

    expect(setup.state.isSubmitting, isTrue);
    completer.complete();
    await future;
  });

  test('changePassword desactiva isSubmitting en éxito', () async {
    final setup = _setup();

    await setup.notifier.changePassword(password: 'NuevaClave123');

    expect(setup.state.isSubmitting, isFalse);
  });

  test('changePassword desactiva isSubmitting en error', () async {
    final setup = _setup();
    setup.repository.error = const ApiException(message: 'Fallo');

    await setup.notifier.changePassword(password: 'NuevaClave123');

    expect(setup.state.isSubmitting, isFalse);
  });

  test('éxito devuelve true', () async {
    final setup = _setup();

    final result = await setup.notifier.changePassword(
      password: 'NuevaClave123',
    );

    expect(result, isTrue);
  });

  test('éxito guarda successMessage', () async {
    final setup = _setup();

    await setup.notifier.changePassword(password: 'NuevaClave123');

    expect(setup.state.successMessage, 'Contraseña actualizada correctamente.');
  });

  test('error devuelve false', () async {
    final setup = _setup();
    setup.repository.error = const ApiException(message: 'Fallo');

    final result = await setup.notifier.changePassword(
      password: 'NuevaClave123',
    );

    expect(result, isFalse);
  });

  test('error guarda AppException', () async {
    final setup = _setup();
    setup.repository.error = const ApiException(message: 'Fallo');

    await setup.notifier.changePassword(password: 'NuevaClave123');

    expect(setup.state.error, isA<ApiException>());
  });

  test('error inesperado se convierte con ErrorMapper.fromObject', () async {
    final setup = _setup();
    setup.repository.error = StateError('boom');

    await setup.notifier.changePassword(password: 'NuevaClave123');

    expect(setup.state.error, isA<UnknownException>());
  });

  test('la contraseña se envía sin modificación', () async {
    final setup = _setup();

    await setup.notifier.changePassword(password: '  NuevaClave123  ');

    expect(setup.repository.passwords.single, '  NuevaClave123  ');
  });

  test('evita envíos duplicados', () async {
    final setup = _setup();
    final completer = Completer<void>();
    setup.repository.completers.add(completer);

    final firstFuture = setup.notifier.changePassword(
      password: 'NuevaClave123',
    );
    final secondFuture = setup.notifier.changePassword(
      password: 'OtraClave123',
    );

    expect(setup.repository.changePasswordCalls, 1);
    completer.complete();
    final results = await Future.wait([firstFuture, secondFuture]);

    expect(results, [true, false]);
    expect(setup.repository.passwords, ['NuevaClave123']);
  });

  test('clearError elimina error', () async {
    final setup = _setup();
    setup.repository.error = const ApiException(message: 'Fallo');
    await setup.notifier.changePassword(password: 'NuevaClave123');

    setup.notifier.clearError();

    expect(setup.state.error, isNull);
  });

  test('clearSuccessMessage elimina mensaje', () async {
    final setup = _setup();
    await setup.notifier.changePassword(password: 'NuevaClave123');

    setup.notifier.clearSuccessMessage();

    expect(setup.state.successMessage, isNull);
  });

  test('no modifica AuthSessionController', () async {
    final setup = _setup();
    final sessionBefore = setup.container.read(authSessionControllerProvider);

    await setup.notifier.changePassword(password: 'NuevaClave123');

    final sessionAfter = setup.container.read(authSessionControllerProvider);
    expect(sessionAfter, sessionBefore);
  });

  test('el repository puede sustituirse con provider override', () {
    final fakeRepository = _FakeChangePasswordRepository();
    final container = ProviderContainer(
      overrides: [
        changePasswordRepositoryProvider.overrideWithValue(fakeRepository),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(changePasswordRepositoryProvider),
      same(fakeRepository),
    );
  });

  test('copyWith permite limpiar campos opcionales', () {
    const state = ChangePasswordState(
      isSubmitting: false,
      error: ApiException(message: 'Fallo'),
      successMessage: 'Listo',
    );

    final next = state.copyWith(error: null, successMessage: null);

    expect(next.error, isNull);
    expect(next.successMessage, isNull);
  });
}

_Setup _setup() {
  final repository = _FakeChangePasswordRepository();
  final container = ProviderContainer(
    overrides: [
      changePasswordRepositoryProvider.overrideWithValue(repository),
      tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
      profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
    ],
  );
  addTearDown(container.dispose);

  return _Setup(container: container, repository: repository);
}

class _Setup {
  const _Setup({required this.container, required this.repository});

  final ProviderContainer container;
  final _FakeChangePasswordRepository repository;

  ChangePasswordState get state =>
      container.read(changePasswordControllerProvider);

  ChangePasswordController get notifier =>
      container.read(changePasswordControllerProvider.notifier);
}

class _FakeChangePasswordRepository implements ChangePasswordRepository {
  final completers = Queue<Completer<void>>();
  final passwords = <String>[];
  Object? error;
  int changePasswordCalls = 0;

  @override
  Future<void> changePassword({required String password}) async {
    changePasswordCalls++;
    passwords.add(password);

    if (error != null) {
      throw error!;
    }

    if (completers.isNotEmpty) {
      return completers.removeFirst().future;
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
    return const Profile(
      id: 'profile-id',
      email: 'user@example.com',
      profileCompleted: true,
    );
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
    return const Profile(
      id: 'profile-id',
      email: 'user@example.com',
      profileCompleted: true,
    );
  }
}
