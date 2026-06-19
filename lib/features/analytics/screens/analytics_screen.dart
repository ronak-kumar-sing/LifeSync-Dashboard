import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/shared/empty_state.dart';
import '../../../widgets/shared/loading_shimmer.dart';
import '../providers/analytics_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const LoadingShimmer(count: 3);
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Analytics'),
            backgroundColor: AppColors.background,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primaryText),
                onPressed: () => _showMetricDialog(context, provider),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMetricHeader(provider),
                const SizedBox(height: 16),
                _buildAreaChart(provider),
                const SizedBox(height: 16),
                _buildDateRangePicker(context, provider),
                const SizedBox(height: 16),
                _buildEntriesList(provider),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddEntryDialog(context, provider),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildMetricHeader(AnalyticsProvider provider) {
    final change = provider.totalChange;
    final absChange = provider.absoluteChange;
    final isPositive = change >= 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.yellowAccent.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.yellowAccent.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${isPositive ? '+' : ''}${absChange.toStringAsFixed(0)}${absChange.abs() >= 1000 ? ' k' : ''}',
            style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 42,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? AppColors.greenAccent : AppColors.negative,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: isPositive ? AppColors.greenAccent : AppColors.negative,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'vs start of period',
                style: TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAreaChart(AnalyticsProvider provider) {
    final data = provider.chartData;
    if (data.isEmpty) {
      return const EmptyState(
        icon: Icons.show_chart,
        title: 'No Data',
        message: 'Add some entries to see your analytics chart.',
      );
    }

    final maxY = data.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.2;
    final minY = data.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final start = data.first;
    final end = data.last;

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
            'Trend',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: (maxY - minY) / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.chartGrid,
                    strokeWidth: 0.5,
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: AppColors.chartGrid,
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: AppColors.chartTooltip,
                    getTooltipItems: (touchedSpots) => touchedSpots.map((spot) => LineTooltipItem(
                      spot.y.toStringAsFixed(0),
                      const TextStyle(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    )).toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: data,
                    isCurved: true,
                    curveSmoothness: 0.4,
                    color: AppColors.yellowAccent,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                        radius: index == 0 || index == data.length - 1 ? 6 : 0,
                        color: AppColors.primaryText,
                        strokeWidth: 2,
                        strokeColor: AppColors.yellowAccent,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.yellowAccent.withOpacity(0.3),
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Start: ${start.y.toStringAsFixed(0)}',
                style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
              ),
              Text(
                'End: ${end.y.toStringAsFixed(0)}',
                style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangePicker(BuildContext context, AnalyticsProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildDateChip(
            context,
            'From: ${DateFormat('MMM d').format(provider.startDate)}',
            () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: provider.startDate,
                firstDate: DateTime(2020),
                lastDate: provider.endDate,
              );
              if (picked != null) provider.setDateRange(picked, provider.endDate);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDateChip(
            context,
            'To: ${DateFormat('MMM d').format(provider.endDate)}',
            () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: provider.endDate,
                firstDate: provider.startDate,
                lastDate: DateTime.now(),
              );
              if (picked != null) provider.setDateRange(provider.startDate, picked);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateChip(BuildContext context, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.yellowAccent.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 14, color: AppColors.yellowAccent),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntriesList(AnalyticsProvider provider) {
    final entries = provider.filteredEntries;
    if (entries.isEmpty) return const SizedBox.shrink();

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
            'Entries',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length.clamp(0, 10),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.yellowAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.show_chart, color: AppColors.yellowAccent, size: 18),
                ),
                title: Text(
                  entry.value.toStringAsFixed(0),
                  style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  DateFormat('MMM d, yyyy').format(entry.date),
                  style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showMetricDialog(BuildContext context, AnalyticsProvider provider) {
    final controller = TextEditingController(text: provider.currentMetric);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Metric Name', style: TextStyle(color: AppColors.primaryText)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.primaryText),
          decoration: const InputDecoration(
            hintText: 'e.g., Views, Followers, Sales, Steps',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.setMetric(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context, AnalyticsProvider provider) {
    final valueController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Add Entry', style: TextStyle(color: AppColors.primaryText)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.primaryText),
                decoration: const InputDecoration(
                  labelText: 'Value',
                  hintText: 'e.g., 1000',
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: AppColors.secondaryText),
                title: Text(
                  DateFormat('MMM d, yyyy').format(selectedDate),
                  style: const TextStyle(color: AppColors.primaryText),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(valueController.text);
                if (value != null) {
                  provider.addEntry(value, selectedDate);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
