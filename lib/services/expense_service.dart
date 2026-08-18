import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/expense_model.dart';

class ExpenseService {
  static Future<List<ExpenseModel>> getByUser(String userId) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.expensesPath}',
    ).replace(queryParameters: {'userId': userId});
    final res = await http.get(uri);
    if (res.statusCode == 404) {
      final fallback = await _getTransactions(userId);
      return fallback
          .where((item) => item['type']?.toString() == 'expense')
          .map((item) => ExpenseModel.fromJson(item))
          .toList();
    }
    _ensureSuccess(res, 'load expenses failed');

    final data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((item) => ExpenseModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> add(ExpenseModel expense) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.expensesPath}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(expense.toJson()),
    );
    if (res.statusCode == 404) {
      final fallback = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.transactionsPath}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          ...expense.toJson(),
          'type': 'expense',
          'title': expense.category,
        }),
      );
      if (fallback.statusCode == 201) return;
      throw Exception('add expense failed (${fallback.statusCode})');
    }
    if (res.statusCode != 201) {
      throw Exception('add expense failed (${res.statusCode})');
    }
  }

  static Future<void> delete(String id) async {
    final res = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.expensesPath}/$id'),
    );
    if (res.statusCode == 404) {
      final fallback = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.transactionsPath}/$id'),
      );
      _ensureSuccess(fallback, 'delete expense failed');
      return;
    }
    _ensureSuccess(res, 'delete expense failed');
  }

  static Future<List<Map<String, dynamic>>> _getTransactions(
    String userId,
  ) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.transactionsPath}',
    ).replace(queryParameters: {'userId': userId});
    final res = await http.get(uri);
    _ensureSuccess(res, 'load transactions failed');
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  static void _ensureSuccess(http.Response res, String message) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('$message (${res.statusCode})');
    }
  }

  // ເພີ່ມຟັງຊັນນີ້ເຂົ້າໄປໃນຄຼາສ ExpenseService
  static Future<void> update(ExpenseModel expense) async {
    final res = await http.put(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.expensesPath}/${expense.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(expense.toJson()),
    );
    _ensureSuccess(res, 'update expense failed');
  }
}
