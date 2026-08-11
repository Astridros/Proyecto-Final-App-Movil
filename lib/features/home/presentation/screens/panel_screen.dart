import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_session_providers.dart';
import '../../../profile/domain/entities/profile.dart';
import '../providers/panel_presentation_providers.dart';
import '../providers/panel_state.dart';
import '../widgets/main_drawer.dart';
import '../widgets/offer_preview_card.dart';
import '../widgets/panel_promo_banner.dart';

// Yeison Familia - modulo Inicio.
// Panel principal: a donde se llega tras el slider de Inicio. Saludo, banner
// de bienvenida, vista previa de ofertas y noticias (leyendo los repositorios
// de Astrid y Angel, sin repetir su logica), y accesos al resto de modulos.
class PanelScreen extends ConsumerStatefulWidget {
  const PanelScreen({super.key});

  @override
  ConsumerState<PanelScreen> createState() => _PanelScreenState();
}

class _PanelScreenState extends ConsumerState<PanelScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(panelControllerProvider.notifier).loadPreviews();
    });
  }

  @override
  Widget build(BuildContext context) {
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
    final panel = ref.watch(panelControllerProvider);

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
        onMyApplications: () => context.pushNamed(
          RouteNames.myApplications,
        ),
        onHome: () => context.goNamed(RouteNames.initial),
        onMiPerfil: () => context.goNamed(RouteNames.profile),
        onMisPagos: () => context.pushNamed(RouteNames.myPayments),
        onMyOffers: () => context.pushNamed(RouteNames.myOffers),
        onChangePassword: () {
          final path = GoRouterState.of(context).uri.path;
          if (path != RouteNames.changePasswordPath) {
            context.pushNamed(RouteNames.changePassword);
          }
        },
        onAcercaDe: () => context.pushNamed(RouteNames.about),
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
              Text('Ofertas recomendadas', style: AppTextStyles.headingSmall),
              const SizedBox(height: AppDimensions.spacing16),
              _OffersSection(panel: panel),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _QuickAccessBottomBar(),
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
// Lista vertical, sin carrusel ni "Ver todas": todo el contenido del panel
// se ve bajando con el dedo. Para explorar el listado completo esta el
// buscador de arriba y el acceso "Explorar ofertas" de la barra inferior.
class _OffersSection extends StatelessWidget {
  const _OffersSection({required this.panel});

  final PanelState panel;

  @override
  Widget build(BuildContext context) {
    if (panel.isLoadingOffers && panel.offers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.spacing24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Un fallo aqui no debe tumbar el resto del panel: el acceso completo a
    // ofertas sigue disponible desde el buscador y la barra inferior.
    if (panel.offersError && panel.offers.isEmpty) {
      return const SizedBox.shrink();
    }

    if (panel.offers.isEmpty) {
      return Text(
        'Todavía no hay ofertas activas.',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }

    return Column(
      children: [
        for (final offer in panel.offers) ...[
          OfferPreviewCard(
            offer: offer,
            onTap: () => context.pushNamed(
              RouteNames.offerDetail,
              pathParameters: {'id': offer.id},
            ),
          ),
          if (offer != panel.offers.last)
            const SizedBox(height: AppDimensions.spacing12),
        ],
      ],
    );
  }
}

// Yeison Familia - modulo Inicio.
// Barra fija con los accesos al resto de los modulos. Solo vive en el Panel,
// no envuelve el resto de la app: cada boton navega hacia una pantalla
// separada, no cambia una pestana dentro de esta misma pantalla, asi que no
// se marca ningun boton como "seleccionado".
class _QuickAccessBottomBar extends StatelessWidget {
  const _QuickAccessBottomBar();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing4,
            vertical: AppDimensions.spacing8,
          ),
          child: Row(
            children: [
              _BottomBarItem(
                label: 'Noticias',
                icon: Icons.newspaper_outlined,
                onTap: () => context.pushNamed(RouteNames.news),
              ),
              _BottomBarItem(
                label: 'Mapa',
                icon: Icons.map_outlined,
                onTap: () => context.pushNamed(RouteNames.offersMap),
              ),
              _BottomBarItem(
                label: 'Publicar',
                icon: Icons.campaign_outlined,
                onTap: () => context.pushNamed(RouteNames.publishOffer),
              ),
              _BottomBarItem(
                label: 'Videos',
                icon: Icons.smart_display_outlined,
                onTap: () => context.pushNamed(RouteNames.videos),
              ),
              _BottomBarItem(
                label: 'Explorar ofertas',
                icon: Icons.work_outline_rounded,
                onTap: () => context.pushNamed(RouteNames.offers),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacing4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textSecondary, size: AppDimensions.iconMedium),
              const SizedBox(height: AppDimensions.spacing4),
              Text(
                label,
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
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
