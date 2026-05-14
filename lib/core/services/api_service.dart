import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // আপনার রেন্ডার ব্যাকএন্ড ইউআরএল এখানে বসানো হলো
  static const String _liveBaseUrl = 'https://maahvi-web.onrender.com/api';

  String get baseUrl => kDebugMode
      ? (kIsWeb ? 'http://localhost:5000/api' : 'http://10.0.2.2:5000/api')
      : _liveBaseUrl;

  // Helper to handle response and ensure it returns dynamic data
  dynamic _handleResponse(http.Response response) {
    final body = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw body['message'] ?? 'Server Error: ${response.statusCode}';
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      if (e.toString().contains('ClientException')) {
        throw 'সার্ভার সচল নেই। লাইভ ইউআরএল কি সঠিক দেওয়া হয়েছে?';
      }
      rethrow;
    }
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl$endpoint'),
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }
}
