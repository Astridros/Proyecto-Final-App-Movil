import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocupa2/core/errors/api_exception.dart';
import 'package:ocupa2/core/storage/secure_storage_provider.dart';
import 'package:ocupa2/core/storage/token_storage.dart';
import 'package:ocupa2/features/auth/presentation/providers/auth_session_providers.dart';
import 'package:ocupa2/features/offers/data/providers/offers_data_providers.dart';
import 'package:ocupa2/features/offers/domain/entities/apply_offer_answer.dart';
import 'package:ocupa2/features/offers/domain/entities/apply_offer_result.dart';
import 'package:ocupa2/features/offers/domain/entities/job_type.dart';
import 'package:ocupa2/features/offers/domain/entities/offer.dart';
import 'package:ocupa2/features/offers/domain/entities/offer_like_result.dart';
import 'package:ocupa2/features/offers/domain/repositories/offers_repository.dart';
import 'package:ocupa2/features/offers/presentation/providers/offer_like_providers.dart';
import 'package:ocupa2/features/profile/data/providers/profile_data_providers.dart';
import 'package:ocupa2/features/profile/domain/entities/profile.dart';
import 'package:ocupa2/features/profile/domain/repositories/profile_repository.dart';

void main() {
  test('usuario no autenticado mantiene sesion sin autenticar', () async {
    final setup = _setup(hasToken: false);

    await setup.container
        .read(authSessionControllerProvider.notifier)
        .restoreSession();

    final state = setup.container.read(authSessionControllerProvider);
    expect(state.isAuthenticated, isFalse);
    expect(state.hasCheckedSession, isTrue);
    expect(setup.repository.getProfileCalls, 0);
  });

  test('token valido restaura GET me y profileCompleted false', () async {
    final setup = _setup(hasToken: true, profileCompleted: false);

    await setup.container
        .read(authSessionControllerProvider.notifier)
        .restoreSession();

    final state = setup.container.read(authSessionControllerProvider);
    expect(setup.repository.getProfileCalls, 1);
    expect(state.isAuthenticated, isTrue);
    expect(state.requiresProfileCompletion, isTrue);
  });

  test('token valido restaura GET me y profileCompleted true', () async {
    final setup = _setup(hasToken: true, profileCompleted: true);

    await setup.container
        .read(authSessionControllerProvider.notifier)
        .restoreSession();

    final state = setup.container.read(authSessionControllerProvider);
    expect(state.canAccessAuthenticatedRoutes, isTrue);
    expect(state.requiresProfileCompletion, isFalse);
  });

  test('mientras carga GET me expone isRestoring', () async {
    final setup = _setup(hasToken: true);
    setup.repository.profileCompleter = Completer<Profile>();

    final future = setup.container
        .read(authSessionControllerProvider.notifier)
        .restoreSession();

    expect(
      setup.container.read(authSessionControllerProvider).isRestoring,
      isTrue,
    );
    setup.repository.profileCompleter!.complete(_profile());
    await future;
  });

  test('error de GET me no deja loading infinito', () async {
    final setup = _setup(hasToken: true);
    setup.repository.profileError = const ApiException(message: 'Fallo');

    await setup.container
        .read(authSessionControllerProvider.notifier)
        .restoreSession();

    final state = setup.container.read(authSessionControllerProvider);
    expect(state.isRestoring, isFalse);
    expect(state.isAuthenticated, isFalse);
    expect(state.error, isA<ApiException>());
  });

  test('updateAuthenticatedProfile marca profileCompleted true', () {
    final setup = _setup(hasToken: true);

    setup.container
        .read(authSessionControllerProvider.notifier)
        .updateAuthenticatedProfile(_profile(profileCompleted: true));

    final state = setup.container.read(authSessionControllerProvider);
    expect(state.isAuthenticated, isTrue);
    expect(state.canAccessAuthenticatedRoutes, isTrue);
  });

  test('restaurar app con token vuelve a comprobar profileCompleted', () async {
    final setup = _setup(hasToken: true, profileCompleted: true);

    await setup.container
        .read(authSessionControllerProvider.notifier)
        .restoreSession();

    expect(setup.repository.getProfileCalls, 1);
  });

  test('logout elimina el token', () async {
    final setup = _setup(hasToken: true);
    setup.container
        .read(authSessionControllerProvider.notifier)
        .updateAuthenticatedProfile(_profile(profileCompleted: true));

    await setup.container.read(authSessionControllerProvider.notifier).logout();

    expect(await setup.tokenStorage.hasAccessToken(), isFalse);
    expect(setup.tokenStorage.clearSessionCalls, 1);
  });

  test('logout limpia el perfil y establece sesion no autenticada', () async {
    final setup = _setup(hasToken: true);
    setup.container
        .read(authSessionControllerProvider.notifier)
        .updateAuthenticatedProfile(_profile(profileCompleted: true));

    await setup.container.read(authSessionControllerProvider.notifier).logout();

    final state = setup.container.read(authSessionControllerProvider);
    expect(state.profile, isNull);
    expect(state.isAuthenticated, isFalse);
    expect(state.hasCheckedSession, isTrue);
    expect(state.error, isNull);
  });

  test('logout activa y desactiva isLoggingOut', () async {
    final setup = _setup(hasToken: true);
    setup.tokenStorage.clearSessionCompleter = Completer<void>();
    setup.container
        .read(authSessionControllerProvider.notifier)
        .updateAuthenticatedProfile(_profile(profileCompleted: true));

    final future = setup.container
        .read(authSessionControllerProvider.notifier)
        .logout();

    expect(
      setup.container.read(authSessionControllerProvider).isLoggingOut,
      isTrue,
    );
    setup.tokenStorage.clearSessionCompleter!.complete();
    await future;

    expect(
      setup.container.read(authSessionControllerProvider).isLoggingOut,
      isFalse,
    );
  });

  test('error al limpiar almacenamiento conserva estado coherente', () async {
    final setup = _setup(hasToken: true);
    final profile = _profile(profileCompleted: true);
    setup.tokenStorage.clearSessionError = const ApiException(
      message: 'No se pudo cerrar sesion',
    );
    setup.container
        .read(authSessionControllerProvider.notifier)
        .updateAuthenticatedProfile(profile);

    await setup.container.read(authSessionControllerProvider.notifier).logout();

    final state = setup.container.read(authSessionControllerProvider);
    expect(state.isAuthenticated, isTrue);
    expect(state.profile, profile);
    expect(state.isLoggingOut, isFalse);
    expect(state.error?.message, 'No se pudo cerrar sesion');
  });

  test('logout no llama ningun endpoint', () async {
    final setup = _setup(hasToken: true);
    setup.container
        .read(authSessionControllerProvider.notifier)
        .updateAuthenticatedProfile(_profile(profileCompleted: true));

    await setup.container.read(authSessionControllerProvider.notifier).logout();

    expect(setup.repository.getProfileCalls, 0);
  });

  test(
    'logout invalida estado de likes y nueva sesion no hereda estado',
    () async {
      final setup = _setup(hasToken: true);
      setup.container
          .read(authSessionControllerProvider.notifier)
          .updateAuthenticatedProfile(_profile(profileCompleted: true));
      setup.container
          .read(offerLikeControllerProvider('offer-a').notifier)
          .syncFromOffer(likedByMe: true, likesCount: 5);

      expect(
        setup.container.read(offerLikeControllerProvider('offer-a')).liked,
        isTrue,
      );

      await setup.container
          .read(authSessionControllerProvider.notifier)
          .logout();

      final stateAfterLogout = setup.container.read(
        offerLikeControllerProvider('offer-a'),
      );
      expect(stateAfterLogout.liked, isFalse);
      expect(stateAfterLogout.likesCount, 0);
    },
  );
}

