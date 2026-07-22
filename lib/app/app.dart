import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

class Ocupa2App extends StatelessWidget {
  const Ocupa2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ocupa2',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
