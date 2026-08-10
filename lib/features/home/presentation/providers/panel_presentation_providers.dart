import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'panel_controller.dart';
import 'panel_state.dart';

final panelControllerProvider = NotifierProvider<PanelController, PanelState>(
  PanelController.new,
);