_Setup _setup({required bool hasToken, bool profileCompleted = false}) {
  final repository = _FakeProfileRepository(
    profile: _profile(profileCompleted: profileCompleted),
  );
  final tokenStorage = _FakeTokenStorage(hasToken ? 'token' : null);
  final container = ProviderContainer(
    overrides: [
      tokenStorageProvider.overrideWithValue(tokenStorage),
      profileRepositoryProvider.overrideWithValue(repository),
      offersRepositoryProvider.overrideWithValue(_FakeOffersRepository()),
    ],
  );
  addTearDown(container.dispose);

  return _Setup(
    container: container,
    repository: repository,
    tokenStorage: tokenStorage,
  );
}

class _FakeOffersRepository implements OffersRepository {
  @override
  Future<List<JobType>> getJobTypes() async => const [];

  @override
  Future<List<Offer>> getOffers({
    String? jobTypeKey,
    String? contractType,
  }) async {
    return const [];
  }

  @override
  Future<Offer> getOfferById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<ApplyOfferResult> applyToOffer({
    required String offerId,
    required String comment,
    required List<ApplyOfferAnswer> answers,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<OfferLikeResult> likeOffer(String offerId) async {
    return const OfferLikeResult(liked: true, likesCount: 1);
  }

  @override
  Future<OfferLikeResult> unlikeOffer(String offerId) async {
    return const OfferLikeResult(liked: false, likesCount: 0);
  }

  @override
  Future<List<Offer>> getMyLikedOffers() async => const [];
}

Profile _profile({bool profileCompleted = false}) {
  return Profile(
    id: 'profile-id',
    email: 'user@example.com',
    firstName: 'Ana',
    lastName: 'Perez',
    birthDate: DateTime.utc(1997, 5, 12),
    cedula: '00112345678',
    gender: 'femenino',
    profileCompleted: profileCompleted,
  );
}

class _Setup {
  const _Setup({
    required this.container,
    required this.repository,
    required this.tokenStorage,
  });

  final ProviderContainer container;
  final _FakeProfileRepository repository;
  final _FakeTokenStorage tokenStorage;
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({required this.profile});

  final Profile profile;
  Completer<Profile>? profileCompleter;
  Object? profileError;
  int getProfileCalls = 0;

  @override
  Future<Profile> getProfile() async {
    getProfileCalls++;
    if (profileError != null) {
      throw profileError!;
    }

    final completer = profileCompleter;
    if (completer != null) {
      return completer.future;
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
  }) async {
    return _profile(profileCompleted: true);
  }
}

class _FakeTokenStorage implements TokenStorage {
  _FakeTokenStorage(this._token);

  String? _token;
  Completer<void>? clearSessionCompleter;
  Object? clearSessionError;
  int clearSessionCalls = 0;

  @override
  Future<void> saveAccessToken(String token) async {
    _token = token;
  }

  @override
  Future<String?> readAccessToken() async {
    final normalized = _token?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  @override
  Future<bool> hasAccessToken() async {
    return (await readAccessToken()) != null;
  }

  @override
  Future<void> deleteAccessToken() async {
    _token = null;
  }

  @override
  Future<void> clearSession() async {
    clearSessionCalls++;
    if (clearSessionError != null) {
      throw clearSessionError!;
    }

    final completer = clearSessionCompleter;
    if (completer != null) {
      await completer.future;
    }

    _token = null;
  }
}
