import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GlowBorder extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double borderRadius;
  final double borderWidth;
  final double blurRadius;
  final EdgeInsets padding;
  final EdgeInsets margin;

  const GlowBorder({
    super.key,
    required this.child,
    this.glowColor = AppColors.greenAccent,
    this.borderRadius = 20,
    this.borderWidth = 2,
    this.blurRadius = 15,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: glowColor.withOpacity(0.6),
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.3),
            blurRadius: blurRadius,
            spreadRadius: 2,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            glowColor.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: child,
    );
  }
}
