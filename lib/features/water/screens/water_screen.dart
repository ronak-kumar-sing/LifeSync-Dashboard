import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/shared/empty_state.dart';
import '../widgets/water_card.dart';
import '../providers/water_provider.dart';

class WaterScreen extends StatelessWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Water Intake'),
            backgroundColor: AppColors.background,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppColors.primaryText),
                onPressed: () => _showSettings(context, provider),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const WaterCard(),
                const SizedBox(height: 16),
                _buildHistory(provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistory(WaterProvider provider) {
    if (provider.entries.isEmpty) {
      return const EmptyState(
        icon: Icons.water_drop_outlined,
        title: 'No Water Logged',
        message: 'Start tracking your hydration by adding water intake.',
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Logs',
            style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.entries.length.clamp(0, 10),
            itemBuilder: (context, index) {
              final entry = provider.entries[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.blueAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.water_drop, color: AppColors.blueAccent, size: 18),
                ),
                title: Text(
                  '${entry.amount.toStringAsFixed(2)} L',
                  style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${entry.date.day}/${entry.date.month}/${entry.date.year} ${entry.date.hour}:${entry.date.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context, WaterProvider provider) {
    final controller = TextEditingController(text: provider.dailyGoal.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Water Goal', style: TextStyle(color: AppColors.primaryText)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.primaryText),
          decoration: const InputDecoration(
            labelText: 'Daily Goal (Liters)',
            suffixText: 'L',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final goal = double.tryParse(controller.text);
              if (goal != null && goal > 0) {
                provider.setGoal(goal);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
