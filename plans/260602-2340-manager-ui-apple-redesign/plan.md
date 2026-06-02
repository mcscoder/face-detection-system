---
title: "Apple-Inspired Manager UI Redesign"
description: "Concise implementation plan for a light Apple-like redesign of the Flutter manager console UI."
status: pending
priority: P2
effort: 10h
branch: main
tags: [flutter, ui, manager-console, redesign]
created: 2026-06-02
---

# Apple-Inspired Manager UI Redesign

- Scope: manager UI only after login; public user mode stays unchanged per [client/lib/screens/shell_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/shell_screen.dart:43).
- Behavior lock: keep current controller calls, screen destinations, and API/controller flows wired from [client/lib/screens/shell_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/shell_screen.dart:77), [client/lib/screens/enrollment_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/enrollment_screen.dart:65), and [client/lib/screens/capture_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/capture_screen.dart:84).
- Label lock: preserve user-visible labels where tests may depend on them: `Manager Console`, `Dashboard`, `People`, `Recent Activity`, `Settings`, `Enrollment`, `Face Check`, `Events`.

## Phases

1. [Phase 1: Theme + Shell](/home/mcs/Workspaces/face-detection-system/plans/260602-2340-manager-ui-apple-redesign/phase-01-theme-and-shell.md)
2. [Phase 2: Dashboard + Lists](/home/mcs/Workspaces/face-detection-system/plans/260602-2340-manager-ui-apple-redesign/phase-02-dashboard-and-lists.md)
3. [Phase 3: Settings + Action Screens](/home/mcs/Workspaces/face-detection-system/plans/260602-2340-manager-ui-apple-redesign/phase-03-settings-and-action-screens.md)
4. [Phase 4: Verification + Rollback Gate](/home/mcs/Workspaces/face-detection-system/plans/260602-2340-manager-ui-apple-redesign/phase-04-verification-and-rollback.md)

## Dependency Graph

- Phase 1 blocks Phases 2 and 3 because shell spacing, colors, and nav structure originate in [client/lib/app.dart](/home/mcs/Workspaces/face-detection-system/client/lib/app.dart:41) and [client/lib/screens/shell_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/shell_screen.dart:94).
- Phase 2 can run after Phase 1; it owns dashboard, people, and events surfaces.
- Phase 3 can run after Phase 1; it owns settings, enrollment, face check, and shared status styling.
- Phase 4 runs last; it verifies no behavior regressions and that analyze/build gates pass.

## File Ownership

- Phase 1: `client/lib/app.dart`, `client/lib/screens/shell_screen.dart`
- Phase 2: `client/lib/screens/manager_dashboard_screen.dart`, `client/lib/screens/people_screen.dart`, `client/lib/screens/events_screen.dart`
- Phase 3: `client/lib/screens/settings_screen.dart`, `client/lib/screens/enrollment_screen.dart`, `client/lib/screens/capture_screen.dart`, `client/lib/widgets/status_banner.dart`
- Phase 4: no product-code ownership; verification only

## Test Matrix

- Static: `flutter analyze` in `client/`
- Compile/smoke: `flutter test` in `client/` to catch text/nav regressions already covered by existing tests
- Manual manager QA:
  - login -> `Manager Console`
  - switch all nav destinations
  - dashboard quick actions open same destinations
  - people search/open still works
  - events filter chips still filter
  - settings role gating still disables save for non-admin
  - enrollment flow UI only changed; create/start/cancel behavior unchanged
  - face check UI only changed; capture/result behavior unchanged

## Success Criteria

- Authenticated manager shell renders as a clean light Apple-like console.
- Navigation remains mapped to the same six destinations.
- Public mode code path remains untouched.
- No API/controller method signatures or call order changes.
- `flutter analyze` passes.
- Existing client tests pass.

## Rollback

- Revert by phase in reverse order.
- If Phase 2 or 3 styling causes regressions, keep Phase 1 shell/theme only.
- If Phase 1 shell causes layout or label regressions, revert `client/lib/app.dart` and `client/lib/screens/shell_screen.dart` together.

## Unresolved Questions

- None.
