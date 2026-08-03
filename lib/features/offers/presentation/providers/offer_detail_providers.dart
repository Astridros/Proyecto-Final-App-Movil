import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'offer_detail_controller.dart';
import 'offer_detail_state.dart';

final offerDetailControllerProvider =
    NotifierProvider.family<OfferDetailController, OfferDetailState, String>(
      OfferDetailController.new,
    );
