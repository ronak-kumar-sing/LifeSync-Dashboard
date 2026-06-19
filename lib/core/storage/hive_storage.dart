import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'storage_keys.dart';

class HiveStorage {
  static final HiveStorage _instance = HiveStorage._internal();
  factory HiveStorage() => _instance;
  HiveStorage._internal();

  static final Logger _logger = Logger();
  static bool _initialized = false;

  static late Box<dynamic> _incomeBox;
  static late Box<dynamic> _waterBox;
  static late Box<dynamic> _calendarBox;
  static late Box<dynamic> _analyticsBox;
  static late Box<dynamic> _settingsBox;

  static Future<void> initialize() async {
    if (_initialized) return;

    _incomeBox = await Hive.openBox(StorageKeys.incomeBox);
    _waterBox = await Hive.openBox(StorageKeys.waterBox);
    _calendarBox = await Hive.openBox(StorageKeys.calendarBox);
    _analyticsBox = await Hive.openBox(StorageKeys.analyticsBox);
    _settingsBox = await Hive.openBox(StorageKeys.settingsBox);

    _initialized = true;
    _logger.i('HiveStorage initialized');
  }

  static Box<dynamic> get incomeBox => _incomeBox;
  static Box<dynamic> get waterBox => _waterBox;
  static Box<dynamic> get calendarBox => _calendarBox;
  static Box<dynamic> get analyticsBox => _analyticsBox;
  static Box<dynamic> get settingsBox => _settingsBox;

  static Future<void> setIncomeData(String key, dynamic value) async {
    await _incomeBox.put(key, value);
  }

  static dynamic getIncomeData(String key, {dynamic defaultValue}) {
    return _incomeBox.get(key, defaultValue: defaultValue);
  }

  static Future<void> deleteIncomeData(String key) async {
    await _incomeBox.delete(key);
  }

  static Future<void> setWaterData(String key, dynamic value) async {
    await _waterBox.put(key, value);
  }

  static dynamic getWaterData(String key, {dynamic defaultValue}) {
    return _waterBox.get(key, defaultValue: defaultValue);
  }

  static Future<void> deleteWaterData(String key) async {
    await _waterBox.delete(key);
  }

  static Future<void> setCalendarData(String key, dynamic value) async {
    await _calendarBox.put(key, value);
  }

  static dynamic getCalendarData(String key, {dynamic defaultValue}) {
    return _calendarBox.get(key, defaultValue: defaultValue);
  }

  static Future<void> setAnalyticsData(String key, dynamic value) async {
    await _analyticsBox.put(key, value);
  }

  static dynamic getAnalyticsData(String key, {dynamic defaultValue}) {
    return _analyticsBox.get(key, defaultValue: defaultValue);
  }

  static Future<void> setSettings(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  static dynamic getSettings(String key, {dynamic defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  static Future<void> clearAll() async {
    await _incomeBox.clear();
    await _waterBox.clear();
    await _calendarBox.clear();
    await _analyticsBox.clear();
    await _settingsBox.clear();
  }
}