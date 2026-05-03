import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/api_result.dart';
import '../models/domain.dart';
import '../models/session.dart';

class AppState {
  const AppState({
    this.session,
    this.serverInfo,
    this.people = const [],
    this.events = const [],
    this.config,
    this.lastResult,
    this.isBusy = false,
    this.message,
  });

  final Session? session;
  final ServerInfo? serverInfo;
  final List<PersonSummary> people;
  final List<RecognitionEvent> events;
  final SystemConfig? config;
  final RecognitionResult? lastResult;
  final bool isBusy;
  final String? message;

  bool get isLoggedIn => session != null;

  AppState copyWith({
    Session? session,
    ServerInfo? serverInfo,
    List<PersonSummary>? people,
    List<RecognitionEvent>? events,
    SystemConfig? config,
    RecognitionResult? lastResult,
    bool? isBusy,
    String? message,
    bool clearMessage = false,
  }) {
    return AppState(
      session: session ?? this.session,
      serverInfo: serverInfo ?? this.serverInfo,
      people: people ?? this.people,
      events: events ?? this.events,
      config: config ?? this.config,
      lastResult: lastResult ?? this.lastResult,
      isBusy: isBusy ?? this.isBusy,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}

class AppController extends ValueNotifier<AppState> {
  AppController(this._api) : super(const AppState());

  final ApiClient _api;

  Future<void> loadServerInfo() async {
    final result = await _api.serverInfo(token: value.session?.token);
    value = result.when(
      ok: (info) => value.copyWith(serverInfo: info, clearMessage: true),
      error: (failure) => value.copyWith(message: failure.operatorMessage),
    );
  }

  Future<void> login(String userName, String password) async {
    value = value.copyWith(isBusy: true, clearMessage: true);
    final result = await _api.login(userName, password);
    value = result.when(
      ok: (session) => value.copyWith(session: session, isBusy: false),
      error: (failure) =>
          value.copyWith(isBusy: false, message: failure.operatorMessage),
    );
    if (value.isLoggedIn) await refreshAdminData();
  }

  Future<void> identifyImage({
    required String fileName,
    required List<int> bytes,
  }) async {
    final token = value.session?.token;
    if (token == null) return;
    value = value.copyWith(isBusy: true, clearMessage: true);
    final result = await _api.identify(
      token: token,
      fileName: fileName,
      bytes: bytes,
    );
    value = result.when(
      ok: (recognition) =>
          value.copyWith(lastResult: recognition, isBusy: false),
      error: (failure) =>
          value.copyWith(isBusy: false, message: failure.operatorMessage),
    );
  }

  Future<PersonSummary?> createPerson({
    required String displayName,
    String? employeeCode,
    String? jobTitle,
  }) async {
    final token = value.session?.token;
    if (token == null) return null;
    value = value.copyWith(isBusy: true, clearMessage: true);
    final result = await _api.createPerson(
      token: token,
      displayName: displayName,
      employeeCode: employeeCode,
      jobTitle: jobTitle,
    );
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

  Future<PersonSummary?> loadPerson(String personId) async {
    final token = value.session?.token;
    if (token == null) return null;
    value = value.copyWith(isBusy: true, clearMessage: true);
    final result = await _api.person(token, personId);
    return result.when(
      ok: (person) {
        value = value.copyWith(isBusy: false);
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

  Future<PersonSummary?> updatePerson({
    required String personId,
    required String displayName,
    String? employeeCode,
    String? jobTitle,
  }) async {
    final token = value.session?.token;
    if (token == null) return null;
    value = value.copyWith(isBusy: true, clearMessage: true);
    final result = await _api.updatePerson(
      token: token,
      personId: personId,
      displayName: displayName,
      employeeCode: employeeCode,
      jobTitle: jobTitle,
    );
    return result.when(
      ok: (person) {
        value = value.copyWith(
          people: [
            for (final item in value.people)
              if (item.id == person.id) person else item,
          ],
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

  Future<bool> deletePerson(String personId) async {
    final token = value.session?.token;
    if (token == null) return false;
    value = value.copyWith(isBusy: true, clearMessage: true);
    final result = await _api.deletePerson(token: token, personId: personId);
    return result.when(
      ok: (_) {
        value = value.copyWith(
          people: [
            for (final person in value.people)
              if (person.id != personId) person,
          ],
          isBusy: false,
        );
        return true;
      },
      error: (failure) {
        value = value.copyWith(
          isBusy: false,
          message: failure.operatorMessage,
        );
        return false;
      },
    );
  }

  Future<FaceTemplateSummary?> uploadEnrollmentSample({
    required String personId,
    required String fileName,
    required List<int> bytes,
    required String expectedPose,
  }) async {
    final token = value.session?.token;
    if (token == null) return null;
    value = value.copyWith(isBusy: true, clearMessage: true);
    final result = await _api.uploadEnrollmentSample(
      token: token,
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

  Future<void> refreshAdminData() async {
    final token = value.session?.token;
    if (token == null) return;
    final people = await _api.people(token);
    final events = await _api.events(token);
    final config = await _api.config(token);
    value = value.copyWith(
      people: people is ApiSuccess<List<PersonSummary>>
          ? people.value
          : value.people,
      events: events is ApiSuccess<List<RecognitionEvent>>
          ? events.value
          : value.events,
      config: config is ApiSuccess<SystemConfig> ? config.value : value.config,
    );
  }

  void logout() {
    value = const AppState();
  }

  void showMessage(String message) {
    value = value.copyWith(isBusy: false, message: message);
  }
}
