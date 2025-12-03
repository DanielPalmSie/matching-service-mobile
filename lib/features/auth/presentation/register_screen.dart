import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth_provider.dart';
import 'validation.dart';
import 'widgets/frosted_card.dart';
import 'widgets/gradient_button.dart';
import 'widgets/icon_input_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle:
            Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
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
                constraints: const BoxConstraints(maxWidth: 500),
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return FrostedCard(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Register',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 18),
                            IconInputField(
                              controller: _nameController,
                              label: 'Name',
                              icon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Name is required';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 12),
                            IconInputField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: validateEmail,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 12),
                            IconInputField(
                              controller: _passwordController,
                              label: 'Password',
                              icon: Icons.lock_outline,
                              obscureText: true,
                              validator: validatePassword,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 12),
                            IconInputField(
                              controller: _confirmController,
                              label: 'Confirm Password',
                              icon: Icons.lock_outline,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.done,
                            ),
                            const SizedBox(height: 14),
                            if (auth.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  auth.errorMessage!,
                                  style: const TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            AppGradientButton(
                              label: 'Register',
                              onPressed: auth.isLoading ? null : () => _submit(context),
                              loading: auth.isLoading,
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.secondary,
                                  colorScheme.primary,
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
    await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (auth.isAuthenticated) {
      Navigator.of(context).pop();
    }
  }
}
