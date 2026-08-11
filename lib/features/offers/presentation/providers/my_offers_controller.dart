import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../data/providers/offers_data_providers.dart';
import '../../domain/entities/offer.dart';
import '../../domain/repositories/my_offers_repository.dart';
import 'my_offers_state.dart';

class MyOffersController extends Notifier<MyOffersState> {
  late final MyOffersRepository _repository;

  @override
  MyOffersState build() {
    _repository = ref.watch(myOffersRepositoryProvider);
    return MyOffersState.initial();
  }

  Future<void> load() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final offers = await _repository.getMyOffers();

      state = state.copyWith(
        offers: _mergeWithCurrent(offers),
        error: null,
      );
    } catch (error) {
      state = state.copyWith(
        error: ErrorMapper.fromObject(error),
      );
    } finally {
      state = state.copyWith(
        isLoading: false,
      );
    }
  }

  void addCreatedOffer(Offer offer) {
    state = state.copyWith(
      offers: [
        offer,
        ...state.offers.where(
              (item) => item.id != offer.id,
        ),
      ],
      error: null,
    );
  }

  List<Offer> _mergeWithCurrent(
      List<Offer> remoteOffers,
      ) {
    final remoteIds = remoteOffers
        .map((offer) => offer.id)
        .toSet();

    return [
      ...remoteOffers,
      ...state.offers.where(
            (offer) => !remoteIds.contains(offer.id),
      ),
    ];
  }

  Future<bool> deactivate(String offerId) async {
    if (state.deactivatingIds.contains(offerId)) {
      return false;
    }

    state = state.copyWith(
      deactivatingIds: {
        ...state.deactivatingIds,
        offerId,
      },
      error: null,
    );

    try {
      final updated = await _repository.deactivateOffer(
        offerId,
      );

      state = state.copyWith(
        offers: [
          for (final offer in state.offers)
            if (offer.id == updated.id)
              updated
            else
              offer,
        ],
        error: null,
      );

      return true;
    } catch (error) {
      state = state.copyWith(
        error: ErrorMapper.fromObject(error),
      );

      return false;
    } finally {
      state = state.copyWith(
        deactivatingIds: {
          ...state.deactivatingIds,
        }..remove(offerId),
      );
    }
  }
}