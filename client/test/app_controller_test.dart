import 'package:face_detection_client/api/api_client.dart';
import 'package:face_detection_client/api/api_transport.dart';
import 'package:face_detection_client/state/app_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('login stores session and loads demo admin data', () async {
    final controller = AppController(const ApiClient(DemoApiTransport()));

    await controller.login('admin', 'password');

    expect(controller.value.isLoggedIn, isTrue);
    expect(controller.value.people, isNotEmpty);
    expect(controller.value.config?.retentionDays, 30);

    controller.dispose();
  });
}
