import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile_controller.dart';
import 'profile_state.dart';

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(
  ProfileController.new,
);