import 'package:flutter/material.dart';
import 'package:maahvi/data/models/state_model.dart';
import 'package:maahvi/data/repositories/lottery_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final LotteryRepository _repository = LotteryRepository();

  List<StateModel> _states = [];
  List<dynamic> _ads = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<StateModel> get states => _states;
  List<dynamic> get ads => _ads;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchHomeData() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final List<dynamic> results = await Future.wait([
        _repository.getStates(),
        _repository.getAds(),
      ]);

      _states = results[0];
      _ads = results[1];
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStates() => fetchHomeData();
}
