import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../data/providers/profile_data_providers.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_state.dart';

class ProfileController extends Notifier<ProfileState> {
  late final ProfileRepository _repository;

  @override
  ProfileState build() {
    _repository = ref.watch(profileRepositoryProvider);
    return ProfileState.initial();
  }

  Future<void> loadProfile() async {
    if (state.isInitialLoading) {
      return;
    }

    state = state.copyWith(isInitialLoading: true, error: null);

    try {
      final profile = await _repository.getProfile();
      state = state.copyWith(profile: profile, error: null);
    } catch (error) {
      state = state.copyWith(error: _toAppException(error));
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  void setProfile(Profile profile) {
    state = state.copyWith(profile: profile, error: null);
  }

  Future<bool> submitProfile({
    required String firstName,
    required String lastName,
    required String cedula,
    required String gender,
    required DateTime birthDate,
    String? email,
    String? referralMatricula,
  }) async {
    if (state.isSubmitting) {
      return false;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final profile = await _repository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        cedula: cedula,
        gender: gender,
        birthDate: birthDate,
        email: email,
        referralMatricula: referralMatricula,
      );
      state = state.copyWith(profile: profile, error: null);
      return true;
    } catch (error) {
      state = state.copyWith(error: _toAppException(error));
      return false;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  void clearError() {
    if (state.error == null) {
      return;
    }

    state = state.copyWith(error: null);
  }

  AppException _toAppException(Object error) {
    return ErrorMapper.fromObject(error);
  }
}
