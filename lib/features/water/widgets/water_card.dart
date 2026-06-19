import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/water_provider.dart';

class WaterCard extends StatelessWidget {
  const WaterCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, provider, _) {
        final today = provider.todayIntake;
        final goal = provider.dailyGoal;
        final percentage = provider.todayPercentage;
        final weeklyData = provider.weeklyData;
        final isAbove75 = percentage >= 0.75;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF0D0D0D),
            border: Border.all(
              color: AppColors.blueAccent.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.blueAccent.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${today.toStringAsFixed(1)} L',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'today',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.mutedText,
                            ),
                      ),
                    ],
                  ),
                  CircularPercentIndicator(
                    radius: 36,
                    lineWidth: 6,
                    percent: percentage,
                    center: Text(
                      '${(percentage * 100).toInt()}%',
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    progressColor: isAbove75 ? AppColors.neonGreen : AppColors.blueAccent,
                    backgroundColor: AppColors.mutedText.withOpacity(0.2),
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                    animationDuration: 1000,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 120,
                child: _buildWeeklyChart(weeklyData, goal, context),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(width: 12, height: 2, color: AppColors.neonGreen),
                  const SizedBox(width: 6),
                  Text(
                    'GOAL: ${goal.toStringAsFixed(1)}L',
                    style: const TextStyle(
                      color: AppColors.neonGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${provider.weeklyAverage.toStringAsFixed(1)} L/DAY AVERAGE',
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildWaterButton(context, '250 ml', 0.25),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildWaterButton(context, '500 ml', 0.50),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildWaterButton(context, '1 L', 1.0),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyChart(Map<DateTime, double> data, double goal, BuildContext context) {
    final entries = data.entries.toList();
    final maxVal = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final maxY = maxVal > goal ? maxVal * 1.2 : goal * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: goal / 2,
          getDrawingHorizontalLine: (value) {
            if (value == goal) {
              return FlLine(
                color: AppColors.neonGreen.withOpacity(0.5),
                strokeWidth: 2,
                dashArray: [5, 5],
              );
            }
            return FlLine(
              color: AppColors.chartGrid,
              strokeWidth: 0.5,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= entries.length) return const SizedBox.shrink();
                final day = entries[index].key;
                final isToday = DateTime.now().day == day.day;
                return Text(
                  DateFormat('E').format(day).substring(0, 1),
                  style: TextStyle(
                    color: isToday ? AppColors.blueAccent : AppColors.mutedText,
                    fontSize: 11,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: entries.asMap().entries.map((e) {
          final index = e.key;
          final value = e.value.value;
          final isToday = DateTime.now().day == e.value.key.day;
          final isAboveGoal = value >= goal;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                color: isToday
                    ? AppColors.blueAccent
                    : isAboveGoal
                        ? AppColors.neonGreen.withOpacity(0.8)
                        : AppColors.blueAccent.withOpacity(0.5),
                width: 14,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: AppColors.chartGrid.withOpacity(0.3),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWaterButton(BuildContext context, String label, double amount) {
    return ElevatedButton(
      onPressed: () => context.read<WaterProvider>().addWater(amount),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blueAccent.withOpacity(0.2),
        foregroundColor: AppColors.blueAccent,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: AppColors.blueAccent.withOpacity(0.3)),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}
