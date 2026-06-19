import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/calendar_widget.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: AppColors.background,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: CalendarWidget(),
      ),
    );
  }
}
