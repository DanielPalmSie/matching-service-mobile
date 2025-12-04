import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service);

  final AuthService _service;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _initialized = false;
  bool _loading = false;
  String? _token;
  String? _errorMessage;
  bool _rememberMe = true;

  bool get initialized => _initialized;
  bool get isLoading => _loading;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  String get displayName => 'User';
  String? get errorMessage => _errorMessage;
  bool get rememberMe => _rememberMe;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _rememberMe = prefs.getBool(_PrefsKeys.rememberMe) ?? true;
    _token = await _secureStorage.read(key: _PrefsKeys.token);
    _initialized = true;
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
    bool remember = true,
  }) async {
    _rememberMe = remember;
    await _saveRememberPreference();
    _setLoading(true);
    _errorMessage = null;
    try {
      final result = await _service.login(email: email, password: password);
      _token = result.token;

      if (remember) {
        await _secureStorage.write(key: _PrefsKeys.token, value: _token);
      } else {
        await _secureStorage.delete(key: _PrefsKeys.token);
      }
      notifyListeners();
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again later.';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _service.register(email: email, password: password);
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again later.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setRememberMe(bool value) async {
    _rememberMe = value;
    await _saveRememberPreference();
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_PrefsKeys.token);
    await _secureStorage.delete(key: _PrefsKeys.token);
    _token = null;
    notifyListeners();
  }

  Future<String?> getToken() async {
    if (_token != null && _token!.isNotEmpty) {
      return _token;
    }
    _token = await _secureStorage.read(key: _PrefsKeys.token);
    return _token;
  }

  Future<Map<String, String>> authorizationHeaders() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return {'Content-Type': 'application/json'};
    }
    return _service.buildAuthHeaders(token);
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> _saveRememberPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_PrefsKeys.rememberMe, _rememberMe);
  }
}

class _PrefsKeys {
  static const token = 'auth_token';
  static const rememberMe = 'remember_me';
}
