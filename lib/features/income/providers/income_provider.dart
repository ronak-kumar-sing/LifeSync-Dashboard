import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

import '../../../core/storage/hive_storage.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/sync/sync_engine.dart';
import 'income_model.dart';

class IncomeProvider extends ChangeNotifier {
  final Logger _logger = Logger();
  final _uuid = const Uuid();

  List<IncomeEntry> _entries = [];
  bool _isLoading = false;
  String _error = '';
  DateTime _selectedDate = DateTime.now();

  List<IncomeEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get selectedDate => _selectedDate;

  double get totalBalance {
    return _entries.fold(0.0, (sum, e) => sum + e.signedAmount);
  }

  double get totalIncome {
    return _entries
        .where((e) => e.isIncome)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get totalExpense {
    return _entries
        .where((e) => !e.isIncome)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  List<IncomeEntry> get entriesForSelectedDate {
    return _entries.where((e) =>
      e.date.year == _selectedDate.year &&
      e.date.month == _selectedDate.month &&
      e.date.day == _selectedDate.day
    ).toList();
  }

  Map<DateTime, double> get dailyBalance {
    final map = <DateTime, double>{};
    for (final entry in _entries) {
      final key = DateTime(entry.date.year, entry.date.month, entry.date.day);
      map[key] = (map[key] ?? 0.0) + entry.signedAmount;
    }
    return map;
  }

  List<MapEntry<DateTime, double>> get last14DaysBalance {
    final today = DateTime.now();
    final result = <MapEntry<DateTime, double>>[];
    for (int i = 13; i >= 0; i--) {
      final date = DateTime(today.year, today.month, today.day - i);
      final balance = dailyBalance[date] ?? 0.0;
      result.add(MapEntry(date, balance));
    }
    return result;
  }

  IncomeProvider() {
    loadEntries();
  }

  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = HiveStorage.getIncomeData(StorageKeys.incomeEntries, defaultValue: <String>[]);
      if (data is List) {
        _entries = data
            .map((e) => IncomeEntry.fromJson(jsonDecode(e as String)))
            .toList();
        _entries.sort((a, b) => b.date.compareTo(a.date));
      }
      _error = '';
    } catch (e) {
      _error = 'Failed to load income data';
      _logger.e('Error loading entries: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEntry({
    required double amount,
    required String label,
    required String category,
    required DateTime date,
    required bool isIncome,
  }) async {
    try {
      final entry = IncomeEntry(
        id: _uuid.v4(),
        amount: amount,
        label: label,
        category: category,
        date: date,
        isIncome: isIncome,
        createdAt: DateTime.now(),
      );

      _entries.add(entry);
      _entries.sort((a, b) => b.date.compareTo(a.date));
      await _saveEntries();

      await SyncEngine.syncIncome(entry.toJson());

      _error = '';
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add entry';
      _logger.e('Error adding entry: $e');
      notifyListeners();
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      _entries.removeWhere((e) => e.id == id);
      await _saveEntries();
      await SyncEngine.deleteFromFirestore('income', id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete entry';
      _logger.e('Error deleting entry: $e');
      notifyListeners();
    }
  }

  Future<void> _saveEntries() async {
    final data = _entries.map((e) => jsonEncode(e.toJson())).toList();
    await HiveStorage.setIncomeData(StorageKeys.incomeEntries, data);
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
