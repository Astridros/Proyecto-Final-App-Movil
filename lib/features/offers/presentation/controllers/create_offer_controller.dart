import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../data/providers/offers_data_providers.dart';
import '../../domain/entities/create_offer_request.dart';
import '../../domain/repositories/offers_repository.dart';
import 'create_offer_state.dart';

class CreateOfferController extends Notifier<CreateOfferState> {
  late final OffersRepository _repository;

  @override
  CreateOfferState build() {
    _repository = ref.watch(offersRepositoryProvider);
    return CreateOfferState.initial();
  }

  Future<bool> createOffer(CreateOfferRequest request) async {
    if (state.isSubmitting) {
      return false;
    }

    final validationError = _validate(request);
    if (validationError != null) {
      state = state.copyWith(error: ApiException(message: validationError));
      return false;
    }

    state = state.copyWith(isSubmitting: true, error: null, createdOffer: null);
    try {
      final offer = await _repository.createOffer(request);
      state = state.copyWith(createdOffer: offer);
      return true;
    } catch (error) {
      state = state.copyWith(error: ErrorMapper.fromObject(error));
      return false;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  String? _validate(CreateOfferRequest request) {
    if (request.jobTypeKey.trim().isEmpty) {
      return 'El tipo de trabajo es obligatorio.';
    }
    if (request.contractType.trim().isEmpty) {
      return 'El tipo de contrato es obligatorio.';
    }
    if (request.description.trim().isEmpty) {
      return 'La descripción es obligatoria.';
    }
    if (request.address.trim().isEmpty) {
      return 'La dirección es obligatoria.';
    }
    if (request.amount <= 0) {
      return 'El monto debe ser mayor que cero.';
    }
    if (request.currency.trim().isEmpty) {
      return 'La moneda es obligatoria.';
    }
    if (request.paymentId.trim().isEmpty) {
      return 'Debes completar el pago antes de publicar la oferta.';
    }
    if (request.latitude < -90 || request.latitude > 90) {
      return 'La latitud debe estar entre -90 y 90.';
    }
    if (request.longitude < -180 || request.longitude > 180) {
      return 'La longitud debe estar entre -180 y 180.';
    }
    return null;
  }
}
