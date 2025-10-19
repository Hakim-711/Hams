import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:hams/core/storage/session_manager.dart';

class ApiService {
  ApiService._();

  static final String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static Future<Map<String, String>> _buildHeaders({bool includeContentType = true}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (includeContentType) {
      headers['Content-Type'] = 'application/json';
    }

    final token = await SessionManager.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Uri _buildUri(String endpoint) {
    return Uri.parse('$baseUrl/$endpoint');
  }

  static Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception('Unexpected response shape: $decoded');
  }

  static Future<Map<String, dynamic>> register({
    required String userId,
    required String username,
    required String passcode,
    required String profileImagePath,
  }) async {
    final response = await http.post(
      _buildUri('auth/register'),
      headers: await _buildHeaders(),
      body: jsonEncode({
        'userId': userId,
        'username': username,
        'passcode': passcode,
        'profileImagePath': profileImagePath,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return _decodeBody(response);
    }

    throw Exception('فشل التسجيل: ${response.body}');
  }

  static Future<Map<String, dynamic>> login({
    required String userId,
    required String passcode,
  }) async {
    final response = await http.post(
      _buildUri('auth/login'),
      headers: await _buildHeaders(),
      body: jsonEncode({'userId': userId, 'passcode': passcode}),
    );

    if (response.statusCode == 200) {
      return _decodeBody(response);
    }

    throw Exception('فشل تسجيل الدخول: ${response.body}');
  }

  static Future<Map<String, dynamic>> getUserById(String userId) async {
    final response = await http.get(
      _buildUri('auth/$userId'),
      headers: await _buildHeaders(includeContentType: false),
    );

    if (response.statusCode == 200) {
      return _decodeBody(response);
    }

    throw Exception('المستخدم غير موجود');
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      _buildUri(endpoint),
      headers: await _buildHeaders(includeContentType: false),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _decodeBody(response);
    }

    throw Exception('GET failed: ${response.body}');
  }

  static Future<List<Map<String, dynamic>>> getList(String endpoint) async {
    final response = await http.get(
      _buildUri(endpoint),
      headers: await _buildHeaders(includeContentType: false),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = response.body.isEmpty ? [] : jsonDecode(response.body);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .toList(growable: false);
      }
      throw Exception('GET list failed: غير متوقع - $decoded');
    }

    throw Exception('GET list failed: ${response.body}');
  }

  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    final response = await http.post(
      _buildUri(endpoint),
      headers: await _buildHeaders(),
      body: jsonEncode(data ?? <String, dynamic>{}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _decodeBody(response);
    }

    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    if (body is Map<String, dynamic> && body.containsKey('message')) {
      throw Exception(body['message']);
    }

    throw Exception('POST failed: ${response.body}');
  }

  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    final response = await http.put(
      _buildUri(endpoint),
      headers: await _buildHeaders(),
      body: jsonEncode(data ?? <String, dynamic>{}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _decodeBody(response);
    }

    throw Exception('PUT failed: ${response.body}');
  }

  static Future<bool> delete(String endpoint) async {
    final response = await http.delete(
      _buildUri(endpoint),
      headers: await _buildHeaders(includeContentType: false),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }

    throw Exception('DELETE failed: ${response.body}');
  }
}
