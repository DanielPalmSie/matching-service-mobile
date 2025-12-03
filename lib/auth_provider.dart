import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service);

  final AuthService _service;

  bool _initialized = false;
  bool _loading = false;
  String? _token;
  String _name = '';
  String? _errorMessage;
  bool _rememberMe = true;

  bool get initialized => _initialized;
  bool get isLoading => _loading;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  String get displayName => _name.isNotEmpty ? _name : 'User';
  String? get errorMessage => _errorMessage;
  bool get rememberMe => _rememberMe;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_PrefsKeys.token);
    _name = prefs.getString(_PrefsKeys.name) ?? '';
    _rememberMe = prefs.getBool(_PrefsKeys.rememberMe) ?? true;
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
    await _performAuth(
      () => _service.login(email: email, password: password),
      persistToken: remember,
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _performAuth(
      () => _service.register(name: name, email: email, password: password),
    );
  }

  Future<void> setRememberMe(bool value) async {
    _rememberMe = value;
    await _saveRememberPreference();
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_PrefsKeys.token);
    await prefs.remove(_PrefsKeys.name);
    _token = null;
    _name = '';
    notifyListeners();
  }

  Future<void> _performAuth(
    Future<AuthResult> Function() action, {
    bool persistToken = true,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final result = await action();
      _token = result.token;
      _name = result.name;
      final prefs = await SharedPreferences.getInstance();
      if (persistToken) {
        await prefs.setString(_PrefsKeys.token, _token!);
        await prefs.setString(_PrefsKeys.name, _name);
      } else {
        await prefs.remove(_PrefsKeys.token);
        await prefs.remove(_PrefsKeys.name);
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
  static const name = 'auth_name';
  static const rememberMe = 'remember_me';
}
