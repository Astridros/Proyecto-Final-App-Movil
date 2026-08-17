import 'package:flutter/widgets.dart';

// Yeison Familia - modulo Inicio.
// Lamina del slider de bienvenida. [imageAsset] es opcional: cuando viene nulo
// la lamina se dibuja con el degradado de la marca, asi el modulo no depende de
// imagenes que todavia no estan en assets/.
class WelcomeSlide {
  const WelcomeSlide({
    required this.title,
    required this.message,
    required this.icon,
    this.imageAsset,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? imageAsset;
}
