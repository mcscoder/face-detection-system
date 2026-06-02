import 'package:flutter/material.dart';

import '../api/api_provider.dart';
import '../state/app_controller.dart';
import '../widgets/manager_shell_chrome.dart';
import '../widgets/manager_shell_navigation.dart';
import '../widgets/manager_ui.dart';
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
        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 620;
            return Scaffold(
              backgroundColor: managerBackground,
              body: SafeArea(
                child: compact
                    ? Column(
                        children: [
                          _CommandBar(state.serverInfo?.status ?? 'local'),
                          Expanded(child: screens[index]),
                          ManagerBottomNavigation(
                            selectedIndex: index,
                            onDestinationSelected: (value) {
                              setState(() => index = value);
                            },
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          ManagerSidebar(
                            selectedIndex: index,
                            onDestinationSelected: (value) {
                              setState(() => index = value);
                            },
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                _CommandBar(
                                  state.serverInfo?.status ?? 'local',
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
      },
    );
  }

  Widget _CommandBar(String status) {
    return ManagerCommandBar(
      status: status,
      onRefresh: widget.controller.refreshAdminData,
      onLogout: () {
        setState(() {
          index = 0;
          showManagerLogin = false;
        });
        widget.controller.logout();
      },
    );
  }
}
