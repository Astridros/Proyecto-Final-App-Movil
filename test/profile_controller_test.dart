import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/errors/api_exception.dart';
import 'package:ocupa2/core/errors/unknown_exception.dart';
import 'package:ocupa2/features/profile/data/providers/profile_data_providers.dart';
import 'package:ocupa2/features/profile/domain/entities/profile.dart';
import 'package:ocupa2/features/profile/domain/repositories/profile_repository.dart';
import 'package:ocupa2/features/profile/presentation/providers/profile_controller.dart';
import 'package:ocupa2/features/profile/presentation/providers/profile_presentation_providers.dart';
import 'package:ocupa2/features/profile/presentation/providers/profile_state.dart';

void main() {
  test('estado inicial', () {
    final setup = _setup();

    final state = setup.state;

    expect(state.isInitialLoading, isFalse);
    expect(state.isSubmitting, isFalse);
    expect(state.profile, isNull);
    expect(state.error, isNull);
    expect(state.hasProfile, isFalse);
    expect(state.isProfileCompleted, isFalse);
  });

  test('loadProfile activa loading', () async {
    final setup = _setup();
    final completer = Completer<Profile>();
    setup.repository.profileCompleters.add(completer);

    final future = setup.notifier.loadProfile();

    expect(setup.state.isInitialLoading, isTrue);
    completer.complete(_profile(profileCompleted: false));
    await future;

    expect(setup.state.isInitialLoading, isFalse);
  });

  test('loadProfile guarda perfil incompleto', () async {
    final setup = _setup(profile: _profile(profileCompleted: false));

    await setup.notifier.loadProfile();

    expect(setup.state.profile?.id, 'profile-1');
    expect(setup.state.hasProfile, isTrue);
    expect(setup.state.isProfileCompleted, isFalse);
  });

  test('loadProfile guarda perfil completado', () async {
    final setup = _setup(profile: _profile(profileCompleted: true));

    await setup.notifier.loadProfile();

    expect(setup.state.profile?.profileCompleted, isTrue);
    expect(setup.state.isProfileCompleted, isTrue);
  });

  test('loadProfile guarda AppException', () async {
    final setup = _setup();
    setup.repository.profileError = const ApiException(message: 'Fallo');

    await setup.notifier.loadProfile();

    expect(setup.state.error, isA<ApiException>());
    expect(setup.state.isInitialLoading, isFalse);
  });

  test('loadProfile convierte errores inesperados', () async {
    final setup = _setup();
    setup.repository.profileError = StateError('boom');

    await setup.notifier.loadProfile();

    expect(setup.state.error, isA<UnknownException>());
  });

  test('evita cargas iniciales duplicadas', () async {
    final setup = _setup();
    final completer = Completer<Profile>();
    setup.repository.profileCompleters.add(completer);

    final firstFuture = setup.notifier.loadProfile();
    final secondFuture = setup.notifier.loadProfile();

    expect(setup.repository.getProfileCalls, 1);
    completer.complete(_profile());
    await Future.wait([firstFuture, secondFuture]);
  });

  test('submitProfile envia todos los valores correctamente', () async {
    final setup = _setup();
    final birthDate = DateTime.utc(1997, 5, 12);

    await setup.notifier.submitProfile(
      firstName: 'Astrid',
      lastName: 'Diaz',
      cedula: '00112345678',
      gender: 'female',
      birthDate: birthDate,
      email: 'astrid@example.com',
      referralMatricula: '12345678',
    );

    expect(
      setup.repository.updateCalls.single,
      _UpdateCall(
        firstName: 'Astrid',
        lastName: 'Diaz',
        cedula: '00112345678',
        gender: 'female',
        birthDate: birthDate,
        email: 'astrid@example.com',
        referralMatricula: '12345678',
      ),
    );
  });

  test('submitProfile guarda la respuesta actualizada', () async {
    final updated = _profile(id: 'updated', profileCompleted: true);
    final setup = _setup(updatedProfile: updated);

    await setup.notifier.submitProfile(
      firstName: 'Ana',
      lastName: 'Perez',
      cedula: '40212345678',
      gender: 'female',
      birthDate: DateTime.utc(1997, 5, 12),
    );

    expect(setup.state.profile, same(updated));
  });

  test('submitProfile devuelve true en exito', () async {
    final setup = _setup();

    final result = await setup.notifier.submitProfile(
      firstName: 'Astrid',
      lastName: 'Diaz',
      cedula: '00112345678',
      gender: 'female',
      birthDate: DateTime.utc(1997, 5, 12),
    );

    expect(result, isTrue);
  });

  test('submitProfile devuelve false en error', () async {
    final setup = _setup();
    setup.repository.updateError = const ApiException(message: 'Fallo');

    final result = await setup.notifier.submitProfile(
      firstName: 'Astrid',
      lastName: 'Diaz',
      cedula: '00112345678',
      gender: 'female',
      birthDate: DateTime.utc(1997, 5, 12),
    );

    expect(result, isFalse);
    expect(setup.state.error, isA<ApiException>());
  });

  test('conserva perfil previo al fallar', () async {
    final previous = _profile(id: 'previous');
    final setup = _setup(profile: previous);
    await setup.notifier.loadProfile();
    setup.repository.updateError = const ApiException(message: 'Fallo');

    await setup.notifier.submitProfile(
      firstName: 'Astrid',
      lastName: 'Diaz',
      cedula: '00112345678',
      gender: 'female',
      birthDate: DateTime.utc(1997, 5, 12),
    );

    expect(setup.state.profile, same(previous));
  });

  test('isSubmitting vuelve a false en exito', () async {
    final setup = _setup();
    final completer = Completer<Profile>();
    setup.repository.updateCompleters.add(completer);

    final future = setup.notifier.submitProfile(
      firstName: 'Astrid',
      lastName: 'Diaz',
      cedula: '00112345678',
      gender: 'female',
      birthDate: DateTime.utc(1997, 5, 12),
    );

    expect(setup.state.isSubmitting, isTrue);
    completer.complete(_profile());
    await future;

    expect(setup.state.isSubmitting, isFalse);
  });

  test('isSubmitting vuelve a false en error', () async {
    final setup = _setup();
    setup.repository.updateError = const ApiException(message: 'Fallo');

    await setup.notifier.submitProfile(
      firstName: 'Astrid',
      lastName: 'Diaz',
      cedula: '00112345678',
      gender: 'female',
      birthDate: DateTime.utc(1997, 5, 12),
    );

    expect(setup.state.isSubmitting, isFalse);
  });

  test('evita envios duplicados', () async {
    final setup = _setup();
    final completer = Completer<Profile>();
    setup.repository.updateCompleters.add(completer);

    final firstFuture = setup.notifier.submitProfile(
      firstName: 'Astrid',
      lastName: 'Diaz',
      cedula: '00112345678',
      gender: 'female',
      birthDate: DateTime.utc(1997, 5, 12),
    );
    final secondFuture = setup.notifier.submitProfile(
      firstName: 'Ana',
      lastName: 'Perez',
      cedula: '40212345678',
      gender: 'female',
      birthDate: DateTime.utc(1998, 6, 13),
    );

    expect(setup.repository.updateCalls, hasLength(1));
    completer.complete(_profile());
    final results = await Future.wait([firstFuture, secondFuture]);

    expect(results, [true, false]);
  });

  test('clearError elimina el error', () async {
    final setup = _setup();
    setup.repository.profileError = const ApiException(message: 'Fallo');
    await setup.notifier.loadProfile();

    setup.notifier.clearError();

    expect(setup.state.error, isNull);
  });

  test('copyWith permite limpiar campos opcionales', () {
    final state = ProfileState(
      isInitialLoading: false,
      isSubmitting: false,
      profile: _profile(),
      error: const ApiException(message: 'Fallo'),
    );

    final next = state.copyWith(profile: null, error: null);

    expect(next.profile, isNull);
    expect(next.error, isNull);
  });
}

