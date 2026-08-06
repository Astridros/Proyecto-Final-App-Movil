import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../data/providers/offers_data_providers.dart';
import '../../domain/repositories/offers_repository.dart';
import 'offer_like_state.dart';

class OfferLikeController extends Notifier<OfferLikeState> {
  OfferLikeController(this._offerId);

  late OffersRepository _repository;
  final String _offerId;

  @override
  OfferLikeState build() {
    _repository = ref.watch(offersRepositoryProvider);
    return OfferLikeState.initial();
  }

  Future<bool> toggleLike() async {
    if (state.isSubmitting) {
      return false;
    }

    final previous = state;
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final result = previous.liked
          ? await _repository.unlikeOffer(_offerId)
          : await _repository.likeOffer(_offerId);

      state = state.copyWith(
        isSubmitting: false,
        liked: result.liked,
        likesCount: result.likesCount,
        hasLocalInteraction: true,
        error: null,
      );
      return true;
    } catch (error) {
      state = previous.copyWith(
        isSubmitting: false,
        error: _toAppException(error),
      );
      return false;
    }
  }

  void syncFromOffer({required bool likedByMe, required int likesCount}) {
    if (state.hasLocalInteraction || state.isSubmitting) {
      return;
    }

    final safeLikesCount = likesCount.clamp(0, 1 << 31);
    if (state.liked == likedByMe && state.likesCount == safeLikesCount) {
      return;
    }

    state = state.copyWith(
      liked: likedByMe,
      likesCount: safeLikesCount,
      error: null,
    );
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
