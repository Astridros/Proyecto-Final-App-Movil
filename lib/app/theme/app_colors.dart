import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const primary = Color(0xFF0F9D8A);
  static const primaryDark = Color(0xFF087A6C);
  static const secondary = Color(0xFF3975E8);
  static const accent = Color(0xFF6857E5);
  static const background = Color(0xFFF6F8FC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSoft = Color(0xFFEEF3F8);
  static const textPrimary = Color(0xFF182234);
  static const textSecondary = Color(0xFF657187);
  static const textDisabled = Color(0xFF9AA5B5);
  static const border = Color(0xFFDCE3EC);
  static const success = Color(0xFF169B62);
  static const warning = Color(0xFFE59A17);
  static const error = Color(0xFFD64545);

  static const primaryGradient = LinearGradient(
    colors: [primary, secondary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
