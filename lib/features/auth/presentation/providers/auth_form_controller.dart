import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../data/providers/auth_data_providers.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_form_state.dart';
import 'auth_session_providers.dart';

class AuthFormController extends Notifier<AuthFormState> {
  late final AuthRepository _repository;

  @override
  AuthFormState build() {
    _repository = ref.watch(authRepositoryProvider);
    return AuthFormState.initial();
  }

  Future<bool> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String referralMatricula,
  }) async {
    if (state.isRegistering) {
      return false;
    }

    state = state.copyWith(
      isRegistering: true,
      error: null,
      successMessage: null,
    );

    try {
      final result = await _repository.register(
        email: email,
        firstName: firstName,
        lastName: lastName,
        password: password,
        referralMatricula: referralMatricula,
      );
      ref
          .read(authSessionControllerProvider.notifier)
          .updateAuthenticatedProfile(result.user);
      return true;
    } catch (error) {
      state = state.copyWith(error: _toAppException(error));
      return false;
    } finally {
      state = state.copyWith(isRegistering: false);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    if (state.isLoggingIn) {
      return false;
    }

    state = state.copyWith(
      isLoggingIn: true,
      error: null,
      successMessage: null,
    );

    try {
      final result = await _repository.login(email: email, password: password);
      ref
          .read(authSessionControllerProvider.notifier)
          .updateAuthenticatedProfile(result.user);
      return true;
    } catch (error) {
      state = state.copyWith(error: _toAppException(error));
      return false;
    } finally {
      state = state.copyWith(isLoggingIn: false);
    }
  }

  Future<bool> forgotPassword({
    required String email,
    required String referralMatricula,
  }) async {
    if (state.isRecoveringPassword) {
      return false;
    }

    state = state.copyWith(
      isRecoveringPassword: true,
      error: null,
      successMessage: null,
    );

    try {
      await _repository.forgotPassword(
        email: email,
        referralMatricula: referralMatricula,
      );
      state = state.copyWith(
        successMessage:
            'Si los datos coinciden, recibirás una clave temporal en tu correo.',
      );
      return true;
    } catch (error) {
      state = state.copyWith(error: _toAppException(error));
      return false;
    } finally {
      state = state.copyWith(isRecoveringPassword: false);
    }
  }

  void clearError() {
    if (state.error == null) {
      return;
    }

    state = state.copyWith(error: null);
  }

  void clearSuccessMessage() {
    if (state.successMessage == null) {
      return;
    }

    state = state.copyWith(successMessage: null);
  }

  AppException _toAppException(Object error) {
    return ErrorMapper.fromObject(error);
  }
}