_ControllerSetup _setup({Profile? profile, Profile? updatedProfile}) {
  final repository = _FakeProfileRepository(
    profile: profile ?? _profile(),
    updatedProfile: updatedProfile ?? _profile(profileCompleted: true),
  );
  final container = ProviderContainer(
    overrides: [profileRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);

  return _ControllerSetup(container: container, repository: repository);
}

Profile _profile({String id = 'profile-1', bool profileCompleted = false}) {
  return Profile(
    id: id,
    email: '$id@example.com',
    firstName: 'Astrid',
    lastName: 'Diaz',
    nombre: 'Astrid Diaz',
    referralMatricula: 'MAT-001',
    role: 'worker',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    lastLoginAt: DateTime(2026),
    birthDate: DateTime.utc(1997, 5, 12),
    cedula: '00112345678',
    gender: 'female',
    profileCompleted: profileCompleted,
  );
}

class _ControllerSetup {
  const _ControllerSetup({required this.container, required this.repository});

  final ProviderContainer container;
  final _FakeProfileRepository repository;

  ProfileState get state => container.read(profileControllerProvider);

  ProfileController get notifier =>
      container.read(profileControllerProvider.notifier);
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({required this.profile, required this.updatedProfile});

  final Profile profile;
  final Profile updatedProfile;
  final profileCompleters = Queue<Completer<Profile>>();
  final updateCompleters = Queue<Completer<Profile>>();
  final updateCalls = <_UpdateCall>[];
  Object? profileError;
  Object? updateError;
  int getProfileCalls = 0;

  @override
  Future<Profile> getProfile() async {
    getProfileCalls++;
    if (profileError != null) {
      throw profileError!;
    }

    if (profileCompleters.isNotEmpty) {
      return profileCompleters.removeFirst().future;
    }

    return profile;
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
    updateCalls.add(
      _UpdateCall(
        firstName: firstName,
        lastName: lastName,
        cedula: cedula,
        gender: gender,
        birthDate: birthDate,
        email: email,
        referralMatricula: referralMatricula,
      ),
    );

    if (updateError != null) {
      throw updateError!;
    }

    if (updateCompleters.isNotEmpty) {
      return updateCompleters.removeFirst().future;
    }

    return updatedProfile;
  }
}

class _UpdateCall {
  const _UpdateCall({
    required this.firstName,
    required this.lastName,
    required this.cedula,
    required this.gender,
    required this.birthDate,
    this.email,
    this.referralMatricula,
  });

  final String firstName;
  final String lastName;
  final String cedula;
  final String gender;
  final DateTime birthDate;
  final String? email;
  final String? referralMatricula;

  @override
  bool operator ==(Object other) {
    return other is _UpdateCall &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.cedula == cedula &&
        other.gender == gender &&
        other.birthDate == birthDate &&
        other.email == email &&
        other.referralMatricula == referralMatricula;
  }

  @override
  int get hashCode {
    return Object.hash(
      firstName,
      lastName,
      cedula,
      gender,
      birthDate,
      email,
      referralMatricula,
    );
  }

  @override
  String toString() {
    return 'UpdateCall(firstName: $firstName, lastName: $lastName, '
        'cedula: $cedula, gender: $gender, birthDate: $birthDate, '
        'email: $email, referralMatricula: $referralMatricula)';
  }
}
