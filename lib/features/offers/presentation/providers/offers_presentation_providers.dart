import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/create_offer_controller.dart';
import '../controllers/create_offer_state.dart';
import 'offers_controller.dart';
import 'offers_state.dart';

final offersControllerProvider =
    NotifierProvider<OffersController, OffersState>(OffersController.new);

final createOfferControllerProvider =
    NotifierProvider<CreateOfferController, CreateOfferState>(
      CreateOfferController.new,
    );
