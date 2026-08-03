import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_exception.dart';

const _unset = Object();

class ChangePasswordState extends Equatable {
  const ChangePasswordState({
    required this.isSubmitting,
    required this.error,
    required this.successMessage,
  });

  factory ChangePasswordState.initial() {
    return const ChangePasswordState(
      isSubmitting: false,
      error: null,
      successMessage: null,
    );
  }

  final bool isSubmitting;
  final AppException? error;
  final String? successMessage;

  ChangePasswordState copyWith({
    bool? isSubmitting,
    Object? error = _unset,
    Object? successMessage = _unset,
  }) {
    return ChangePasswordState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: identical(error, _unset) ? this.error : error as AppException?,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
    );
  }

  @override
  List<Object?> get props => [isSubmitting, error, successMessage];
}
