import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../../core/theme/app_colors.dart';
import '../../features/ai_agent/screens/ai_agent_screen.dart';

class FloatingAIButton extends StatelessWidget {
  const FloatingAIButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedColor: AppColors.purpleAccent,
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      closedElevation: 4,
      openColor: AppColors.background,
      transitionDuration: const Duration(milliseconds: 400),
      closedBuilder: (context, openContainer) {
        return SizedBox(
          width: 56,
          height: 56,
          child: FloatingActionButton(
            heroTag: 'ai_fab',
            onPressed: openContainer,
            backgroundColor: AppColors.purpleAccent,
            elevation: 0,
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
            ),
          ),
        );
      },
      openBuilder: (context, _) => const AIAgentScreen(),
    );
  }
}
