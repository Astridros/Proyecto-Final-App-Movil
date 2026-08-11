import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../offers/data/providers/offers_data_providers.dart';
import '../../../offers/domain/repositories/offers_repository.dart';
import 'panel_state.dart';

// Cuantas tarjetas se muestran en el carrusel del panel. Ver todo el
// listado es responsabilidad de Explorar ofertas, no de aqui.
const _previewCount = 5;

// Yeison Familia - modulo Inicio.
// No repite la logica de Astrid: solo lee su repositorio ya existente y se
// queda con las primeras tarjetas para armar la vista previa del panel.
// Noticias no tiene vista previa aqui, solo un acceso directo en la barra
// inferior, asi que este controlador no necesita su repositorio.
class PanelController extends Notifier<PanelState> {
  late final OffersRepository _offersRepository;

  @override
  PanelState build() {
    _offersRepository = ref.watch(offersRepositoryProvider);
    return PanelState.initial();
  }

  Future<void> loadPreviews() async {
    state = state.copyWith(isLoadingOffers: true, offersError: false);

    try {
      final offers = await _offersRepository.getOffers();
      state = state.copyWith(
        offers: offers.take(_previewCount).toList(),
        offersError: false,
      );
    } catch (_) {
      state = state.copyWith(offersError: true);
    } finally {
      state = state.copyWith(isLoadingOffers: false);
    }
  }
}
