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

  test('creates person and uploads enrollment sample', () async {
    final controller = AppController(const ApiClient(DemoApiTransport()));

    await controller.login('admin', 'password');
    final person = await controller.createPerson(displayName: 'New Person');
    final template = await controller.uploadEnrollmentSample(
      personId: person!.id,
      fileName: 'sample.jpg',
      bytes: const [1, 2, 3],
      expectedPose: 'face_forward',
    );

    expect(person.id, 'p-1002');
    expect(template?.isActive, isTrue);
    expect(template?.qualityScore, 0.87);

    controller.dispose();
  });

  test('loads, updates, and deletes person records', () async {
    final controller = AppController(const ApiClient(DemoApiTransport()));

    await controller.login('admin', 'password');
    final person = await controller.loadPerson('p-1001');
    final updated = await controller.updatePerson(
      personId: 'p-1001',
      displayName: 'Updated Person',
      employeeCode: 'EMP-2',
      jobTitle: 'Supervisor',
    );
    final removed = await controller.deletePerson('p-1001');

    expect(person?.id, 'p-1001');
    expect(updated?.displayName, 'Updated Person');
    expect(controller.value.people, isEmpty);
    expect(removed, isTrue);

    controller.dispose();
  });
}
