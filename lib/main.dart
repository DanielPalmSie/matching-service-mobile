import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_provider.dart';
import 'auth_service.dart';
import 'features/auth/presentation/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthProvider is created at the top level so that the whole app can react
    // when authentication state changes.
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(AuthService())..initialize(),
      child: MaterialApp(
        title: 'Matching App',
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: const AuthGate(),
      ),
    );
  }
}

/// Decides what to show on app start: authentication screen or the logged in home.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.initialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (auth.isAuthenticated) {
          return const HomeScreen();
        }

        // Shows the redesigned login screen; successful auth causes AuthGate
        // to rebuild and reveal the home screen.
        return const LoginScreen();
      },
    );
  }
}

class HomeScreen extends StatelessWidget {d
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: auth.logout,
            tooltip: 'Logout',
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${auth.displayName}!'),
            const SizedBox(height: 12),
            const Text(
              'This screen is shown after successful login or registration.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final auth = context.read<AuthProvider>();
      auth.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: auth.logout,
            tooltip: 'Logout',
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${auth.displayName}!'),
            const SizedBox(height: 12),
            const Text(
              'This screen is shown after successful login or registration.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

String? _validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  final emailRegEx = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!emailRegEx.hasMatch(value)) {
    return 'Enter a valid email';
  }
  return null;
}

String? _validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}
