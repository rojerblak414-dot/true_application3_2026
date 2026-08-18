import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/income_model.dart';

class IncomeService {
  static Future<List<IncomeModel>> getByUser(String userId) async {
    final res = await _get(ApiConfig.incomesPath, userId);
    final data = jsonDecode(res.body) as List<dynamic>;
    return data
        .where((item) {
          final map = item as Map<String, dynamic>;
          return map['type'] == null || map['type']?.toString() == 'income';
        })
        .map((item) => IncomeModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> add(IncomeModel income) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.incomesPath}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(income.toJson()),
    );
    if (res.statusCode == 404) {
      final fallback = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.legacyIncomePath}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(income.toJson()),
      );
      if (fallback.statusCode == 201) return;
      if (fallback.statusCode == 404) {
        final transactionsFallback = await http.post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.transactionsPath}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            ...income.toJson(),
            'type': 'income',
            'category': 'Income',
            'title': 'Income',
          }),
        );
        if (transactionsFallback.statusCode == 201) return;
        throw Exception(
          'add income failed (${transactionsFallback.statusCode})',
        );
      }
      throw Exception('add income failed (${fallback.statusCode})');
    }
    if (res.statusCode != 201) {
      throw Exception('add income failed (${res.statusCode})');
    }
  }

  static Future<void> delete(String id) async {
    final res = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.incomesPath}/$id'),
    );
    if (res.statusCode == 404) {
      final fallback = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.legacyIncomePath}/$id'),
      );
      if (fallback.statusCode == 404) {
        final transactionsFallback = await http.delete(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.transactionsPath}/$id'),
        );
        _ensureSuccess(transactionsFallback, 'delete income failed');
        return;
      }
      _ensureSuccess(fallback, 'delete income failed');
      return;
    }
    _ensureSuccess(res, 'delete income failed');
  }

  static Future<http.Response> _get(String path, String userId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}$path',
    ).replace(queryParameters: {'userId': userId});
    final res = await http.get(uri);
    if (res.statusCode != 404) {
      _ensureSuccess(res, 'load income failed');
      return res;
    }

    final fallbackUri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.legacyIncomePath}',
    ).replace(queryParameters: {'userId': userId});
    final fallback = await http.get(fallbackUri);
    if (fallback.statusCode == 404) {
      final transactionsUri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.transactionsPath}',
      ).replace(queryParameters: {'userId': userId});
      final transactions = await http.get(transactionsUri);
      _ensureSuccess(transactions, 'load income failed');
      return transactions;
    }
    _ensureSuccess(fallback, 'load income failed');
    return fallback;
  }

  static void _ensureSuccess(http.Response res, String message) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('$message (${res.statusCode})');
    }
  }
}
