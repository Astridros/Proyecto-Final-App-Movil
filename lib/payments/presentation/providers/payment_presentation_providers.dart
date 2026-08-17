import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/payment_controller.dart';
import '../controllers/payment_state.dart';

final paymentControllerProvider =
    NotifierProvider<PaymentController, PaymentState>(
  PaymentController.new,
);