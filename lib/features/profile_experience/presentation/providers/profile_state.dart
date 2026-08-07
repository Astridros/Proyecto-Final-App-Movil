import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/profile.dart';

const _unset = Object();

class ProfileState extends Equatable {
  const ProfileState({
    required this.isLoading,
    required this.profile,
    required this.error,
  });

  factory ProfileState.initial() {
    return const ProfileState(
      isLoading: false,
      profile: null,
      error: null,
    );
  }

  final bool isLoading;
  final Profile? profile;
  final AppException? error;

  bool get hasError => error != null;

  ProfileState copyWith({
    bool? isLoading,
    Profile? profile,
    Object? error = _unset,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: identical(error, _unset)
          ? this.error
          : error as AppException?,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        profile,
        error,
      ];
}