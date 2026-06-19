import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/analytics_provider.dart';

class AnalyticsCard extends StatelessWidget {
  const AnalyticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider, _) {
        final data = provider.chartData;
        if (data.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.surface,
              border: Border.all(
                color: AppColors.yellowAccent.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.currentMetric.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.yellowAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No data yet',
                  style: TextStyle(color: AppColors.mutedText),
                ),
              ],
            ),
          );
        }

        final maxY = data.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.3;
        final minY = data.map((e) => e.y).reduce((a, b) => a < b ? a : b);
        final change = provider.totalChange;
        final isPositive = change >= 0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.surface,
            border: Border.all(
              color: AppColors.yellowAccent.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.yellowAccent.withOpacity(0.15),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.yellowAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      provider.currentMetric.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.yellowAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPositive ? AppColors.greenAccent.withOpacity(0.2) : AppColors.negative.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: isPositive ? AppColors.greenAccent : AppColors.negative,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${isPositive ? '+' : ''}${provider.absoluteChange.toStringAsFixed(0)}${provider.absoluteChange.abs() >= 1000 ? 'k' : ''}',
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: data,
                        isCurved: true,
                        curveSmoothness: 0.4,
                        color: AppColors.yellowAccent,
                        barWidth: 2.5,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.yellowAccent.withOpacity(0.2),
                              AppColors.yellowAccent.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                    minY: minY >= 0 ? 0 : minY * 0.9,
                    maxY: maxY,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
