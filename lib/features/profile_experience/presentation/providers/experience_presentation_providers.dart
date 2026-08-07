import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'experience_controller.dart';
import 'experience_state.dart';

final experienceControllerProvider = NotifierProvider<ExperienceController, ExperienceState>(
  ExperienceController.new,
);