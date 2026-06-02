# Phase 02 Client Public API State

## Context Links

- API client: `client/lib/api/api_client.dart`
- Demo transport: `client/lib/api/api_transport.dart`
- App controller: `client/lib/state/app_controller.dart`
- Controller tests: `client/test/app_controller_test.dart`

## Overview

- Priority: high
- Current status: planned
- Add client methods for public user create, verify, and enrollment sample upload with no session token.

## Key Insights

- Existing `AppController.identifyImage`, `createPerson`, and `uploadEnrollmentSample` return early when no session token exists.
- Public user mode needs separate methods so manager behavior stays unchanged.

## Requirements

- Public verify works when `AppState.session == null`.
- Public enroll creates person when `AppState.session == null`.
- Public enrollment sample uploads `expected_pose`.
- Demo transport supports new public paths for tests and offline demo mode.

## Architecture

`ApiClient` gets public user methods that call `/v1/user/...` without token. `AppController` gets corresponding public methods that update `isBusy`, `message`, and `lastResult` like existing manager methods.

## Related Code Files

- Modify: `client/lib/api/api_client.dart`
- Modify: `client/lib/api/api_transport.dart`
- Modify: `client/lib/state/app_controller.dart`
- Test: `client/test/app_controller_test.dart`

## Implementation Steps

- [ ] **Step 1: Write controller test for public methods**

Append to `client/test/app_controller_test.dart`:

```dart
  test('public user methods work without login', () async {
    final controller = AppController(const ApiClient(DemoApiTransport()));

    final person = await controller.createUserPerson(displayName: 'Public User');
    final template = await controller.uploadUserEnrollmentSample(
      personId: person!.id,
      fileName: 'sample.jpg',
      bytes: const [1, 2, 3],
      expectedPose: 'face_forward',
    );
    await controller.identifyUserImage(
      fileName: 'probe.jpg',
      bytes: const [4, 5, 6],
    );

    expect(controller.value.isLoggedIn, isFalse);
    expect(person.displayName, 'New Person');
    expect(template?.isActive, isTrue);
    expect(controller.value.lastResult?.eventId, 'evt-demo');

    controller.dispose();
  });
```

- [ ] **Step 2: Run controller test to verify it fails**

Run from `client/`:

```bash
flutter test test/app_controller_test.dart
```

Expected: FAIL because `createUserPerson` is not defined.

- [ ] **Step 3: Add public methods to ApiClient**

Add to `client/lib/api/api_client.dart` after `createPerson`:

```dart
  Future<ApiResult<PersonSummary>> createUserPerson({
    required String displayName,
  }) async {
    return _mapObject(
      await _transport.postJson(
        '/v1/user/people',
        {
          'display_name': displayName,
          'extra_data': <String, Object?>{},
        },
      ),
      PersonSummary.fromJson,
    );
  }
```

Add after `uploadEnrollmentSample`:

```dart
  Future<ApiResult<FaceTemplateSummary>> uploadUserEnrollmentSample({
    required String personId,
    required String fileName,
    required List<int> bytes,
    required String expectedPose,
  }) async {
    return _mapObject(
      await _transport.postMultipart(
        '/v1/user/faces/$personId/samples',
        fileField: 'file',
        fileName: fileName,
        bytes: bytes,
        fields: {'expected_pose': expectedPose},
      ),
      FaceTemplateSummary.fromJson,
    );
  }
```

Add after `identify`:

```dart
  Future<ApiResult<RecognitionResult>> identifyUser({
    required String fileName,
    required List<int> bytes,
  }) async {
    return _mapObject(
      await _transport.postMultipart(
        '/v1/user/recognitions/identify',
        fileField: 'file',
        fileName: fileName,
        bytes: bytes,
      ),
      RecognitionResult.fromJson,
    );
  }
```

- [ ] **Step 4: Add public demo transport paths**

Modify `client/lib/api/api_transport.dart`.

Change `postJson` switch case:

```dart
      '/v1/people' || '/v1/user/people' => const ApiResponse(
          statusCode: 201,
          body: {
            'id': 'p-1002',
            'display_name': 'New Person',
            'access_status': 'active',
            'extra_data': <String, Object?>{},
          },
        ),
```

Change face sample condition:

```dart
    if (path.contains('/v1/faces/') || path.contains('/v1/user/faces/')) {
```

Change identify condition:

```dart
    if (path == '/v1/recognitions/identify' ||
        path == '/v1/user/recognitions/identify') {
```

- [ ] **Step 5: Add public methods to AppController**

Add to `client/lib/state/app_controller.dart` after `identifyImage`:

```dart
  Future<void> identifyUserImage({
    required String fileName,
    required List<int> bytes,
  }) async {
    value = value.copyWith(isBusy: true, clearMessage: true);
    final result = await _api.identifyUser(fileName: fileName, bytes: bytes);
    value = result.when(
      ok: (recognition) =>
          value.copyWith(lastResult: recognition, isBusy: false),
      error: (failure) =>
          value.copyWith(isBusy: false, message: failure.operatorMessage),
    );
  }
```

Add after `createPerson`:

```dart
  Future<PersonSummary?> createUserPerson({
    required String displayName,
  }) async {
    value = value.copyWith(isBusy: true, clearMessage: true);
    final result = await _api.createUserPerson(displayName: displayName);
    return result.when(
      ok: (person) {
        value = value.copyWith(
          people: [...value.people, person],
          isBusy: false,
        );
        return person;
      },
      error: (failure) {
        value = value.copyWith(
          isBusy: false,
          message: failure.operatorMessage,
        );
        return null;
      },
    );
  }
```

Add after `uploadEnrollmentSample`:

```dart
  Future<FaceTemplateSummary?> uploadUserEnrollmentSample({
    required String personId,
    required String fileName,
    required List<int> bytes,
    required String expectedPose,
  }) async {
    value = value.copyWith(isBusy: true, clearMessage: true);
    final result = await _api.uploadUserEnrollmentSample(
      personId: personId,
      fileName: fileName,
      bytes: bytes,
      expectedPose: expectedPose,
    );
    return result.when(
      ok: (template) {
        value = value.copyWith(isBusy: false);
        return template;
      },
      error: (failure) {
        value = value.copyWith(
          isBusy: false,
          message: failure.operatorMessage,
        );
        return null;
      },
    );
  }
```

- [ ] **Step 6: Run controller test to verify it passes**

Run from `client/`:

```bash
flutter test test/app_controller_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit phase**

```bash
git add client/lib/api/api_client.dart client/lib/api/api_transport.dart client/lib/state/app_controller.dart client/test/app_controller_test.dart
git commit -m "feat: add public user client state"
```

## Success Criteria

- Public controller methods work with no session.
- Existing manager controller methods still require a session token.

## Risk Assessment

- `AppController` is already over 200 lines. Keep changes surgical in this phase, then avoid adding unrelated state.

## Security Considerations

- Public methods do not send bearer token.
- Manager methods keep bearer token.

## Next Steps

- Continue with Phase 03 user shell and public verify UI.

## Unresolved Questions

None.
