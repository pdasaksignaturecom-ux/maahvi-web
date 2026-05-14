import 'package:flutter/material.dart';
import 'package:maahvi/data/models/result_model.dart';
import 'package:maahvi/data/repositories/lottery_repository.dart';

class ResultViewModel extends ChangeNotifier {
  final LotteryRepository _repository = LotteryRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ResultModel? _selectedResult;
  ResultModel? get selectedResult => _selectedResult;

  List<ResultModel> _allTodayResults = [];
  List<ResultModel> get allTodayResults => _allTodayResults;

  List<dynamic> _todayPredictions = [];

  Future<void> fetchResultDetail(String resultId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _selectedResult = await _repository.getResultById(resultId);
      if (_selectedResult != null) {
        // Use stateId (ObjectId) instead of stateName for fetching related data
        // because stateName might be empty in the Result object
        final String identifier = _selectedResult!.stateId.isNotEmpty
            ? _selectedResult!.stateId
            : _selectedResult!.stateName;

        _allTodayResults = await _repository.getResults(identifier,
            date: _selectedResult!.date);
        _todayPredictions = await _repository.getPredictions(identifier,
            date: _selectedResult!.date);
      }
    } catch (e) {
      debugPrint("Error fetching result detail: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic>? getPredictionForTime(String time,
      {bool isVip = false}) {
    try {
      final t = time.toUpperCase().replaceAll(" ", "");
      for (var p in _todayPredictions) {
        final pTime =
            p['drawTime'].toString().toUpperCase().replaceAll(" ", "");
        final pIsVip =
            (p['isVip'] == true || p['isVip'] == 'true' || p['isVip'] == 1);
        if (pTime.contains(t) && pIsVip == isVip) return p;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }
}
