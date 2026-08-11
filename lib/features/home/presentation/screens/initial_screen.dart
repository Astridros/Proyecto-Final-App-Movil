import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/providers/auth_session_providers.dart';
import '../../domain/entities/welcome_slide.dart';
import '../widgets/welcome_slider.dart';

// Yeison Familia - modulo Inicio.
// La consigna define Inicio como el slider de bienvenida a la plataforma, asi
// que esta pantalla es solo eso. Los accesos a los demas modulos viven en el
// panel, al que se entra con el boton de abajo.
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

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenHorizontalPadding,
            vertical: AppDimensions.spacing24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Ocupa2',
                textAlign: TextAlign.center,
                style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing4),
              Text(
                'Encuentra tu próxima oportunidad',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing24),
              // El slider ocupa todo el alto disponible: es el contenido del
              // modulo, no un adorno.
              const Expanded(child: WelcomeSlider(slides: _welcomeSlides)),
              const SizedBox(height: AppDimensions.spacing24),
              AppButton(
                label: 'Entrar',
                icon: Icons.arrow_forward_rounded,
                width: double.infinity,
                onPressed: () => context.goNamed(RouteNames.panel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Mensajes de bienvenida del slider. "Bienvenido a Ocupa2" ya no va aqui:
// se movio al banner del Panel. Para usar fotos reales basta con agregar
// imageAsset a la lamina y registrar la carpeta en pubspec.yaml.
const _welcomeSlides = <WelcomeSlide>[
  WelcomeSlide(
    title: 'Encuentra tu próximo trabajo',
    message:
        'Explora ofertas por tipo de empleo o búscalas en el mapa y aplica '
        'a las que van contigo.',
    icon: Icons.travel_explore_outlined,
    imageAsset: 'assets/images/home/slide_encuentra_trabajo.jpg',
  ),
  WelcomeSlide(
    title: 'Publica lo que necesitas',
    message:
        'Crea tu oferta, revisa a los aplicantes, califícalos y elige a tu '
        'ganador.',
    icon: Icons.campaign_outlined,
    imageAsset: 'assets/images/home/slide_publica_oferta.jpg',
  ),
  WelcomeSlide(
    title: 'Haz valer tu experiencia',
    message:
        'Suma tus experiencias y certificados al perfil para destacar entre '
        'los demás aplicantes.',
    icon: Icons.workspace_premium_outlined,
    imageAsset: 'assets/images/home/slide_experiencia.jpg',
  ),
];
