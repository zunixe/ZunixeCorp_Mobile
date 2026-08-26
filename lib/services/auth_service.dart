import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  static const _tokenKey = 'zunixe_token';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<Map<String, String>> authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/public/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['status'] == 'success') {
      await saveToken(body['data']['token']);
      return body['data'];
    }
    throw Exception(body['message'] ?? 'Login gagal');
  }

  Future<Map<String, dynamic>> register(
    String email, String password, String fullName, {String? phone}
  ) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/public/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'full_name': fullName,
        if (phone != null) 'phone': phone,
      }),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 201 && body['status'] == 'success') {
      await saveToken(body['data']['token']);
      return body['data'];
    }
    throw Exception(body['message'] ?? 'Pendaftaran gagal');
  }

  Future<Map<String, dynamic>> getMe() async {
    final headers = await authHeaders();
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/public/auth/me'),
      headers: headers,
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['status'] == 'success') {
      return body['data'];
    }
    throw Exception(body['message'] ?? 'Gagal memuat profil');
  }

  Future<void> logout() async {
    await clearToken();
  }
}
