import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_placeholder_screen.dart';
import '../../features/home/presentation/screens/initial_screen.dart';
import '../../features/offers/presentation/screens/offers_placeholder_screen.dart';
import '../../features/profile/presentation/screens/complete_profile_placeholder_screen.dart';
import 'route_names.dart';

GoRouter get appRouter => GoRouter(
  initialLocation: RouteNames.initialPath,
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
      path: RouteNames.completeProfilePath,
      name: RouteNames.completeProfile,
      builder: (context, state) => const CompleteProfilePlaceholderScreen(),
    ),
    GoRoute(
      path: RouteNames.offersPath,
      name: RouteNames.offers,
      builder: (context, state) => const OffersPlaceholderScreen(),
    ),
  ],
);
