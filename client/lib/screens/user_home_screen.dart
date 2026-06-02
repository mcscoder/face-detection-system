import 'package:flutter/material.dart';

import '../api/api_provider.dart';
import '../widgets/api_provider_dropdown.dart';
import '../widgets/face_oval_guide.dart';
import '../widgets/user_home_demo_badge.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({
    super.key,
    required this.onVerifyFace,
    required this.onEnrollFace,
    required this.onManagerLogin,
    required this.selectedApiProvider,
    required this.apiProviders,
    required this.onApiProviderChanged,
  });

  final VoidCallback onVerifyFace;
  final VoidCallback onEnrollFace;
  final VoidCallback onManagerLogin;
  final ApiProviderOption selectedApiProvider;
  final List<ApiProviderOption> apiProviders;
  final ValueChanged<ApiProviderOption> onApiProviderChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff000000), Color(0xff101010), Color(0xff000000)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const UserHomeDemoBadge(),
                        const Spacer(),
                        ApiProviderDropdown(
                          selectedProvider: selectedApiProvider,
                          providers: apiProviders,
                          onChanged: onApiProviderChanged,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Manager',
                          onPressed: onManagerLogin,
                          color: Colors.white,
                          style: IconButton.styleFrom(
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.08),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          icon: const Icon(Icons.admin_panel_settings),
                        ),
                      ],
                    ),
                    const Spacer(flex: 2),
                    const Center(
                      child: SizedBox(
                        width: 180,
                        height: 240,
                        child: FaceOvalGuide(
                          color: Colors.white,
                          accentColor: Color(0xff0a84ff),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Face Detection Demo',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Look at the camera',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const Spacer(flex: 3),
                    _UserActionCard(
                      icon: Icons.center_focus_strong,
                      label: 'Verify Face',
                      onTap: onVerifyFace,
                      emphasized: true,
                    ),
                    const SizedBox(height: 12),
                    _UserActionCard(
                      icon: Icons.person_add_alt_1,
                      label: 'Enroll Face',
                      onTap: onEnrollFace,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserActionCard extends StatelessWidget {
  const _UserActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final background =
        emphasized ? Colors.white : Colors.white.withValues(alpha: 0.08);
    final foreground = emphasized ? Colors.black : Colors.white;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        border: Border.all(
          color:
              emphasized ? Colors.white : Colors.white.withValues(alpha: 0.16),
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: emphasized
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Row(
            children: [
              Icon(icon, size: 30, color: foreground),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Icon(Icons.chevron_right, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}
