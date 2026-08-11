import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'my_payments_controller.dart';
import 'my_payments_state.dart';

final myPaymentsControllerProvider =
    NotifierProvider<MyPaymentsController, MyPaymentsState>(
      MyPaymentsController.new,
    );
