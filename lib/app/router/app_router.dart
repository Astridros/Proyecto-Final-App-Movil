import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/offers/presentation/pages/my_offers_screen.dart';
import 'package:ocupa2/features/profile_experience/presentation/screens/add_experience_screen.dart';
import 'package:ocupa2/features/profile_experience/presentation/screens/experience_screen.dart';
import 'package:ocupa2/features/profile_experience/presentation/screens/profile_screen.dart';
import 'package:ocupa2/payments/presentation/screens/payment_screen.dart';
import '../../features/about/presentation/screens/about_screen.dart';
import '../../features/auth/presentation/providers/auth_session_providers.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/auth/presentation/screens/session_loading_screen.dart';
import '../../features/change_password/presentation/pages/change_password_screen.dart';
import '../../features/home/presentation/screens/initial_screen.dart';
import '../../features/news/domain/entities/news_item.dart';
import '../../features/news/presentation/pages/news_detail_screen.dart';
import '../../features/news/presentation/pages/news_screen.dart';
import '../../features/offers/presentation/pages/offer_detail_screen.dart';
import '../../features/offers/presentation/screens/create_offer_screen.dart';
import '../../features/offers/presentation/screens/my_offers_screen.dart';
import '../../features/offers/presentation/pages/offers_screen.dart';
import '../../features/profile/presentation/pages/complete_profile_screen.dart';
import '../../features/videos/domain/entities/video.dart';
import '../../features/videos/presentation/pages/video_detail_screen.dart';
import '../../features/videos/presentation/pages/videos_screen.dart';
import 'route_names.dart';
import '../../features/offer_map/presentation/screens/offers_map_screen.dart';
import '../../features/profile_experience/presentation/screens/edit_profile_screen.dart';
import '../../features/profile_experience/domain/entities/profile.dart';
import '../../features/applications/presentation/pages/my_applications_screen.dart';
import '../../features/applications/presentation/pages/offer_applications_screen.dart';
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
      final isPublicAuthRoute = _publicAuthPaths.contains(location);

      if (session.isRestoring || !session.hasCheckedSession) {
        return isLoadingRoute ? null : RouteNames.sessionLoadingPath;
      }

      if (!session.isAuthenticated) {
        if (isPublicAuthRoute) {
          return null;
        }

        return RouteNames.loginPath;
      }

      if (session.requiresProfileCompletion) {
        return isCompleteProfileRoute ? null : RouteNames.completeProfilePath;
      }

      if (isLoadingRoute || isCompleteProfileRoute || isPublicAuthRoute) {
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
        builder: (context, state) => LoginScreen(
          onRegister: () => context.pushNamed(RouteNames.register),
          onForgotPassword: () => context.pushNamed(RouteNames.forgotPassword),
        ),
      ),
      GoRoute(
        path: RouteNames.registerPath,
        name: RouteNames.register,
        builder: (context, state) => RegisterScreen(
          onBackToLogin: () {
            if (context.canPop()) {
              context.pop();
              return;
            }

            context.goNamed(RouteNames.login);
          },
        ),
      ),
      GoRoute(
        path: RouteNames.forgotPasswordPath,
        name: RouteNames.forgotPassword,
        builder: (context, state) => ForgotPasswordScreen(
          onBackToLogin: () {
            if (context.canPop()) {
              context.pop();
              return;
            }

            context.goNamed(RouteNames.login);
          },
        ),
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
      GoRoute(
        path: RouteNames.myOffersPath,
        name: RouteNames.myOffers,
        builder: (context, state) =>
        const MyOffersScreen(),
      ),
      GoRoute(
        path:
        RouteNames.offerApplicationsPath,
        name:
        RouteNames.offerApplications,
        builder: (
            context,
            state,
            ) {
          final offerId =
              state.pathParameters['id'] ??
                  '';

          return OfferApplicationsScreen(
            offerId: offerId,
          );
        },
      ),

      GoRoute(
        path: RouteNames.myApplicationsPath,
        name: RouteNames.myApplications,
        builder: (context, state) =>
        const MyApplicationsScreen(),
      ),
      GoRoute(
        path: RouteNames.offersMapPath,
        name: RouteNames.offersMap,
        builder: (context, state) => const OffersMapScreen(),
      ),
      GoRoute(
        path: RouteNames.aboutPath,
        name: RouteNames.about,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: RouteNames.offerDetailPath,
        name: RouteNames.offerDetail,
        builder: (context, state) {
          final offerId = state.pathParameters['id'] ?? '';
          return OfferDetailScreen(offerId: offerId);
        },
      ),
      GoRoute(
        path: RouteNames.changePasswordPath,
        name: RouteNames.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),

      // Angel Daniel Genao 2024-1169: rutas de Noticias y Videos.
      // La lista (news/videos) no recibe parámetros; el detalle recibe
      // el objeto completo (NewsItem o Video) por "extra" porque la API
      // no tiene un endpoint de detalle por id para estos dos recursos.
      GoRoute(
        path: RouteNames.newsPath,
        name: RouteNames.news,
        builder: (context, state) => const NewsScreen(),
      ),
      GoRoute(
        path: RouteNames.newsDetailPath,
        name: RouteNames.newsDetail,
        builder: (context, state) =>
            NewsDetailScreen(newsItem: state.extra as NewsItem),
      ),
      GoRoute(
        path: RouteNames.videosPath,
        name: RouteNames.videos,
        builder: (context, state) => const VideosScreen(),
      ),
      GoRoute(
        path: RouteNames.videoDetailPath,
        name: RouteNames.videoDetail,
        builder: (context, state) =>
            VideoDetailScreen(video: state.extra as Video),
      ),

      GoRoute(
        name: RouteNames.experiences,
        path: RouteNames.experiencesPath,
        builder: (context, state) => const ExperienceScreen(),
      ),
      GoRoute(
        name: RouteNames.addExperience,
        path: RouteNames.addExperiencePath,
        builder: (context, state) => const AddExperienceScreen(),
      ),
      GoRoute(
        path: RouteNames.profilePath,
        name: RouteNames.profile,
        builder: (_, _) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.editProfilePath,
        name: RouteNames.editProfile,
        builder: (context, state) {
          final profile = state.extra as Profile;

          return EditProfileScreen(profile: profile);
        },
      ),
      GoRoute(
        name: RouteNames.payment,
        path: '/payment',
        builder: (context, state) {
          return const PaymentScreen();
        },
      ),
      // La pantalla de publicar oferta existia sin ruta registrada, asi que no
      // se podia alcanzar desde ningun lado. Se registra para engancharla al
      // Inicio.
      GoRoute(
        name: RouteNames.publishOffer,
        path: RouteNames.publishOfferPath,
        builder: (context, state) => const CreateOfferScreen(),
      ),
      GoRoute(
        name: RouteNames.myOffers,
        path: RouteNames.myOffersPath,
        builder: (context, state) => const MyOffersScreen(),
      ),
    ],
  );
});

const _publicAuthPaths = {
  RouteNames.loginPath,
  RouteNames.registerPath,
  RouteNames.forgotPasswordPath,
};

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
