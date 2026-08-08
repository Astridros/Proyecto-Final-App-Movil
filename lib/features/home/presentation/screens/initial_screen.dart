import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_session_providers.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../domain/entities/welcome_slide.dart';
import '../widgets/main_drawer.dart';
import '../widgets/quick_access_card.dart';
import '../widgets/welcome_slider.dart';

// Yeison Familia - modulo Inicio.
// Pantalla de entrada: slider de bienvenida (requisito de la consigna) mas los
// accesos rapidos a los modulos del equipo y el menu lateral de la sesion.
class InitialScreen extends ConsumerWidget {
  const InitialScreen({super.key});

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
            return IconButton(
              tooltip: 'Abrir menú',
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: const Text('Inicio'),
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
              const WelcomeSlider(slides: _welcomeSlides),
              const SizedBox(height: AppDimensions.spacing32),
              Text('Explora la plataforma', style: AppTextStyles.headingSmall),
              const SizedBox(height: AppDimensions.spacing4),
              Text(
                'Entra a las secciones desde aquí.',
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
          style: AppTextStyles.display,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppDimensions.spacing8),
        Text(
          'Encuentra tu próxima oportunidad',
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

class _QuickAccessList extends StatelessWidget {
  const _QuickAccessList();

  @override
  Widget build(BuildContext context) {
    // Se usan los mismos nombres de los modulos de la consigna para que el
    // recorrido de la app coincida con lo que se evalua.
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
          label: 'Noticias',
          description: 'Novedades sobre empleo y oficios',
          icon: Icons.newspaper_outlined,
          color: AppColors.accent,
          onTap: () => context.pushNamed(RouteNames.news),
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
          label: 'Acerca de',
          description: 'Equipo de desarrollo',
          icon: Icons.info_outline_rounded,
          color: AppColors.success,
          onTap: () => context.pushNamed(RouteNames.about),
        ),
      ],
    );
  }
}

// Mensajes de bienvenida del slider. Para usar fotos reales basta con agregar
// imageAsset a la lamina y registrar la carpeta en pubspec.yaml.
const _welcomeSlides = <WelcomeSlide>[
  WelcomeSlide(
    title: 'Bienvenido a Ocupa2',
    message:
        'La plataforma donde se conectan quienes necesitan resolver un '
        'trabajo y quienes saben hacerlo.',
    icon: Icons.handshake_outlined,
  ),
  WelcomeSlide(
    title: 'Encuentra tu próximo trabajo',
    message:
        'Explora ofertas por tipo de empleo o búscalas en el mapa y aplica '
        'a las que van contigo.',
    icon: Icons.travel_explore_outlined,
  ),
  WelcomeSlide(
    title: 'Publica lo que necesitas',
    message:
        'Crea tu oferta, revisa a los aplicantes, califícalos y elige a tu '
        'ganador.',
    icon: Icons.campaign_outlined,
  ),
  WelcomeSlide(
    title: 'Haz valer tu experiencia',
    message:
        'Suma tus experiencias y certificados al perfil para destacar entre '
        'los demás aplicantes.',
    icon: Icons.workspace_premium_outlined,
  ),
];
