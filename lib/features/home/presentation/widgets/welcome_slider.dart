import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/welcome_slide.dart';

// Yeison Familia - modulo Inicio.
// Slider de bienvenida requerido por la consigna. Avanza solo, tambien se puede
// deslizar con el dedo y muestra puntos de posicion. Cuando el sistema pide
// reducir animaciones el avance automatico se apaga.
class WelcomeSlider extends StatefulWidget {
  const WelcomeSlider({
    super.key,
    required this.slides,
    this.height = 220,
    this.autoPlayInterval = const Duration(seconds: 5),
  });

  final List<WelcomeSlide> slides;
  final double height;
  final Duration autoPlayInterval;

  @override
  State<WelcomeSlider> createState() => _WelcomeSliderState();
}

class _WelcomeSliderState extends State<WelcomeSlider> {
  final PageController _controller = PageController();
  Timer? _autoPlayTimer;
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAutoPlay();
  }

  @override
  void didUpdateWidget(WelcomeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slides.length != widget.slides.length ||
        oldWidget.autoPlayInterval != widget.autoPlayInterval) {
      _syncAutoPlay();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // No tiene sentido animar solo si hay una lamina, y si el usuario configuro
  // el telefono para reducir movimiento hay que respetarlo.
  void _syncAutoPlay() {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    if (reduceMotion || widget.slides.length < 2) {
      _autoPlayTimer?.cancel();
      _autoPlayTimer = null;
      return;
    }

    _restartAutoPlay();
  }

  void _restartAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!mounted || !_controller.hasClients || widget.slides.length < 2) {
        return;
      }

      final nextIndex = (_currentIndex + 1) % widget.slides.length;
      _controller.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);

    // Si la persona desliza a mano, el conteo vuelve a empezar para que la
    // lamina que acaba de elegir no salte de inmediato.
    if (_autoPlayTimer != null) {
      _restartAutoPlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: _onPageChanged,
            itemCount: widget.slides.length,
            itemBuilder: (context, index) {
              return _SlideCard(
                slide: widget.slides[index],
                gradient: _slideGradients[index % _slideGradients.length],
                position: index + 1,
                total: widget.slides.length,
              );
            },
          ),
        ),
        const SizedBox(height: AppDimensions.spacing12),
        _SlideIndicator(
          length: widget.slides.length,
          currentIndex: _currentIndex,
        ),
      ],
    );
  }
}

class _SlideCard extends StatelessWidget {
  const _SlideCard({
    required this.slide,
    required this.gradient,
    required this.position,
    required this.total,
  });

  final WelcomeSlide slide;
  final LinearGradient gradient;
  final int position;
  final int total;

  @override
  Widget build(BuildContext context) {
    final imageAsset = slide.imageAsset;

    return Semantics(
      label: 'Bienvenida $position de $total. ${slide.title}. ${slide.message}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageAsset == null)
                DecoratedBox(decoration: BoxDecoration(gradient: gradient))
              else ...[
                Image.asset(imageAsset, fit: BoxFit.cover),
                // Velo oscuro para que el texto blanco siga siendo legible por
                // encima de cualquier foto.
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.66),
                        Colors.black.withValues(alpha: 0.24),
                      ],
                    ),
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spacing20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      slide.icon,
                      color: AppColors.surface,
                      size: AppDimensions.iconLarge,
                    ),
                    const SizedBox(height: AppDimensions.spacing12),
                    Text(
                      slide.title,
                      style: AppTextStyles.headingMedium.copyWith(
                        color: AppColors.surface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    Text(
                      slide.message,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.surface.withValues(alpha: 0.92),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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
}

class _SlideIndicator extends StatelessWidget {
  const _SlideIndicator({required this.length, required this.currentIndex});

  final int length;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isActive = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing4,
          ),
          height: AppDimensions.spacing8,
          width: isActive ? AppDimensions.spacing24 : AppDimensions.spacing8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(AppDimensions.spacing8),
          ),
        );
      }),
    );
  }
}

// Se definen aqui y no en app/theme porque son propios del slider de Inicio,
// y app/theme/ es archivo compartido que no se toca sin coordinar.
const _slideGradients = <LinearGradient>[
  LinearGradient(
    colors: [AppColors.primary, AppColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [AppColors.secondary, AppColors.accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [AppColors.accent, AppColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [AppColors.primaryDark, AppColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
];
