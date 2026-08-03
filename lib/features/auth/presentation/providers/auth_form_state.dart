import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_exception.dart';

const _unset = Object();

class AuthFormState extends Equatable {
  const AuthFormState({
    required this.isRegistering,
    required this.isLoggingIn,
    required this.isRecoveringPassword,
    required this.error,
    required this.successMessage,
  });

  factory AuthFormState.initial() {
    return const AuthFormState(
      isRegistering: false,
      isLoggingIn: false,
      isRecoveringPassword: false,
      error: null,
      successMessage: null,
    );
  }

  final bool isRegistering;
  final bool isLoggingIn;
  final bool isRecoveringPassword;
  final AppException? error;
  final String? successMessage;

  AuthFormState copyWith({
    bool? isRegistering,
    bool? isLoggingIn,
    bool? isRecoveringPassword,
    Object? error = _unset,
    Object? successMessage = _unset,
  }) {
    return AuthFormState(
      isRegistering: isRegistering ?? this.isRegistering,
      isLoggingIn: isLoggingIn ?? this.isLoggingIn,
      isRecoveringPassword: isRecoveringPassword ?? this.isRecoveringPassword,
      error: identical(error, _unset) ? this.error : error as AppException?,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    isRegistering,
    isLoggingIn,
    isRecoveringPassword,
    error,
    successMessage,
  ];
}
