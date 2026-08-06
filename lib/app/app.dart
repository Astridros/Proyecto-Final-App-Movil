import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/providers/auth_session_providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class Ocupa2App extends ConsumerStatefulWidget {
  const Ocupa2App({super.key});

  @override
  ConsumerState<Ocupa2App> createState() => _Ocupa2AppState();
}

class _Ocupa2AppState extends ConsumerState<Ocupa2App> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authSessionControllerProvider.notifier).restoreSession(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Ocupa2',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
