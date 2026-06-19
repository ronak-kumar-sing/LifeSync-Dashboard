import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color cardBackground = Color(0xFF121212);
  static const Color elevatedSurface = Color(0xFF2A2A2A);

  // Accents
  static const Color greenAccent = Color(0xFF00C853);
  static const Color blueAccent = Color(0xFF4D9FFF);
  static const Color purpleAccent = Color(0xFF6C5CE7);
  static const Color yellowAccent = Color(0xFFD4FF00);
  static const Color neonYellow = Color(0xFFFFE500);
  static const Color neonGreen = Color(0xFF00E676);
  static const Color neonBlue = Color(0xFF4D9FFF);

  // Text
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFF888888);
  static const Color mutedText = Color(0xFF666666);

  // Status
  static const Color negative = Color(0xFFFF5252);
  static const Color positive = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFFF5252);
  static const Color success = Color(0xFF00E676);

  // Glassmorphism
  static const Color glassOverlay = Color(0x20FFFFFF);
  static const Color glassBorder = Color(0x30FFFFFF);

  // Chart
  static const Color chartGreen = Color(0xFF00C853);
  static const Color chartRed = Color(0xFFFF5252);
  static const Color chartBlue = Color(0xFF4D9FFF);
  static const Color chartYellow = Color(0xFFD4FF00);
  static const Color chartGrid = Color(0x1AFFFFFF);
  static const Color chartTooltip = Color(0xFF2A2A2A);

  // Gradients
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C853), Color(0xFF009624)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1A2E), Color(0xFF0A0A0A)],
  );

  static const LinearGradient purpleGlow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x406C5CE7), Colors.transparent],
  );

  static BoxShadow greenGlow = BoxShadow(
    color: greenAccent.withOpacity(0.3),
    blurRadius: 20,
    spreadRadius: 2,
  );

  static BoxShadow blueGlow = BoxShadow(
    color: blueAccent.withOpacity(0.3),
    blurRadius: 20,
    spreadRadius: 2,
  );

  static BoxShadow purpleGlowShadow = BoxShadow(
    color: purpleAccent.withOpacity(0.3),
    blurRadius: 20,
    spreadRadius: 2,
  );

  static BoxShadow yellowGlow = BoxShadow(
    color: yellowAccent.withOpacity(0.3),
    blurRadius: 20,
    spreadRadius: 2,
  );
}