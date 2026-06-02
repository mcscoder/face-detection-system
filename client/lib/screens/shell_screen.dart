import 'package:flutter/material.dart';

import '../api/api_provider.dart';
import '../state/app_controller.dart';
import 'capture_screen.dart';
import 'enrollment_screen.dart';
import 'events_screen.dart';
import 'login_screen.dart';
import 'manager_dashboard_screen.dart';
import 'people_screen.dart';
import 'settings_screen.dart';
import 'user_enrollment_screen.dart';
import 'user_home_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({
    super.key,
    required this.controller,
    this.selectedApiProvider,
    this.apiProviders,
    this.onApiProviderChanged,
  });

  final AppController controller;
  final ApiProviderOption? selectedApiProvider;
  final List<ApiProviderOption>? apiProviders;
  final ValueChanged<ApiProviderOption>? onApiProviderChanged;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int index = 0;
  bool showManagerLogin = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.value;
        if (!state.isLoggedIn) {
          final apiProviders = widget.apiProviders ?? apiProviderOptions;
          if (showManagerLogin) {
            return LoginScreen(
              controller: widget.controller,
              onBack: () => setState(() => showManagerLogin = false),
            );
          }
          return UserHomeScreen(
            onVerifyFace: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CaptureScreen(
                    controller: widget.controller,
                    publicMode: true,
                  ),
                ),
              );
            },
            onEnrollFace: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      UserEnrollmentScreen(controller: widget.controller),
                ),
              );
            },
            onManagerLogin: () => setState(() => showManagerLogin = true),
            selectedApiProvider:
                widget.selectedApiProvider ?? apiProviders.first,
            apiProviders: apiProviders,
            onApiProviderChanged: widget.onApiProviderChanged ?? (_) {},
          );
        }
        final screens = [
          ManagerDashboardScreen(
            controller: widget.controller,
            onOpenPeople: () => setState(() => index = 1),
            onOpenEnroll: () => setState(() => index = 2),
            onOpenVerify: () => setState(() => index = 3),
            onOpenEvents: () => setState(() => index = 4),
          ),
          PeopleScreen(
            controller: widget.controller,
            onAddPerson: () => setState(() => index = 2),
          ),
          EnrollmentScreen(controller: widget.controller),
          CaptureScreen(controller: widget.controller),
          EventsScreen(controller: widget.controller),
          SettingsScreen(controller: widget.controller),
        ];
        return Scaffold(
          backgroundColor: const Color(0xffeef2f6),
          body: SafeArea(
            child: Row(
              children: [
                NavigationRail(
                  backgroundColor: Colors.white,
                  selectedIconTheme: const IconThemeData(
                    color: Color(0xff0f766e),
                  ),
                  selectedLabelTextStyle: const TextStyle(
                    color: Color(0xff0f766e),
                    fontWeight: FontWeight.w800,
                  ),
                  labelType: NavigationRailLabelType.all,
                  selectedIndex: index,
                  onDestinationSelected: (value) {
                    setState(() => index = value);
                  },
                  leading: const Padding(
                    padding: EdgeInsets.only(top: 12, bottom: 16),
                    child: Icon(Icons.admin_panel_settings),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people_outline),
                      selectedIcon: Icon(Icons.people),
                      label: Text('People'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_add_alt),
                      selectedIcon: Icon(Icons.badge),
                      label: Text('Enroll'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.camera_alt_outlined),
                      selectedIcon: Icon(Icons.photo_camera),
                      label: Text('Verify'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.history),
                      selectedIcon: Icon(Icons.receipt_long),
                      label: Text('Events'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Column(
                    children: [
                      _ManagerCommandBar(
                        status: state.serverInfo?.status ?? 'local',
                        onRefresh: widget.controller.refreshAdminData,
                        onLogout: () {
                          setState(() {
                            index = 0;
                            showManagerLogin = false;
                          });
                          widget.controller.logout();
                        },
                      ),
                      Expanded(child: screens[index]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ManagerCommandBar extends StatelessWidget {
  const _ManagerCommandBar({
    required this.status,
    required this.onRefresh,
    required this.onLogout,
  });

  final String status;
  final VoidCallback onRefresh;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xffe2e8f0))),
      ),
      child: Row(
        children: [
          Text(
            'Manager Console',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xffecfdf5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xffbbf7d0)),
            ),
            child: Text(
              status,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xff047857),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Refresh',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
