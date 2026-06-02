## Context Links

- Client app/theme entry: [client/lib/app.dart](/home/mcs/Workspaces/face-detection-system/client/lib/app.dart:41)
- Manager shell routing: [client/lib/screens/shell_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/shell_screen.dart:77)
- Manager capture shared-file risk: [client/lib/screens/capture_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/capture_screen.dart:120)

## Overview

- Priority: P1
- Status: pending
- Goal: prove the redesign is presentation-only and leave a clean rollback path.

## Key Insights

- Acceptance requires compile/analyze success; repo README states client analyze/tests currently pass, so plan should preserve that bar.
- No new tests required, but existing tests are still the cheapest regression detector for nav labels and screen text.

## Requirements

- Run verification in `client/`.
- Confirm no controller/API flow changes.
- Confirm public mode behavior unchanged.
- Keep rollback atomic by phase/file ownership.

## Architecture

- Verification input: modified Flutter UI files only.
- Checks: analyzer, test suite, manual manager/public smoke pass.
- Output: ship/no-ship decision plus exact files to revert if needed.

## Related Code Files

- Modify: none
- Verify: `client/lib/app.dart`, `client/lib/screens/shell_screen.dart`, `client/lib/screens/manager_dashboard_screen.dart`, `client/lib/screens/people_screen.dart`, `client/lib/screens/events_screen.dart`, `client/lib/screens/settings_screen.dart`, `client/lib/screens/enrollment_screen.dart`, `client/lib/screens/capture_screen.dart`, `client/lib/widgets/status_banner.dart`

## Implementation Steps

1. Run `flutter analyze` in `client/`.
2. Run `flutter test` in `client/`.
3. Manual smoke:
   - public home still opens verify/enroll/login
   - manager login still opens `Manager Console`
   - all six manager destinations open
   - dashboard quick actions route correctly
   - settings role gating still visible
   - enrollment create/start/cancel still responds
   - face check capture/result still responds
4. If regressions appear, revert the owning phase files only and rerun analyze/test.

## Todo List

- [ ] Analyze passes
- [ ] Existing client tests pass
- [ ] Manual public-mode smoke passes
- [ ] Manual manager-mode smoke passes
- [ ] Rollback instructions documented in final handoff

## Success Criteria

- Analyzer clean.
- Tests green.
- No public-mode visual or behavior drift.
- No route or callback drift inside manager mode.

## Risk Assessment

- High: accidental public-mode change via shared theme or shared capture file.
  - Mitigation: explicit public smoke and branch-isolated review.
- Medium: label adjustments break tests.
  - Mitigation: prefer preserving current nav strings unless failing tests prove they are free to change.

## Security Considerations

- None; verification only.

## Next Steps

- Ready for implementation once approved.
