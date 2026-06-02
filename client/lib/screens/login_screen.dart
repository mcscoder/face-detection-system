import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import '../widgets/status_banner.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller, this.onBack});

  final AppController controller;
  final VoidCallback? onBack;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userName = TextEditingController(text: 'admin');
  final password = TextEditingController(text: 'admin');

  @override
  void dispose() {
    userName.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeef2f6),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xffeef2f6),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AnimatedBuilder(
                  animation: widget.controller,
                  builder: (context, _) {
                    final state = widget.controller.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.onBack != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              tooltip: 'Back',
                              onPressed: widget.onBack,
                              icon: const Icon(Icons.arrow_back),
                            ),
                          ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xffdbe3ea)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffecfdf5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.admin_panel_settings,
                                      color: Color(0xff047857),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Manager Console',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                              ),
                                        ),
                                        Text(
                                          state.serverInfo?.status ??
                                              'Local API client',
                                          style: const TextStyle(
                                            color: Color(0xff64748b),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              TextField(
                                controller: userName,
                                decoration: const InputDecoration(
                                  labelText: 'User name',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: password,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.lock_outline),
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
                                label: Text(
                                  state.isBusy ? 'Signing in...' : 'Login',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Protected access for user management.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xff64748b),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                      ],
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
}
