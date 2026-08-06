import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../data/providers/change_password_data_providers.dart';
import '../../domain/repositories/change_password_repository.dart';
import 'change_password_state.dart';

class ChangePasswordController extends Notifier<ChangePasswordState> {
  late final ChangePasswordRepository _repository;

  @override
  ChangePasswordState build() {
    _repository = ref.watch(changePasswordRepositoryProvider);
    return ChangePasswordState.initial();
  }

  Future<bool> changePassword({required String password}) async {
    if (state.isSubmitting) {
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      error: null,
      successMessage: null,
    );

    try {
      await _repository.changePassword(password: password);
      state = state.copyWith(
        successMessage: 'Contraseña actualizada correctamente.',
      );
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
