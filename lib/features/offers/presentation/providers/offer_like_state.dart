import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_exception.dart';

const _unset = Object();

class OfferLikeState extends Equatable {
  const OfferLikeState({
    required this.isSubmitting,
    required this.liked,
    required this.likesCount,
    required this.hasLocalInteraction,
    required this.error,
  });

  factory OfferLikeState.initial() {
    return const OfferLikeState(
      isSubmitting: false,
      liked: false,
      likesCount: 0,
      hasLocalInteraction: false,
      error: null,
    );
  }

  final bool isSubmitting;
  final bool liked;
  final int likesCount;
  final bool hasLocalInteraction;
  final AppException? error;

  OfferLikeState copyWith({
    bool? isSubmitting,
    bool? liked,
    int? likesCount,
    bool? hasLocalInteraction,
    Object? error = _unset,
  }) {
    return OfferLikeState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      liked: liked ?? this.liked,
      likesCount: (likesCount ?? this.likesCount).clamp(0, 1 << 31),
      hasLocalInteraction: hasLocalInteraction ?? this.hasLocalInteraction,
      error: identical(error, _unset) ? this.error : error as AppException?,
    );
  }

  @override
  List<Object?> get props => [
    isSubmitting,
    liked,
    likesCount,
    hasLocalInteraction,
    error,
  ];
}
