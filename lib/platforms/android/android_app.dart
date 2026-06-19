import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/models/app_state.dart';
import '../../features/income/screens/income_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/water/screens/water_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../widgets/shared/dashboard_home.dart';

class AndroidAppLayout extends StatefulWidget {
  const AndroidAppLayout({super.key});

  @override
  State<AndroidAppLayout> createState() => _AndroidAppLayoutState();
}

class _AndroidAppLayoutState extends State<AndroidAppLayout> {
  final List<Widget> _screens = const [
    DashboardHome(),
    IncomeScreen(),
    CalendarScreen(),
    WaterScreen(),
    AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Scaffold(
          body: IndexedStack(
            index: appState.selectedIndex,
            children: _screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(
                  color: AppColors.mutedText.withOpacity(0.2),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: BottomNavigationBar(
                currentIndex: appState.selectedIndex,
                onTap: (index) => context.read<AppState>().setSelectedIndex(index),
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppColors.greenAccent,
                unselectedItemColor: AppColors.mutedText,
                selectedLabelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 12,
                ),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.account_balance_wallet_outlined),
                    activeIcon: Icon(Icons.account_balance_wallet),
                    label: 'Money',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today_outlined),
                    activeIcon: Icon(Icons.calendar_today),
                    label: 'Calendar',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.water_drop_outlined),
                    activeIcon: Icon(Icons.water_drop),
                    label: 'Water',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.show_chart_outlined),
                    activeIcon: Icon(Icons.show_chart),
                    label: 'Analytics',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
