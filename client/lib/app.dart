import 'package:flutter/material.dart';

import 'api/api_client.dart';
import 'api/api_provider.dart';
import 'api/api_transport.dart';
import 'api/live_api_transport.dart';
import 'screens/shell_screen.dart';
import 'state/app_controller.dart';

class FaceDetectionClientApp extends StatefulWidget {
  const FaceDetectionClientApp({
    super.key,
    required this.initialApiProvider,
  });

  final ApiProviderOption initialApiProvider;

  @override
  State<FaceDetectionClientApp> createState() => _FaceDetectionClientAppState();
}

class _FaceDetectionClientAppState extends State<FaceDetectionClientApp> {
  late ApiProviderOption selectedApiProvider;
  late AppController controller;

  @override
  void initState() {
    super.initState();
    selectedApiProvider = widget.initialApiProvider;
    controller = _createController(selectedApiProvider)..loadServerInfo();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Face Detection',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff0a84ff),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.standard,
        scaffoldBackgroundColor: const Color(0xfff5f7fb),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Color(0xfff5f7fb),
          foregroundColor: Color(0xff111827),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xffe5e7eb)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xffd1d5db)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xffd1d5db)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xff0a84ff), width: 1.4),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(64, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(64, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: ShellScreen(
        controller: controller,
        selectedApiProvider: selectedApiProvider,
        apiProviders: apiProviderOptions,
        onApiProviderChanged: _changeApiProvider,
      ),
    );
  }

  AppController _createController(ApiProviderOption provider) {
    final ApiTransport transport = createLiveApiTransport(provider.baseUrl);
    return AppController(ApiClient(transport));
  }

  void _changeApiProvider(ApiProviderOption provider) {
    if (provider == selectedApiProvider) return;
    controller.dispose();
    setState(() {
      selectedApiProvider = provider;
      controller = _createController(provider)..loadServerInfo();
    });
  }
}
