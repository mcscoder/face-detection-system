## Context Links

- Settings role gating and save affordance: [client/lib/screens/settings_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/settings_screen.dart:16)
- Enrollment create/start/cancel flow: [client/lib/screens/enrollment_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/enrollment_screen.dart:65)
- Face Check capture/result flow: [client/lib/screens/capture_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/capture_screen.dart:150)
- Shared banner styling: [client/lib/widgets/status_banner.dart](/home/mcs/Workspaces/face-detection-system/client/lib/widgets/status_banner.dart:16)

## Overview

- Priority: P2
- Status: pending
- Goal: bring settings, enrollment, face check, and banners into the same Apple-like light manager system without touching workflow logic.

## Key Insights

- Settings is already mostly presentational; role gating is the behavior boundary in [client/lib/screens/settings_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/settings_screen.dart:18).
- Enrollment has active camera/timer state and person creation in one file; visual edits must not disturb `_EnrollmentRunState`, timers, or controller calls in [client/lib/screens/enrollment_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/enrollment_screen.dart:98).
- Manager face check shares a file with public verify; only the non-public branch starting at [client/lib/screens/capture_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/capture_screen.dart:150) is in scope.

## Requirements

- Preserve headers `Settings`, `Enrollment`, `Face Check`.
- Keep settings admin-only behavior and disabled save state.
- Keep enrollment create/start/cancel flow and status messaging.
- Keep manager face check result behavior and leave public verify visuals alone.

## Architecture

- Data flow unchanged:
  - Settings reads config/session and emits no new writes.
  - Enrollment reads controller/session, writes through existing create/upload calls.
  - Face Check reads controller state and writes through existing identify call.
  - Status banners remain a shared presentation layer.

## Related Code Files

- Modify: `client/lib/screens/settings_screen.dart`
- Modify: `client/lib/screens/enrollment_screen.dart`
- Modify: `client/lib/screens/capture_screen.dart`
- Modify: `client/lib/widgets/status_banner.dart`
- Create: none
- Delete: none

## Implementation Steps

1. Restyle settings into grouped Apple-like forms/cards with clearer section spacing and preserved disabled states.
2. Restyle enrollment screen framing around the existing person form, camera stage, action panel, and banners; do not alter timer or upload code paths.
3. Restyle only the manager branch of `CaptureScreen` so `Face Check` matches the new shell while leaving `publicMode` output untouched.
4. Refine `StatusBanner` toward softer inset alert styling that still communicates success/warning/error/info clearly across manager screens.
5. Manual verify that settings role gating, enrollment progress, and face check result rendering behave the same as before.

## Todo List

- [ ] Redesign settings form grouping
- [ ] Redesign enrollment layout chrome only
- [ ] Redesign manager face-check layout chrome only
- [ ] Update shared banner styling
- [ ] Confirm no public verify changes

## Success Criteria

- Settings, Enrollment, and Face Check visually match the redesigned manager shell.
- Public verify flow remains visually and behaviorally unchanged.
- Enrollment and identify actions still trigger the same controller methods in the same places.

## Risk Assessment

- High: `CaptureScreen` serves both public and manager modes.
  - Mitigation: isolate edits to the non-public branch and re-check `publicMode` rendering path.
- High: enrollment timing/camera flow is sensitive to layout refactors.
  - Mitigation: avoid moving stateful logic; change wrappers, spacing, and card composition only.
- Medium: shared banner restyle may reduce contrast.
  - Mitigation: validate each tone against current messages and keep icon/text semantics.

## Security Considerations

- Preserve existing role and mode boundaries; no auth or transport changes.

## Next Steps

- Move to Phase 4 verification once all manager screens are restyled.
