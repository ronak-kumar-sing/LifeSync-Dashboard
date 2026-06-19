import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/models/app_state.dart';
import '../../features/income/screens/income_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/water/screens/water_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/ai_agent/screens/ai_agent_screen.dart';
import '../../widgets/shared/dashboard_home.dart';

class MacOSAppLayout extends StatelessWidget {
  const MacOSAppLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return MacosWindow(
          backgroundColor: AppColors.background,
          sidebar: Sidebar(
            minWidth: 200,
            startWidth: 220,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                right: BorderSide(
                  color: AppColors.mutedText.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.greenAccent, AppColors.blueAccent],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.dashboard, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'LifeSync',
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSidebarItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  index: 0,
                  isSelected: appState.selectedIndex == 0,
                ),
                _buildSidebarItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Income',
                  index: 1,
                  isSelected: appState.selectedIndex == 1,
                ),
                _buildSidebarItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Calendar',
                  index: 2,
                  isSelected: appState.selectedIndex == 2,
                ),
                _buildSidebarItem(
                  icon: Icons.water_drop_outlined,
                  label: 'Water',
                  index: 3,
                  isSelected: appState.selectedIndex == 3,
                ),
                _buildSidebarItem(
                  icon: Icons.show_chart_outlined,
                  label: 'Analytics',
                  index: 4,
                  isSelected: appState.selectedIndex == 4,
                ),
                const Spacer(),
                _buildSidebarItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  index: 5,
                  isSelected: appState.selectedIndex == 5,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          child: IndexedStack(
            index: appState.selectedIndex,
            children: const [
              DashboardHome(),
              IncomeScreen(),
              CalendarScreen(),
              WaterScreen(),
              AnalyticsScreen(),
              Center(child: Text('Settings', style: TextStyle(color: AppColors.primaryText))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => context.read<AppState>().setSelectedIndex(index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isSelected ? AppColors.greenAccent.withOpacity(0.15) : Colors.transparent,
            border: isSelected
                ? Border.all(color: AppColors.greenAccent.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.greenAccent : AppColors.secondaryText,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.greenAccent : AppColors.primaryText,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
