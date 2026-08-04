import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/ocupa2_logo.dart';
import '../../../auth/presentation/providers/auth_session_providers.dart';

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
      drawer: _MainDrawer(
        isLoggingOut: session.isLoggingOut,
        userName: session.profile?.nombre,
        userEmail: session.profile?.email,
        onHome: () => context.goNamed(RouteNames.initial),
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
              const _BrandHeader(),
              const SizedBox(height: AppDimensions.spacing24),
              const _GradientPanel(),
              const SizedBox(height: AppDimensions.spacing24),
              Text('Base provisional', style: AppTextStyles.headingSmall),
              const SizedBox(height: AppDimensions.spacing12),
              Text(
                'Esta pantalla permite revisar el tema, los componentes '
                'compartidos y la navegación inicial del proyecto.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing24),
              AppButton.outlined(
                label: 'Explorar ofertas',
                icon: Icons.work_outline_rounded,
                onPressed: () => context.pushNamed(RouteNames.offers),
                width: double.infinity,
              ),
              const SizedBox(height: AppDimensions.spacing12),
              // Angel Daniel Genao 2024-1169: accesos a Noticias y Videos.
              AppButton.outlined(
                label: 'Ver noticias',
                icon: Icons.newspaper_outlined,
                onPressed: () => context.pushNamed(RouteNames.news),
                width: double.infinity,
              ),
              const SizedBox(height: AppDimensions.spacing12),
              AppButton.outlined(
                label: 'Ver videos',
                icon: Icons.smart_display_outlined,
                onPressed: () => context.pushNamed(RouteNames.videos),
                width: double.infinity,
              ),
              const SizedBox(height: AppDimensions.spacing24),
              const AppCard(
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.secondary,
                      size: AppDimensions.iconMedium,
                    ),
                    SizedBox(width: AppDimensions.spacing12),
                    Expanded(
                      child: Text(
                        'No se están consumiendo endpoints en esta etapa.',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
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

class _MainDrawer extends StatelessWidget {
  const _MainDrawer({
    required this.isLoggingOut,
    required this.userName,
    required this.userEmail,
    required this.onHome,
    required this.onChangePassword,
    required this.onLogout,
  });

  final bool isLoggingOut;
  final String? userName;
  final String? userEmail;
  final VoidCallback onHome;
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      children: [
        _DrawerHeader(userName: userName, userEmail: userEmail),
        const Divider(height: 1),
        _DrawerItem(
          icon: Icons.home_outlined,
          label: 'Inicio',
          onTap: () {
            Navigator.of(context).pop();
            onHome();
          },
        ),
        _DrawerItem(
          icon: Icons.lock_reset_outlined,
          label: 'Cambiar contraseña',
          onTap: () {
            Navigator.of(context).pop();
            onChangePassword();
          },
        ),
        const Divider(height: AppDimensions.spacing24),
        _DrawerItem(
          icon: Icons.logout,
          label: 'Cerrar sesión',
          foregroundColor: AppColors.error,
          enabled: !isLoggingOut,
          onTap: () {
            Navigator.of(context).pop();
            onLogout();
          },
        ),
      ],
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.userName, required this.userEmail});

  final String? userName;
  final String? userEmail;

  @override
  Widget build(BuildContext context) {
    final name = _cleanText(userName);
    final email = _cleanText(userEmail);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(AppDimensions.spacing12),
                    child: Ocupa2Logo(),
                  ),
                ),
                if (name != null || email != null) ...[
                  const SizedBox(height: AppDimensions.spacing16),
                  if (name != null)
                    Text(
                      name,
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.surface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (email != null) ...[
                    const SizedBox(height: AppDimensions.spacing4),
                    Text(
                      email,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.surface.withValues(alpha: 0.86),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _cleanText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.foregroundColor,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? foregroundColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? foregroundColor : AppColors.textDisabled;

    return ListTile(
      enabled: enabled,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(color: color),
      ),
      onTap: enabled ? onTap : null,
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ocupa2', style: AppTextStyles.display),
        const SizedBox(height: AppDimensions.spacing8),
        Text(
          'Trabajos temporales organizados en una experiencia móvil limpia '
          'y consistente para el equipo.',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _GradientPanel extends StatelessWidget {
  const _GradientPanel();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Panel visual provisional de Ocupa2',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing20,
          vertical: AppDimensions.spacing16,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.handshake_outlined,
              color: AppColors.surface,
              size: AppDimensions.iconLarge,
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              'Arquitectura lista para crecer',
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.surface,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              'Features separadas, tema compartido y rutas centralizadas.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.surface.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
