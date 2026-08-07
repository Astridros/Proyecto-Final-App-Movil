import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/unknown_exception.dart';

import '../../data/providers/profile_data_providers.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/entities/profile.dart';

import 'profile_state.dart';

class ProfileController extends Notifier<ProfileState> {
  late final ProfileRepository _repository;

  @override
  ProfileState build() {
    _repository = ref.watch(profileRepositoryProvider);
    return ProfileState.initial();
  }

  Future<void> loadProfile() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final profile = await _repository.getProfile();

      state = state.copyWith(
        profile: profile,
      );
    } catch (error) {
      state = state.copyWith(
        error: _toAppException(error),
      );
    } finally {
      state = state.copyWith(
        isLoading: false,
      );
    }
  }

  Future<void> updateProfile(Profile profile) async {
    try {
      await _repository.updateProfile(profile);

      // Volver a cargar el perfil actualizado
      final updatedProfile = await _repository.getProfile();

      state = state.copyWith(
        profile: updatedProfile,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(
        error: _toAppException(error),
      );

      rethrow;
    }
  }

  AppException _toAppException(Object error) {
    if (error is AppException) {
      return error;
    }

    return UnknownException(
      message: 'Ocurrió un error inesperado.',
      cause: error,
    );
  }
}