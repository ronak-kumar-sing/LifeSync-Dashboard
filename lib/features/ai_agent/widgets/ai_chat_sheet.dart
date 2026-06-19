import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AIChatSheet extends StatelessWidget {
  const AIChatSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.mutedText,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.purpleAccent),
              SizedBox(width: 8),
              Text(
                'AI Assistant',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Tap the AI button in the app bar to chat with your personal assistant. Ask about your data, get insights, and more.',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
