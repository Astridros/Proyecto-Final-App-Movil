import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_session_providers.dart';
import '../../../profile/domain/entities/profile.dart';
import '../widgets/main_drawer.dart';
import '../widgets/panel_promo_banner.dart';
import '../widgets/quick_access_card.dart';

// Yeison Familia - modulo Inicio.
// Panel principal: a donde se llega tras el slider de Inicio. Saludo, banner
// de bienvenida y accesos al resto de modulos.
class PanelScreen extends ConsumerWidget {
  const PanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authSessionControllerProvider, (previous, next) {
      final message = next.error?.message;
      if (message == null || previous?.error == next.error) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    });

    final session = ref.watch(authSessionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return _AvatarMenuButton(
              profile: session.profile,
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: _SearchBar(
          // Las ofertas solo se filtran por tipo de empleo y contrato, no hay
          // busqueda por texto en el API. En vez de simular una que no existe,
          // esto lleva a Explorar ofertas, donde si hay filtros reales.
          onTap: () => context.pushNamed(RouteNames.offers),
        ),
      ),
      drawer: MainDrawer(
        isLoggingOut: session.isLoggingOut,
        userName: session.profile?.nombre,
        userEmail: session.profile?.email,
        onHome: () => context.goNamed(RouteNames.initial),
        onMiPerfil: () => context.goNamed(RouteNames.profile),
        onChangePassword: () {
          final path = GoRouterState.of(context).uri.path;
          if (path != RouteNames.changePasswordPath) {
            context.pushNamed(RouteNames.changePassword);
          }
        },
        onLogout: () => _confirmLogout(context, ref),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenHorizontalPadding,
            vertical: AppDimensions.spacing24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Greeting(profile: session.profile),
              const SizedBox(height: AppDimensions.spacing20),
              PanelPromoBanner(
                onExploreOffers: () => context.pushNamed(RouteNames.offers),
              ),
              const SizedBox(height: AppDimensions.spacing32),
              Text('Más secciones', style: AppTextStyles.headingSmall),
              const SizedBox(height: AppDimensions.spacing4),
              Text(
                'El resto de la plataforma, a un toque.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing16),
              const _QuickAccessList(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await ref.read(authSessionControllerProvider.notifier).logout();
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.profile});

  final Profile? profile;

  @override
  Widget build(BuildContext context) {
    final name = _firstName(profile);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ocupa2',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.primary,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: AppDimensions.spacing4),
        Text(
          name == null ? 'Hola' : 'Hola, $name',
          style: AppTextStyles.headingLarge,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppDimensions.spacing8),
        Text(
          'Trabajos temporales y oportunidades cerca de ti.',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // El API devuelve el nombre en firstName o en nombre segun el endpoint, y
  // ambos pueden venir vacios antes de completar el perfil.
  String? _firstName(Profile? profile) {
    if (profile == null) {
      return null;
    }

    for (final candidate in [profile.firstName, profile.nombre]) {
      final trimmed = candidate?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed.split(' ').first;
      }
    }

    return null;
  }
}

// Yeison Familia - modulo Inicio.
// Accesos al resto de los modulos, dentro del scroll del Panel: con varios
// modulos una barra fija de iconos quedaba apretada, asi que se ven como
// tarjetas (icono, titulo y descripcion) bajando con el dedo.
class _QuickAccessList extends StatelessWidget {
  const _QuickAccessList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuickAccessCard(
          label: 'Explorar ofertas',
          description: 'Trabajos disponibles y filtros por tipo de empleo',
          icon: Icons.work_outline_rounded,
          color: AppColors.primary,
          onTap: () => context.pushNamed(RouteNames.offers),
        ),
        const SizedBox(height: AppDimensions.spacing12),
        QuickAccessCard(
          label: 'Mapa de ofertas',
          description: 'Mira las ofertas ubicadas en el mapa',
          icon: Icons.map_outlined,
          color: AppColors.secondary,
          onTap: () => context.pushNamed(RouteNames.offersMap),
        ),
        const SizedBox(height: AppDimensions.spacing12),
        QuickAccessCard(
          label: 'Publicar oferta',
          description: 'Publica un trabajo y recibe aplicantes',
          icon: Icons.campaign_outlined,
          color: AppColors.primaryDark,
          onTap: () => context.pushNamed(RouteNames.publishOffer),
        ),
        const SizedBox(height: AppDimensions.spacing12),
        QuickAccessCard(
          label: 'Mis ofertas publicadas',
          description: 'Revisa y administra lo que has publicado',
          icon: Icons.storefront_outlined,
          color: AppColors.accent,
          onTap: () => context.pushNamed(RouteNames.myOffers),
        ),
        const SizedBox(height: AppDimensions.spacing12),
        QuickAccessCard(
          label: 'Mis aplicaciones',
          description: 'Sigue el estado de las ofertas a las que aplicaste',
          icon: Icons.assignment_outlined,
          color: AppColors.primaryDark,
          onTap: () => context.pushNamed(RouteNames.myApplications),
        ),
        const SizedBox(height: AppDimensions.spacing12),
        QuickAccessCard(
          label: 'Mis pagos',
          description: 'Historial de tus pagos en la plataforma',
          icon: Icons.receipt_long_outlined,
          color: AppColors.success,
          onTap: () => context.pushNamed(RouteNames.myPayments),
        ),
        const SizedBox(height: AppDimensions.spacing12),
        QuickAccessCard(
          label: 'Acerca de',
          description: 'Conoce más sobre Ocupa2 y el equipo',
          icon: Icons.info_outline_rounded,
          color: AppColors.secondary,
          onTap: () => context.pushNamed(RouteNames.about),
        ),
        const SizedBox(height: AppDimensions.spacing12),
        QuickAccessCard(
          label: 'Videos',
          description: 'Tutoriales y capacitación',
          icon: Icons.smart_display_outlined,
          color: AppColors.warning,
          onTap: () => context.pushNamed(RouteNames.videos),
        ),
        const SizedBox(height: AppDimensions.spacing12),
        QuickAccessCard(
          label: 'Noticias',
          description: 'Novedades sobre empleo y oficios',
          icon: Icons.newspaper_outlined,
          color: AppColors.success,
          onTap: () => context.pushNamed(RouteNames.news),
        ),
      ],
    );
  }
}

// Yeison Familia - modulo Inicio.
// Circulo con las iniciales del usuario, en el lugar del icono de menu. El
// perfil no trae foto en el API, asi que se usan iniciales en vez de un
// avatar vacio.
class _AvatarMenuButton extends StatelessWidget {
  const _AvatarMenuButton({required this.profile, required this.onPressed});

  final Profile? profile;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacing8),
      child: Tooltip(
        message: 'Abrir menú',
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(
              _initials,
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.surface),
            ),
          ),
        ),
      ),
    );
  }

  String get _initials {
    final name = [
      profile?.firstName,
      profile?.nombre,
    ].firstWhere((value) => value?.trim().isNotEmpty ?? false, orElse: () => null);

    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return '?';
    }

    final parts = trimmed.split(RegExp(r'\s+'));
    final first = parts.first.characters.first.toUpperCase();
    final second = parts.length > 1
        ? parts.last.characters.first.toUpperCase()
        : '';

    return '$first$second';
  }
}

// Yeison Familia - modulo Inicio.
// Barra con forma de buscador que en realidad es un acceso directo a
// Explorar ofertas, que es donde viven los filtros reales.
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceSoft,
      borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing16,
            vertical: AppDimensions.spacing12,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                size: AppDimensions.iconSmall,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppDimensions.spacing8),
              Text(
                'Buscar ofertas',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
