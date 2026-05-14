import 'package:flutter/material.dart';
import 'package:maahvi/data/models/result_model.dart';
import 'package:maahvi/data/repositories/lottery_repository.dart';

class StateViewModel extends ChangeNotifier {
  final LotteryRepository _repository = LotteryRepository();

  List<ResultModel> _results = [];
  List<dynamic> _predictions = []; // Changed to List
  bool _isLoading = false;
  String _errorMessage = '';

  List<ResultModel> get results => _results;
  List<dynamic> get predictions => _predictions; // Getter for list
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchStateData(String stateId, {String? date}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _results = await _repository.getResults(stateId, date: date);
      _predictions = await _repository.getPredictions(stateId, date: date);
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
