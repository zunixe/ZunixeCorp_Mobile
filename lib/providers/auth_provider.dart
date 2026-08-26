import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _user;
  bool _loading = false;
  String? _error;

  Map<String, dynamic>? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> checkAuth() async {
    final token = await AuthService.getToken();
    if (token == null) return;
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      final data = await _authService.getMe();
      _user = data['user'];
    } catch (_) {
      await AuthService.clearToken();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _authService.login(email, password);
      _user = data['user'];
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
    String email, String password, String fullName, {String? phone}
  ) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _authService.register(email, password, fullName, phone: phone);
      _user = data['user'];
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
