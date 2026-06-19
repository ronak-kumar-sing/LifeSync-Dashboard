import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/shared/glass_card.dart';
import '../providers/income_provider.dart';

class IncomeCard extends StatelessWidget {
  const IncomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IncomeProvider>(
      builder: (context, provider, _) {
        final balance = provider.totalBalance;
        final isNegative = balance < 0;
        final data = provider.last14DaysBalance;

        return GlassCard(
          padding: const EdgeInsets.all(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A2E1A),
              Color(0xFF0A1A0A),
            ],
          ),
          glowShadow: AppColors.greenGlow,
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
                        'Total Balance',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.secondaryText,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$ ${balance.abs().toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: isNegative ? AppColors.negative : AppColors.greenAccent,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (isNegative)
                        Text(
                          '-\$ ${balance.abs().toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.negative,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isNegative ? AppColors.negative.withOpacity(0.2) : AppColors.greenAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isNegative ? Icons.trending_down : Icons.trending_up,
                          color: isNegative ? AppColors.negative : AppColors.greenAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isNegative ? 'Deficit' : 'Healthy',
                          style: TextStyle(
                            color: isNegative ? AppColors.negative : AppColors.greenAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (data.isNotEmpty) ...[
                Text(
                  'Sales / Balance by Day',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.mutedText,
                      ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: data.map((e) => e.value.abs()).reduce((a, b) => a > b ? a : b) * 1.2,
                      minY: 0,
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: data.asMap().entries.map((e) {
                        final index = e.key;
                        final value = e.value.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: value.abs(),
                              color: value >= 0 ? AppColors.chartGreen.withOpacity(0.8) : AppColors.chartRed.withOpacity(0.8),
                              width: 8,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
