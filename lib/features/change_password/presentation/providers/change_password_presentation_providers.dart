import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'change_password_controller.dart';
import 'change_password_state.dart';

final changePasswordControllerProvider =
    NotifierProvider<ChangePasswordController, ChangePasswordState>(
      ChangePasswordController.new,
    );
