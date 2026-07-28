import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/profile.dart';

const _unset = Object();

class ProfileState extends Equatable {
  const ProfileState({
    required this.isInitialLoading,
    required this.isSubmitting,
    required this.profile,
    required this.error,
  });

  factory ProfileState.initial() {
    return const ProfileState(
      isInitialLoading: false,
      isSubmitting: false,
      profile: null,
      error: null,
    );
  }

  final bool isInitialLoading;
  final bool isSubmitting;
  final Profile? profile;
  final AppException? error;

  bool get hasProfile => profile != null;
  bool get isProfileCompleted => profile?.profileCompleted ?? false;

  ProfileState copyWith({
    bool? isInitialLoading,
    bool? isSubmitting,
    Object? profile = _unset,
    Object? error = _unset,
  }) {
    return ProfileState(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      profile: identical(profile, _unset) ? this.profile : profile as Profile?,
      error: identical(error, _unset) ? this.error : error as AppException?,
    );
  }

  @override
  List<Object?> get props => [isInitialLoading, isSubmitting, profile, error];
}
