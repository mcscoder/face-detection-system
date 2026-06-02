import 'package:flutter/material.dart';

import 'api/api_client.dart';
import 'api/api_provider.dart';
import 'api/api_transport.dart';
import 'api/live_api_transport.dart';
import 'screens/shell_screen.dart';
import 'state/app_controller.dart';
import 'widgets/manager_colors.dart';

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
    final baseTextTheme = ThemeData.light().textTheme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Face Detection',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: managerBlue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.standard,
        scaffoldBackgroundColor: managerBackground,
        dividerColor: managerBorder,
        textTheme: baseTextTheme.copyWith(
          headlineMedium: baseTextTheme.headlineMedium?.copyWith(
            color: managerText,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
          headlineSmall: baseTextTheme.headlineSmall?.copyWith(
            color: managerText,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
          titleLarge: baseTextTheme.titleLarge?.copyWith(
            color: managerText,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
          titleMedium: baseTextTheme.titleMedium?.copyWith(
            color: managerText,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
          bodyMedium: baseTextTheme.bodyMedium?.copyWith(
            color: managerMutedText,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: managerBackground,
          foregroundColor: managerText,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: managerSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: managerBorder),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: managerSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: managerBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: managerBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: managerBlue, width: 1.4),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(64, 52),
            backgroundColor: managerBlue,
            foregroundColor: Colors.white,
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
