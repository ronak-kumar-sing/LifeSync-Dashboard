import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/storage/hive_storage.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/sync/sync_engine.dart';
import '../../../widgets/shared/loading_shimmer.dart';
import '../../../widgets/shared/empty_state.dart';

class WaterEntry {
  final String id;
  final double amount; // in liters
  final DateTime date;
  final DateTime createdAt;

  WaterEntry({
    required this.id,
    required this.amount,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'timestamp': createdAt.millisecondsSinceEpoch,
      };

  factory WaterEntry.fromJson(Map<String, dynamic> json) => WaterEntry(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class WaterProvider extends ChangeNotifier {
  List<WaterEntry> _entries = [];
  double _dailyGoal = StorageKeys.defaultWaterGoal;
  bool _isLoading = false;
  String _error = '';

  List<WaterEntry> get entries => _entries;
  double get dailyGoal => _dailyGoal;
  bool get isLoading => _isLoading;
  String get error => _error;

  double get todayIntake {
    final now = DateTime.now();
    return _entries
        .where((e) => e.date.year == now.year && e.date.month == now.month && e.date.day == now.day)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get todayPercentage {
    if (_dailyGoal <= 0) return 0;
    return (todayIntake / _dailyGoal).clamp(0.0, 1.0);
  }

  double get weeklyAverage {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEntries = _entries.where((e) => e.date.isAfter(weekStart.subtract(const Duration(days: 1))));
    if (weekEntries.isEmpty) return 0;
    return weekEntries.fold(0.0, (sum, e) => sum + e.amount) / 7;
  }

  Map<DateTime, double> get weeklyData {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final data = <DateTime, double>{};
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      data[date] = _entries
          .where((e) => e.date.year == date.year && e.date.month == date.month && e.date.day == date.day)
          .fold(0.0, (sum, e) => sum + e.amount);
    }
    return data;
  }

  WaterProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final goal = HiveStorage.getWaterData(StorageKeys.waterGoal);
      if (goal != null) _dailyGoal = (goal as num).toDouble();

      final data = HiveStorage.getWaterData(StorageKeys.waterEntries, defaultValue: <String>[]);
      if (data is List) {
        _entries = data
            .map((e) => WaterEntry.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        _entries.sort((a, b) => b.date.compareTo(a.date));
      }
      _error = '';
    } catch (e) {
      _error = 'Failed to load water data';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWater(double amount) async {
    try {
      final entry = WaterEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );
      _entries.add(entry);
      _entries.sort((a, b) => b.date.compareTo(a.date));
      await _saveData();
      await SyncEngine.syncWater(entry.toJson());
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add water entry';
      notifyListeners();
    }
  }

  Future<void> setGoal(double goal) async {
    _dailyGoal = goal;
    await HiveStorage.setWaterData(StorageKeys.waterGoal, goal);
    notifyListeners();
  }

  Future<void> _saveData() async {
    final data = _entries.map((e) => e.toJson()).toList();
    await HiveStorage.setWaterData(StorageKeys.waterEntries, data);
  }

  Future<void> resetToday() async {
    final now = DateTime.now();
    _entries.removeWhere((e) => e.date.year == now.year && e.date.month == now.month && e.date.day == now.day);
    await _saveData();
    notifyListeners();
  }
}
