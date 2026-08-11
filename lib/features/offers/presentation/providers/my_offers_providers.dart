import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'my_offers_controller.dart';
import 'my_offers_state.dart';

final myOffersControllerProvider =
NotifierProvider<
    MyOffersController,
    MyOffersState>(
  MyOffersController.new,
);