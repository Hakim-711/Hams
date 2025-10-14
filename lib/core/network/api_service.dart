// // import 'dart:convert';
// // import 'package:http/http.dart' as http;

// // class ApiService {
// //   static const String baseUrl =
// //       'http://localhost:3000'; // ✅ عدّلها حسب عنوان السيرفر

// //   // REGISTER
// //   static Future<Map<String, dynamic>> register({
// //     required String userId,
// //     required String username,
// //     required String passcode,
// //     required String profileImagePath,
// //   }) async {
// //     final response = await http.post(
// //       Uri.parse('$baseUrl/auth/register'),
// //       headers: {'Content-Type': 'application/json'},
// //       body: jsonEncode({
// //         'userId': userId,
// //         'username': username,
// //         'passcode': passcode,
// //         'profileImagePath': profileImagePath,
// //       }),
// //     );

// //     if (response.statusCode == 200) {
// //       return jsonDecode(response.body);
// //     } else {
// //       throw Exception('فشل التسجيل: ${response.body}');
// //     }
// //   }

// //   // LOGIN
// //   static Future<Map<String, dynamic>> login({
// //     required String userId,
// //   }) async {
// //     final response = await http.get(
// //       Uri.parse('$baseUrl/auth/$userId'),
// //     );

// //     if (response.statusCode == 200) {
// //       return jsonDecode(response.body);
// //     } else {
// //       throw Exception('فشل تسجيل الدخول: ${response.body}');
// //     }
// //   }

// //   //post

// //   static Future<Map<String, dynamic>> post(
// //     String endpoint, {
// //     Map<String, dynamic>? data,
// //   }) async {
// //     final response = await http.post(
// //       Uri.parse('$baseUrl/$endpoint'),
// //       headers: {'Content-Type': 'application/json'},
// //       body: jsonEncode(data),
// //     );

// //     if (response.statusCode == 200) {
// //       return jsonDecode(response.body);
// //     } else {
// //       throw Exception('فشل الاتصال بالخادم: ${response.body}');
// //     }
// //   }
// // }

// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ApiService {
//   static const String baseUrl =
//       'http://localhost:3000'; // 🔁 UPDATE for production

//   // Generic GET (returns Map)
//   static Future<Map<String, dynamic>> get(String endpoint) async {
//     final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('GET failed: ${response.body}');
//     }
//   }

//   // Generic GET List (returns List of Map)
//   static Future<List<Map<String, dynamic>>> getList(String endpoint) async {
//     final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
//     if (response.statusCode == 200) {
//       return List<Map<String, dynamic>>.from(jsonDecode(response.body));
//     } else {
//       throw Exception('GET list failed: ${response.body}');
//     }
//   }

//   // Generic POST
//   static Future<Map<String, dynamic>> post(String endpoint,
//       {Map<String, dynamic>? data}) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/$endpoint'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(data),
//     );
//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception(jsonDecode(response.body)['message'] ?? 'خطأ غير معروف');
//     }
//   }

//   // Generic PUT
//   static Future<Map<String, dynamic>> put(String endpoint,
//       {Map<String, dynamic>? data}) async {
//     final response = await http.put(
//       Uri.parse('$baseUrl/$endpoint'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(data),
//     );

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('PUT failed: ${response.body}');
//     }
//   }

//   // Generic DELETE
//   static Future<bool> delete(String endpoint) async {
//     final response = await http.delete(Uri.parse('$baseUrl/$endpoint'));
//     if (response.statusCode == 200) {
//       return true;
//     } else {
//       throw Exception('DELETE failed: ${response.body}');
//     }
//   }
//
//
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.145:3000';
  static const _storage = FlutterSecureStorage();

  /// ✅ Helper: إضافة Authorization إذا كان عندك JWT
  static Future<Map<String, String>> _buildHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// ✅ تسجيل مستخدم جديد
  static Future<Map<String, dynamic>> register({
    required String userId,
    required String username,
    required String passcode,
    required String profileImagePath,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'username': username,
        'passcode': passcode,
        'profileImagePath': profileImagePath,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('فشل التسجيل: ${response.body}');
    }
  }

  /// ✅ تسجيل الدخول (عن طريق userId + passcode)
  static Future<Map<String, dynamic>> login({
    required String userId,
    required String passcode,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'passcode': passcode}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('فشل تسجيل الدخول: ${response.body}');
    }
  }

  /// ✅ جلب مستخدم حسب userId
  static Future<Map<String, dynamic>> getUserById(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/auth/user/$userId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('المستخدم غير موجود');
    }
  }

  /// 🔄 GET (single object)
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final headers = await _buildHeaders();
    final response =
        await http.get(Uri.parse('$baseUrl/$endpoint'), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('GET failed: ${response.body}');
    }
  }

  /// 🔄 GET (list of objects)
  static Future<List<Map<String, dynamic>>> getList(String endpoint) async {
    final headers = await _buildHeaders();
    final response =
        await http.get(Uri.parse('$baseUrl/$endpoint'), headers: headers);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('GET list failed: ${response.body}');
    }
  }

  /// ✅ POST (with optional body)
  static Future<Map<String, dynamic>> post(String endpoint,
      {Map<String, dynamic>? data}) async {
    final headers = await _buildHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'خطأ غير معروف');
    }
  }

  /// 🔄 PUT (update)
  static Future<Map<String, dynamic>> put(String endpoint,
      {Map<String, dynamic>? data}) async {
    final headers = await _buildHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('PUT failed: ${response.body}');
    }
  }

  /// 🗑️ DELETE
  static Future<bool> delete(String endpoint) async {
    final headers = await _buildHeaders();
    final response =
        await http.delete(Uri.parse('$baseUrl/$endpoint'), headers: headers);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('DELETE failed: ${response.body}');
    }
  }
}
