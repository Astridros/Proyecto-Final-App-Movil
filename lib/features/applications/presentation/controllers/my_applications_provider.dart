import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'my_applications_controller.dart';
import 'my_applications_state.dart';

final myApplicationsControllerProvider =
NotifierProvider<
    MyApplicationsController,
    MyApplicationsState>(
  MyApplicationsController.new,
);