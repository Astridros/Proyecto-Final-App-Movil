import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'offer_applications_controller.dart';
import 'offer_applications_state.dart';

final offerApplicationsControllerProvider =
NotifierProvider.family<
    OfferApplicationsController,
    OfferApplicationsState,
    String>(
  OfferApplicationsController.new,
);