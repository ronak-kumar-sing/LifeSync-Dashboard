import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../features/income/screens/income_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/water/screens/water_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import 'floating_ai_button.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        final crossAxisCount = isDesktop ? 2 : 1;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('LifeSync Dashboard'),
            backgroundColor: AppColors.background,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: isDesktop ? 1.1 : 0.9,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const IncomeScreen()),
                      ),
                      child: const IncomeCard(),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WaterScreen()),
                      ),
                      child: const WaterCard(),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                      ),
                      child: const AnalyticsCard(),
                    ),
                    const CalendarWidget(),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButton: !isDesktop ? const FloatingAIButton() : null,
        );
      },
    );
  }
}
