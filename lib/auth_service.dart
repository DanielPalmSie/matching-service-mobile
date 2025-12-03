import 'dart:convert';

import 'package:http/http.dart' as http;

/// Simple API client responsible for talking to the backend auth endpoints.
/// Update [_defaultBaseUrl] to point to your server.
class AuthService {
  AuthService({http.Client? client, this.baseUrl = _defaultBaseUrl})
      : _client = client ?? http.Client();

  static const String _defaultBaseUrl = 'https://example.com/api';

  final http.Client _client;
  final String baseUrl;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return _parseResponse(response);
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    return _parseResponse(response);
  }

  AuthResult _parseResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['token'] as String?;
      final name = data['name'] as String?;
      if (token == null || token.isEmpty) {
        throw const AuthException('Invalid response from server.');
      }
      return AuthResult(token: token, name: name ?? '');
    } else {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final message = data['message'] as String? ?? 'Authentication failed.';
        throw AuthException(message);
      } catch (_) {
        throw const AuthException('Authentication failed.');
      }
    }
  }
}

class AuthResult {
  const AuthResult({required this.token, required this.name});

  final String token;
  final String name;
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
