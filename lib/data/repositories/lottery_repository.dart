import 'package:maahvi/core/services/api_service.dart';
import 'package:maahvi/data/models/result_model.dart';
import 'package:maahvi/data/models/state_model.dart';

class LotteryRepository {
  final ApiService _apiService = ApiService();

  Future<List<StateModel>> getStates() async {
    try {
      final response = await _apiService.get('/states');
      return (response as List).map((e) => StateModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ResultModel>> getResults(String stateId, {String? date}) async {
    try {
      String url = '/results/$stateId';
      if (date != null) url += '?date=$date';
      final response = await _apiService.get(url);
      return (response as List).map((e) => ResultModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<ResultModel> getResultById(String resultId) async {
    final response = await _apiService.get('/results/detail/$resultId');
    return ResultModel.fromJson(response);
  }

  Future<List<dynamic>> getPredictions(String stateId, {String? date}) async {
    try {
      String url = '/predictions/$stateId';
      if (date != null) url += '?date=$date';
      final response = await _apiService.get(url);
      if (response is List) return response;
      return response != null ? [response] : [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getAds() async {
    try {
      final response = await _apiService.get('/ads');
      return response as List;
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await _apiService.get('/settings');
      return Map<String, dynamic>.from(response);
    } catch (e) {
      return {"vipSecretCode": "DEAR77"};
    }
  }

  // --- Admin & Support Functions ---
  Future<void> uploadResult(Map<String, dynamic> resultData) async {
    await _apiService.post('/results', resultData);
  }

  Future<void> deleteResult(String id) async {
    await _apiService.delete('/results/$id');
  }

  Future<void> updatePrediction(Map<String, dynamic> data) async {
    await _apiService.post('/predictions', data);
  }

  Future<void> saveBulkPredictions(Map<String, dynamic> data) async {
    await _apiService.post('/predictions/bulk', data);
  }

  Future<void> postAd(Map<String, dynamic> data) async {
    await _apiService.post('/ads', data);
  }

  Future<void> updateAd(String id, Map<String, dynamic> data) async {
    await _apiService.put('/ads/$id', data);
  }

  Future<void> deleteAd(String id) async {
    await _apiService.delete('/ads/$id');
  }

  Future<void> updateSettings(Map<String, dynamic> data) async {
    await _apiService.post('/settings', data);
  }
}
