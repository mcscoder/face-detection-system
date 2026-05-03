import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import 'capture_screen.dart';
import 'enrollment_screen.dart';
import 'events_screen.dart';
import 'login_screen.dart';
import 'people_screen.dart';
import 'settings_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.value;
        if (!state.isLoggedIn)
          return LoginScreen(controller: widget.controller);
        final screens = [
          CaptureScreen(controller: widget.controller),
          PeopleScreen(controller: widget.controller),
          EnrollmentScreen(controller: widget.controller),
          EventsScreen(controller: widget.controller),
          SettingsScreen(controller: widget.controller),
        ];
        return Scaffold(
          appBar: AppBar(
            title: Text(state.serverInfo?.name ?? 'Face Detection'),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: widget.controller.refreshAdminData,
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                tooltip: 'Logout',
                onPressed: widget.controller.logout,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: screens[index],
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (value) => setState(() => index = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.photo_camera),
                label: 'Capture',
              ),
              NavigationDestination(icon: Icon(Icons.people), label: 'People'),
              NavigationDestination(icon: Icon(Icons.badge), label: 'Enroll'),
              NavigationDestination(icon: Icon(Icons.history), label: 'Events'),
              NavigationDestination(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
