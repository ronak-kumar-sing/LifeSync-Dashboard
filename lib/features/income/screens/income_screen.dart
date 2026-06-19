import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/shared/empty_state.dart';
import '../../../widgets/shared/loading_shimmer.dart';
import '../../../widgets/shared/glass_card.dart';
import 'income_card.dart';
import '../providers/income_provider.dart';
import 'add_entry_sheet.dart';

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IncomeProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const LoadingShimmer(count: 3);
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Income & Expenses'),
            backgroundColor: AppColors.background,
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: AppColors.primaryText),
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const IncomeCard(),
                const SizedBox(height: 16),
                _buildChart(provider),
                const SizedBox(height: 16),
                _buildRecentEntries(provider),
              ],
            ),
          ),
          floatingActionButton: _buildFAB(context),
        );
      },
    );
  }

  Widget _buildChart(IncomeProvider provider) {
    final data = provider.last14DaysBalance;
    if (data.isEmpty) return const SizedBox.shrink();

    final maxVal = data.map((e) => e.value.abs()).reduce((a, b) => a > b ? a : b);
    final interval = maxVal > 0 ? maxVal / 5 : 1;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales / Balance by Day',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.secondaryText,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal + interval,
                minY: -(maxVal + interval),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.chartGrid,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
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
                        if (index < 0 || index >= data.length) return const SizedBox.shrink();
                        return Text(
                          DateFormat('E').format(data[index].key).substring(0, 1),
                          style: const TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((e) {
                  final index = e.key;
                  final value = e.value.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        color: value >= 0 ? AppColors.chartGreen : AppColors.chartRed,
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 0,
                          color: AppColors.chartGrid,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEntries(IncomeProvider provider) {
    if (provider.entries.isEmpty) {
      return EmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: 'No Entries Yet',
        message: 'Track your income and expenses to see them here.',
        actionLabel: 'Add Entry',
        onAction: () => _showAddEntrySheet(context),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Entries',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.entries.length.clamp(0, 20),
          itemBuilder: (context, index) {
            final entry = provider.entries[index];
            return _buildEntryTile(entry);
          },
        ),
      ],
    );
  }

  Widget _buildEntryTile(dynamic entry) {
    final isPositive = entry.isIncome;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isPositive ? AppColors.greenAccent.withOpacity(0.2) : AppColors.negative.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
          color: isPositive ? AppColors.greenAccent : AppColors.negative,
        ),
      ),
      title: Text(
        entry.label,
        style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${entry.category} \u2022 ${DateFormat('MMM d, yyyy').format(entry.date)}',
        style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
      ),
      trailing: Text(
        '${isPositive ? '+' : '-'}\$${entry.amount.toStringAsFixed(2)}',
        style: TextStyle(
          color: isPositive ? AppColors.greenAccent : AppColors.negative,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      onTap: () {},
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddEntrySheet(context),
      icon: const Icon(Icons.add),
      label: const Text('Add'),
    );
  }

  void _showAddEntrySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddEntrySheet(),
    );
  }
}
