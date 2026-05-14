import 'package:flutter/material.dart';
import 'package:maahvi/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VipViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isVip = false;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isVip => _isVip;

  VipViewModel() {
    _loadVipStatus();
  }

  // Load VIP status from local storage
  Future<void> _loadVipStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isVip = prefs.getBool('isVip') ?? false;
    notifyListeners();
  }

  Future<bool> activateFreeVip(String userId, String taskCode) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _apiService.post('/payments/activate-free', {
        'userId': userId,
        'taskCode': taskCode.trim(), // Trim input
      });

      // Check for success message or isVip flag
      if (response['isVip'] == true ||
          response['message'].toString().toLowerCase().contains('successful')) {
        _isVip = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isVip', true);
        notifyListeners();
        return true;
      }
      _errorMessage = 'Invalid Code! Please try again.';
      return false;
    } catch (e) {
      _errorMessage = e.toString().contains('Invalid')
          ? e.toString()
          : 'Connection Error! Try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logoutVip() async {
    _isVip = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isVip', false);
    notifyListeners();
  }
}
