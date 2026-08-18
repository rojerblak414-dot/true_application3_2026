import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  static const _userIdKey = 'userId';
  static const _userNameKey = 'userName';
  static const _userEmailKey = 'userEmail';

  static Future<UserModel?> login(String email, String password) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.usersPath}',
    ).replace(queryParameters: {'email': email, 'password': password});
    final res = await http.get(uri);
    // _ensureSuccess(res, 'login failed');

    final data = jsonDecode(res.body) as List<dynamic>;

    if (data.isEmpty) return null;

    final user = UserModel.fromJson(data.first as Map<String, dynamic>);
    await _saveUser(user);
    return user;
  }

  static Future<UserModel> register(
    String name,
    String email,
    String password,
  ) async {
    final checkUri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.usersPath}',
    ).replace(queryParameters: {'email': email});
    final check = await http.get(checkUri);
    _ensureSuccess(check, 'email check failed');

    final existing = jsonDecode(check.body) as List<dynamic>;
    if (existing.isNotEmpty) {
      throw Exception('email-already-in-use');
    }

    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.usersPath}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (res.statusCode != 201) {
      throw Exception('register-failed');
    }

    return UserModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }

  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<Map<String, String>> getCurrentUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_userNameKey) ?? 'No Name',
      'email': prefs.getString(_userEmailKey) ?? 'No Email',
    };
  }

  static Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, user.id);
    await prefs.setString(_userNameKey, user.name);
    await prefs.setString(_userEmailKey, user.email);
  }

  static void _ensureSuccess(http.Response res, String message) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('$message (${res.statusCode})');
    }
  }
}
