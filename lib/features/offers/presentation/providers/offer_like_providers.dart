import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'offer_like_controller.dart';
import 'offer_like_state.dart';

final offerLikeControllerProvider =
    NotifierProvider.family<OfferLikeController, OfferLikeState, String>(
      OfferLikeController.new,
    );
