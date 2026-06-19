import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/storage/hive_storage.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/sync/sync_engine.dart';
import '../../../widgets/shared/loading_shimmer.dart';
import '../../../widgets/shared/empty_state.dart';
import '../../../widgets/shared/glow_border.dart';

class AnalyticsEntry {
  final String id;
  final String metric; // e.g., Views, Followers, Sales, Steps
  final double value;
  final DateTime date;
  final DateTime createdAt;

  AnalyticsEntry({
    required this.id,
    required this.metric,
    required this.value,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'metric': metric,
        'value': value,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'timestamp': createdAt.millisecondsSinceEpoch,
      };

  factory AnalyticsEntry.fromJson(Map<String, dynamic> json) => AnalyticsEntry(
        id: json['id'] as String,
        metric: json['metric'] as String,
        value: (json['value'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class AnalyticsProvider extends ChangeNotifier {
  List<AnalyticsEntry> _entries = [];
  String _currentMetric = StorageKeys.defaultMetric;
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;
  String _error = '';

  List<AnalyticsEntry> get entries => _entries;
  String get currentMetric => _currentMetric;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  bool get isLoading => _isLoading;
  String get error => _error;

  List<AnalyticsEntry> get filteredEntries {
    return _entries
        .where((e) => e.metric == _currentMetric)
        .where((e) => e.date.isAfter(_startDate.subtract(const Duration(days: 1))) && e.date.isBefore(_endDate.add(const Duration(days: 1))))
        .toList();
  }

  double get totalChange {
    final data = filteredEntries..sort((a, b) => a.date.compareTo(b.date));
    if (data.length < 2) return 0;
    final first = data.first.value;
    final last = data.last.value;
    if (first == 0) return 0;
    return ((last - first) / first) * 100;
  }

  double get absoluteChange {
    final data = filteredEntries..sort((a, b) => a.date.compareTo(b.date));
    if (data.length < 2) return 0;
    return data.last.value - data.first.value;
  }

  List<FlSpot> get chartData {
    final data = filteredEntries..sort((a, b) => a.date.compareTo(b.date));
    return data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList();
  }

  AnalyticsProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final metric = HiveStorage.getAnalyticsData(StorageKeys.analyticsMetric);
      if (metric != null) _currentMetric = metric as String;

      final data = HiveStorage.getAnalyticsData(StorageKeys.analyticsEntries, defaultValue: <String>[]);
      if (data is List) {
        _entries = data
            .map((e) => AnalyticsEntry.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        _entries.sort((a, b) => b.date.compareTo(a.date));
      }
      _error = '';
    } catch (e) {
      _error = 'Failed to load analytics data';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEntry(double value, DateTime date) async {
    try {
      final entry = AnalyticsEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        metric: _currentMetric,
        value: value,
        date: date,
        createdAt: DateTime.now(),
      );
      _entries.add(entry);
      _entries.sort((a, b) => b.date.compareTo(a.date));
      await _saveData();
      await SyncEngine.syncAnalytics(entry.toJson());
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add entry';
      notifyListeners();
    }
  }

  Future<void> setMetric(String metric) async {
    _currentMetric = metric;
    await HiveStorage.setAnalyticsData(StorageKeys.analyticsMetric, metric);
    notifyListeners();
  }

  Future<void> setDateRange(DateTime start, DateTime end) async {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  Future<void> _saveData() async {
    final data = _entries.map((e) => e.toJson()).toList();
    await HiveStorage.setAnalyticsData(StorageKeys.analyticsEntries, data);
  }
}
