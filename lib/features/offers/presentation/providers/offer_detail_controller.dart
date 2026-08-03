import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../applications/data/providers/applications_data_providers.dart';
import '../../../applications/domain/repositories/applications_repository.dart';
import '../../data/providers/offers_data_providers.dart';
import '../../domain/entities/apply_offer_answer.dart';
import '../../domain/repositories/offers_repository.dart';
import 'offer_detail_state.dart';

class OfferDetailController extends Notifier<OfferDetailState> {
  OfferDetailController(this._offerId);

  late final OffersRepository _repository;
  late final ApplicationsRepository _applicationsRepository;
  final String _offerId;

  @override
  OfferDetailState build() {
    _repository = ref.watch(offersRepositoryProvider);
    _applicationsRepository = ref.watch(applicationsRepositoryProvider);
    return OfferDetailState.initial();
  }

  Future<void> loadOffer([String? offerId]) async {
    if (state.isInitialLoading) {
      return;
    }

    final targetOfferId = offerId ?? _offerId;
    state = state.copyWith(isInitialLoading: true, error: null);

    try {
      final offer = await _repository.getOfferById(targetOfferId);
      state = state.copyWith(offer: offer, error: null);

      try {
        final applications = await _applicationsRepository.getMyApplications();
        final existingApplication = applications
            .where((application) => application.offerId == targetOfferId)
            .firstOrNull;

        state = state.copyWith(
          hasAlreadyApplied: existingApplication != null,
          existingApplication: existingApplication,
          applicationResult: existingApplication == null
              ? null
              : state.applicationResult,
          successMessage: existingApplication == null
              ? null
              : state.successMessage,
          error: null,
        );
      } catch (error) {
        state = state.copyWith(error: _toAppException(error));
      }
    } catch (error) {
      state = state.copyWith(error: _toAppException(error));
    } finally {
      state = state.copyWith(isInitialLoading: false);
    }
  }

  Future<bool> apply({
    required String comment,
    required List<ApplyOfferAnswer> answers,
  }) async {
    final offer = state.offer;
    if (offer == null) {
      state = state.copyWith(
        error: const ApiException(message: 'No hay una oferta cargada.'),
      );
      return false;
    }

    if (state.isSubmitting) {
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      error: null,
      successMessage: null,
    );

    try {
      final result = await _repository.applyToOffer(
        offerId: offer.id,
        comment: comment,
        answers: answers,
      );
      state = state.copyWith(
        applicationResult: result,
        error: null,
        successMessage: 'Aplicación enviada correctamente.',
      );
      return true;
    } catch (error) {
      final mappedError = _toAppException(error);
      state = state.copyWith(
        error: mappedError,
        hasAlreadyApplied: _isAlreadyAppliedError(mappedError)
            ? true
            : state.hasAlreadyApplied,
      );
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

  bool _isAlreadyAppliedError(AppException error) {
    return error.message.trim() == 'Ya aplicaste a esta oferta.';
  }
}
