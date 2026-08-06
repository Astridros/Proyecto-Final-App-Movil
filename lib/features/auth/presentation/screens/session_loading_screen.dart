import 'package:flutter/material.dart';

import '../../../../core/widgets/app_loading.dart';

class SessionLoadingScreen extends StatelessWidget {
  const SessionLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: AppLoading(message: 'Validando sesión...')),
    );
  }
}
