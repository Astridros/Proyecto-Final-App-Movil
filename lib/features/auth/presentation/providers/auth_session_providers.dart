import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_session_controller.dart';
import 'auth_session_state.dart';

final authSessionControllerProvider =
    NotifierProvider<AuthSessionController, AuthSessionState>(
      AuthSessionController.new,
    );
