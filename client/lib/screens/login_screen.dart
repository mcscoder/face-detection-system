import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import '../widgets/status_banner.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userName = TextEditingController(text: 'admin');
  final password = TextEditingController(text: 'password');

  @override
  void dispose() {
    userName.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AnimatedBuilder(
                animation: widget.controller,
                builder: (context, _) {
                  final state = widget.controller.value;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Face Detection',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(state.serverInfo?.status ?? 'Local API client'),
                      const SizedBox(height: 24),
                      TextField(
                        controller: userName,
                        decoration: const InputDecoration(
                          labelText: 'User name',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: password,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (state.message != null) ...[
                        StatusBanner(
                          label: state.message!,
                          tone: BannerTone.error,
                        ),
                        const SizedBox(height: 12),
                      ],
                      FilledButton.icon(
                        onPressed: state.isBusy
                            ? null
                            : () => widget.controller.login(
                                userName.text,
                                password.text,
                              ),
                        icon: const Icon(Icons.login),
                        label: Text(state.isBusy ? 'Signing in...' : 'Login'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
