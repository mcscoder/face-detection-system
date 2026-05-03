import 'package:flutter/material.dart';

import 'api/api_client.dart';
import 'api/api_transport.dart';
import 'screens/shell_screen.dart';
import 'state/app_controller.dart';

class FaceDetectionClientApp extends StatefulWidget {
  const FaceDetectionClientApp({super.key, required this.transport});

  final ApiTransport transport;

  @override
  State<FaceDetectionClientApp> createState() => _FaceDetectionClientAppState();
}

class _FaceDetectionClientAppState extends State<FaceDetectionClientApp> {
  late final AppController controller;

  @override
  void initState() {
    super.initState();
    controller = AppController(ApiClient(widget.transport))..loadServerInfo();
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
          seedColor: const Color(0xff2563eb),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.standard,
      ),
      home: ShellScreen(controller: controller),
    );
  }
}
