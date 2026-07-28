import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../profile/domain/entities/profile.dart';

const _unset = Object();

class AuthSessionState extends Equatable {
  const AuthSessionState({
    required this.isRestoring,
    required this.isAuthenticated,
    required this.profile,
    required this.error,
    required this.hasCheckedSession,
  });

  factory AuthSessionState.initial() {
    return const AuthSessionState(
      isRestoring: false,
      isAuthenticated: false,
      profile: null,
      error: null,
      hasCheckedSession: false,
    );
  }

  final bool isRestoring;
  final bool isAuthenticated;
  final Profile? profile;
  final AppException? error;
  final bool hasCheckedSession;

  bool get requiresProfileCompletion =>
      isAuthenticated && !(profile?.profileCompleted ?? true);

  bool get canAccessAuthenticatedRoutes =>
      isAuthenticated && (profile?.profileCompleted ?? false);

  AuthSessionState copyWith({
    bool? isRestoring,
    bool? isAuthenticated,
    Object? profile = _unset,
    Object? error = _unset,
    bool? hasCheckedSession,
  }) {
    return AuthSessionState(
      isRestoring: isRestoring ?? this.isRestoring,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      profile: identical(profile, _unset) ? this.profile : profile as Profile?,
      error: identical(error, _unset) ? this.error : error as AppException?,
      hasCheckedSession: hasCheckedSession ?? this.hasCheckedSession,
    );
  }

  @override
  List<Object?> get props => [
    isRestoring,
    isAuthenticated,
    profile,
    error,
    hasCheckedSession,
  ];
}
