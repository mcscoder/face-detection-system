## Context Links

- Theme seed and manager app shell entry: [client/lib/app.dart](/home/mcs/Workspaces/face-detection-system/client/lib/app.dart:41)
- Auth split and manager shell composition: [client/lib/screens/shell_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/shell_screen.dart:43)
- Current command bar title/status/refresh/logout: [client/lib/screens/shell_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/shell_screen.dart:154)

## Overview

- Priority: P2
- Status: pending
- Goal: replace the current rail-heavy manager shell with a lighter Apple-like console while keeping the same authenticated routing and actions.

## Key Insights

- Public mode and manager mode branch in one file; manager-only edits must stay below the login gate in [client/lib/screens/shell_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/shell_screen.dart:43).
- Manager destination mapping is index-based in [client/lib/screens/shell_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/shell_screen.dart:77); nav order cannot drift without breaking quick actions.
- Current theme tokens are generic Material 3 light tokens in [client/lib/app.dart](/home/mcs/Workspaces/face-detection-system/client/lib/app.dart:44); an Apple-like result should come from tighter neutrals, spacing, rounded surfaces, softer borders, and restrained blue accents, not behavior changes.

## Requirements

- Keep `Manager Console` visible in the shell.
- Keep six manager destinations and existing destination behavior.
- Preserve refresh/logout actions.
- Keep layout responsive for tablet/desktop widths already supported by Flutter.

## Architecture

- Data flow stays unchanged: `FaceDetectionClientApp` -> `ShellScreen` -> `screens[index]`.
- Visual changes enter through theme tokens in `app.dart`, then shell container/nav/command bar layout in `shell_screen.dart`.
- Output stays the same widgets/actions: refresh calls `refreshAdminData`, logout calls `logout`, quick nav still updates `index`.

## Related Code Files

- Modify: `client/lib/app.dart`
- Modify: `client/lib/screens/shell_screen.dart`
- Create: none
- Delete: none

## Implementation Steps

1. Tighten `ThemeData` in `app.dart` around Apple-like light neutrals, larger corner radii, subtler outlines, and calmer typography.
2. Redesign the manager shell container in `shell_screen.dart` into a softer split layout with a refined navigation column and top command bar.
3. Keep destination list/order stable while renaming visible manager nav labels to `Enrollment` and `Face Check` if current tests allow; otherwise keep `Enroll` and `Verify` in nav and preserve `Enrollment`/`Face Check` as screen headers only.
4. Restyle `_ManagerCommandBar` into a cleaner command surface with title, status pill, refresh, and logout aligned to the new shell.
5. Verify login-gated public surfaces render identically because no code above the authenticated branch changed behavior.

## Todo List

- [ ] Update global manager-safe light theme tokens
- [ ] Restyle shell background and chrome
- [ ] Redesign navigation affordances without changing destination indexes
- [ ] Redesign command bar without changing callbacks
- [ ] Manual check: public mode unchanged

## Success Criteria

- Shell looks visibly different and Apple-like without changing route logic.
- Nav still opens dashboard, people, enrollment, face check, events, settings in the same order.
- `Manager Console`, refresh, and logout remain visible and functional.

## Risk Assessment

- High: nav label drift can break existing text expectations.
  - Mitigation: preserve labels where tests already rely on them; prefer header-only wording changes if uncertain.
- Medium: shell file is already >200 lines.
  - Mitigation: keep edits localized; only extract a helper if the file becomes materially harder to read.
- Medium: theme changes could leak into public mode.
  - Mitigation: keep global theme neutral and do manager-specific chrome styling inside authenticated shell widgets.

## Security Considerations

- None beyond preserving current auth gate and logout behavior.

## Next Steps

- Phase 2 after shell tokens/layout are stable.
- Phase 3 can run in parallel after Phase 1 lands.
