import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/storage/secure_storage_provider.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../profile/data/providers/profile_data_providers.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import 'auth_session_state.dart';

class AuthSessionController extends Notifier<AuthSessionState> {
  late final TokenStorage _tokenStorage;
  late final ProfileRepository _profileRepository;

  @override
  AuthSessionState build() {
    _tokenStorage = ref.watch(tokenStorageProvider);
    _profileRepository = ref.watch(profileRepositoryProvider);
    return AuthSessionState.initial();
  }

  Future<void> restoreSession() async {
    if (state.isRestoring) {
      return;
    }

    state = state.copyWith(isRestoring: true, error: null);

    try {
      final hasToken = await _tokenStorage.hasAccessToken();
      if (!hasToken) {
        state = state.copyWith(
          isAuthenticated: false,
          profile: null,
          error: null,
          hasCheckedSession: true,
        );
        return;
      }

      final profile = await _profileRepository.getProfile();
      state = state.copyWith(
        isAuthenticated: true,
        profile: profile,
        error: null,
        hasCheckedSession: true,
      );
    } catch (error) {
      state = state.copyWith(
        isAuthenticated: false,
        profile: null,
        error: ErrorMapper.fromObject(error),
        hasCheckedSession: true,
      );
    } finally {
      state = state.copyWith(isRestoring: false);
    }
  }

  void updateAuthenticatedProfile(Profile profile) {
    state = state.copyWith(
      isAuthenticated: true,
      profile: profile,
      error: null,
      hasCheckedSession: true,
    );
  }
}
