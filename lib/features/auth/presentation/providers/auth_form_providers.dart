import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_form_controller.dart';
import 'auth_form_state.dart';

final authFormControllerProvider =
    NotifierProvider<AuthFormController, AuthFormState>(AuthFormController.new);
