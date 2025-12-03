import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth_provider.dart';
import 'register_screen.dart';
import 'validation.dart';
import 'widgets/frosted_card.dart';
import 'widgets/gradient_button.dart';
import 'widgets/icon_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final remember = context.read<AuthProvider>().rememberMe;
    if (_rememberMe != remember) {
      _rememberMe = remember;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F1624), Color(0xFF241B4D), Color(0xFF1C1D3B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FrostedCard(
                      child: Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircleAvatar(
                                radius: 36,
                                backgroundColor: Colors.white24,
                                child: Icon(Icons.person_outline, color: Colors.white70, size: 40),
                              ),
                              const SizedBox(height: 20),
                              Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    IconInputField(
                                      controller: _emailController,
                                      label: 'Email',
                                      icon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: validateEmail,
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 14),
                                    IconInputField(
                                      controller: _passwordController,
                                      label: 'Password',
                                      icon: Icons.lock_outline,
                                      obscureText: true,
                                      validator: validatePassword,
                                      textInputAction: TextInputAction.done,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) {
                                            setState(() => _rememberMe = value ?? false);
                                            context.read<AuthProvider>().setRememberMe(value ?? false);
                                          },
                                          activeColor: colorScheme.secondary,
                                          checkColor: Colors.white,
                                        ),
                                        const Text(
                                          'Remember me',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        const Spacer(),
                                        TextButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Forgot password tapped'),
                                              ),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.white70,
                                          ),
                                          child: const Text('Forgot Password?'),
                                        ),
                                      ],
                                    ),
                                    if (auth.errorMessage != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          auth.errorMessage!,
                                          style: const TextStyle(color: Colors.redAccent),
                                        ),
                                      ),
                                    AppGradientButton(
                                      label: 'LOGIN',
                                      onPressed: auth.isLoading ? null : () => _submit(context),
                                      loading: auth.isLoading,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () => _openRegister(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Register now'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      remember: _rememberMe,
    );
  }

  void _openRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }
}
