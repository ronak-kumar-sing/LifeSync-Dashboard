import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/storage/hive_storage.dart';
import '../../../core/storage/storage_keys.dart';
import 'calendar_model.dart';

class CalendarProvider extends ChangeNotifier {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  DateTime get focusedMonth => _focusedMonth;
  DateTime get selectedDate => _selectedDate;
  String get monthYearLabel => DateFormat('MMMM yyyy').format(_focusedMonth);

  CalendarProvider() {
    _loadSelectedDate();
  }

  Future<void> _loadSelectedDate() async {
    final saved = HiveStorage.getCalendarData(StorageKeys.selectedDate);
    if (saved != null) {
      _selectedDate = DateTime.parse(saved as String);
      notifyListeners();
    }
  }

  List<CalendarDay> get daysInMonth {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final firstWeekday = firstDay.weekday - 1;

    final days = <CalendarDay>[];
    for (int i = firstWeekday - 1; i >= 0; i--) {
      days.add(CalendarDay(
        date: firstDay.subtract(Duration(days: i + 1)),
        isCurrentMonth: false,
      ));
    }
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(CalendarDay(
        date: DateTime(_focusedMonth.year, _focusedMonth.month, i),
        isCurrentMonth: true,
      ));
    }
    final remaining = 42 - days.length;
    for (int i = 1; i <= remaining; i++) {
      days.add(CalendarDay(
        date: DateTime(_focusedMonth.year, _focusedMonth.month + 1, i),
        isCurrentMonth: false,
      ));
    }
    return days;
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    HiveStorage.setCalendarData(StorageKeys.selectedDate, date.toIso8601String());
    notifyListeners();
  }

  void nextMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    notifyListeners();
  }

  void previousMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    notifyListeners();
  }

  void goToToday() {
    _focusedMonth = DateTime.now();
    _selectedDate = DateTime.now();
    notifyListeners();
  }

  bool isSelected(DateTime date) {
    return _selectedDate.year == date.year && _selectedDate.month == date.month && _selectedDate.day == date.day;
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year && now.month == date.month && now.day == date.day;
  }
}
