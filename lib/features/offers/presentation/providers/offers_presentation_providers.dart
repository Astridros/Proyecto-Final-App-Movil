import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'offers_controller.dart';
import 'offers_state.dart';

final offersControllerProvider =
    NotifierProvider<OffersController, OffersState>(OffersController.new);
