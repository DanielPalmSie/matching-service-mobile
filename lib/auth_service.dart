import 'dart:convert';

import 'package:http/http.dart' as http;

/// Simple API client responsible for talking to the backend auth endpoints.
/// Update [_defaultBaseUrl] to point to your server.
class AuthService {
  AuthService({http.Client? client, this.baseUrl = _defaultBaseUrl})
      : _client = client ?? http.Client();

  static const String _defaultBaseUrl = 'https://matchinghub.work';

  final http.Client _client;
  final String baseUrl;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token == null || token.isEmpty) {
        throw const AuthException('Invalid response from server.');
      }
      return AuthResult(token: token);
    }

    if (response.statusCode == 401) {
      throw const AuthException('Email or password is incorrect');
    }

    throw AuthException(_extractMessage(response) ?? 'Authentication failed.');
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      return;
    }

    throw AuthException(
      _extractMessage(response) ?? 'Registration failed. Please try again.',
    );
  }

  String? _extractMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['message'] ?? data['error']) as String?;
    } catch (_) {
      return null;
    }
  }

  Map<String, String> buildAuthHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}

class AuthResult {
  const AuthResult({required this.token});

  final String token;
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
