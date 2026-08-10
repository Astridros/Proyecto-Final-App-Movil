import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';

// Yeison Familia - modulo Inicio.
// Menu lateral de la app. Se saco de initial_screen.dart a su propio archivo
// porque es el punto de entrada a los modulos del resto del equipo y asi cada
// quien agrega su entrada sin pelear con el resto de la pantalla.
class MainDrawer extends StatelessWidget {
  const MainDrawer({
    super.key,
    required this.isLoggingOut,
    required this.userName,
    required this.userEmail,
    required this.onHome,
    required this.onMiPerfil,
    required this.onMisPagos,
    required this.onChangePassword,
    required this.onAcercaDe,
    required this.onLogout,
  });

  final bool isLoggingOut;
  final String? userName;
  final String? userEmail;
  final VoidCallback onHome;
  final VoidCallback onMiPerfil;
  final VoidCallback onMisPagos;
  final VoidCallback onChangePassword;
  final VoidCallback onAcercaDe;
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
          onTap: () => _closeAndRun(context, onHome),
        ),
        _DrawerItem(
          icon: Icons.person_outline,
          label: 'Mi perfil',
          onTap: () => _closeAndRun(context, onMiPerfil),
        ),
        _DrawerItem(
          icon: Icons.receipt_long_outlined,
          label: 'Mis pagos',
          onTap: () => _closeAndRun(context, onMisPagos),
        ),
        _DrawerItem(
          icon: Icons.lock_reset_outlined,
          label: 'Cambiar contraseña',
          onTap: () => _closeAndRun(context, onChangePassword),
        ),
        _DrawerItem(
          icon: Icons.info_outline_rounded,
          label: 'Acerca de',
          onTap: () => _closeAndRun(context, onAcercaDe),
        ),
        const Divider(height: AppDimensions.spacing24),
        _DrawerItem(
          icon: Icons.logout,
          label: 'Cerrar sesión',
          foregroundColor: AppColors.error,
          enabled: !isLoggingOut,
          onTap: () => _closeAndRun(context, onLogout),
        ),
      ],
    );
  }

  void _closeAndRun(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop();
    action();
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
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.surface.withValues(alpha: 0.92),
                  child: Text(
                    _initialsFor(name),
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.primaryDark,
                    ),
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

  // Mismo criterio que el avatar de la barra superior: primera letra del
  // nombre y del apellido, para que el circulo se vea igual en toda la app.
  String _initialsFor(String? name) {
    if (name == null || name.isEmpty) {
      return '?';
    }

    final parts = name.split(RegExp(r'\s+'));
    final first = parts.first.characters.first.toUpperCase();
    final second = parts.length > 1
        ? parts.last.characters.first.toUpperCase()
        : '';

    return '$first$second';
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
      title: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: color)),
      onTap: enabled ? onTap : null,
    );
  }
}
