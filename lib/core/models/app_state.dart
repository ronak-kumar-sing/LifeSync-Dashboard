import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  int _selectedIndex = 0;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isMacOS = false;
  bool _isFabOpen = false;

  int get selectedIndex => _selectedIndex;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isMacOS => _isMacOS;
  bool get isFabOpen => _isFabOpen;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void setPlatform(bool isMacOS) {
    _isMacOS = isMacOS;
    notifyListeners();
  }

  void setFabOpen(bool open) {
    _isFabOpen = open;
    notifyListeners();
  }
}