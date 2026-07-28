import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_session_providers.dart';
import '../../features/auth/presentation/screens/login_placeholder_screen.dart';
import '../../features/auth/presentation/screens/session_loading_screen.dart';
import '../../features/home/presentation/screens/initial_screen.dart';
import '../../features/offers/presentation/pages/offers_screen.dart';
import '../../features/profile/presentation/pages/complete_profile_screen.dart';
import 'route_names.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _GoRouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: RouteNames.initialPath,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final session = ref.read(authSessionControllerProvider);
      final location = state.uri.path;
      final isLoadingRoute = location == RouteNames.sessionLoadingPath;
      final isCompleteProfileRoute = location == RouteNames.completeProfilePath;

      if (session.isRestoring || !session.hasCheckedSession) {
        return isLoadingRoute ? null : RouteNames.sessionLoadingPath;
      }

      if (!session.isAuthenticated) {
        if (isLoadingRoute || isCompleteProfileRoute) {
          return RouteNames.initialPath;
        }

        return null;
      }

      if (session.requiresProfileCompletion) {
        return isCompleteProfileRoute ? null : RouteNames.completeProfilePath;
      }

      if (isLoadingRoute || isCompleteProfileRoute) {
        return RouteNames.initialPath;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.initialPath,
        name: RouteNames.initial,
        builder: (context, state) => const InitialScreen(),
      ),
      GoRoute(
        path: RouteNames.loginPath,
        name: RouteNames.login,
        builder: (context, state) => const LoginPlaceholderScreen(),
      ),
      GoRoute(
        path: RouteNames.sessionLoadingPath,
        name: RouteNames.sessionLoading,
        builder: (context, state) => const SessionLoadingScreen(),
      ),
      GoRoute(
        path: RouteNames.completeProfilePath,
        name: RouteNames.completeProfile,
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.offersPath,
        name: RouteNames.offers,
        builder: (context, state) => const OffersScreen(),
      ),
    ],
  );
});

class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(Ref ref) {
    _subscription = ref.listen(authSessionControllerProvider, (previous, next) {
      notifyListeners();
    });
  }

  late final ProviderSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
