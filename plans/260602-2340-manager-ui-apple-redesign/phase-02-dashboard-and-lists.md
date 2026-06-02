## Context Links

- Dashboard metrics, quick actions, recent activity: [client/lib/screens/manager_dashboard_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/manager_dashboard_screen.dart:27)
- People search/list/open flow: [client/lib/screens/people_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/people_screen.dart:26)
- Events filter/list flow: [client/lib/screens/events_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/events_screen.dart:24)

## Overview

- Priority: P2
- Status: pending
- Goal: redesign dashboard, people, and events into cleaner high-density light surfaces with stronger hierarchy and unchanged interactions.

## Key Insights

- Dashboard quick actions mutate the shell index via callbacks from [client/lib/screens/shell_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/shell_screen.dart:78); dashboard redesign must keep those callbacks intact.
- People behavior is local UI state plus navigation to detail in [client/lib/screens/people_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/people_screen.dart:86); redesign can stay presentation-only.
- Events filtering is local `filter` state in [client/lib/screens/events_screen.dart](/home/mcs/Workspaces/face-detection-system/client/lib/screens/events_screen.dart:17); chip visuals can change without touching event data flow.

## Requirements

- Preserve headers `Dashboard`, `People`, `Recent Activity`, `Events`.
- Keep people search, person open, and add-person affordance.
- Keep events filters and empty state messaging.
- Avoid any controller/API changes.

## Architecture

- Data in: `controller.value.people`, `controller.value.events`, `controller.value.config`, `controller.value.serverInfo`.
- Transform: local formatting, grouping, density/layout changes only.
- Data out: same callbacks and same navigation targets.

## Related Code Files

- Modify: `client/lib/screens/manager_dashboard_screen.dart`
- Modify: `client/lib/screens/people_screen.dart`
- Modify: `client/lib/screens/events_screen.dart`
- Create: none
- Delete: none

## Implementation Steps

1. Rework dashboard hero/metrics into Apple-like cards with calmer stat presentation and a stronger quick-actions row.
2. Restyle people summary, search field, and list tiles into cleaner inset cards/list rows while preserving `onAddPerson` and person detail navigation.
3. Restyle event filter chips and event rows into compact timeline/list cards without changing filter logic.
4. Align empty states and secondary text with the new shell spacing and color system from Phase 1.
5. Manual verify that dashboard quick actions still open the same destinations and that people/events local state still responds.

## Todo List

- [ ] Redesign dashboard card hierarchy
- [ ] Redesign people summary/search/list density
- [ ] Redesign events filters/list density
- [ ] Keep callbacks and local filtering unchanged

## Success Criteria

- Dashboard reads as a dashboard-first console, not a generic card stack.
- People and events screens match the shell visual language.
- Search, filters, add/open interactions behave exactly as before.

## Risk Assessment

- High: dashboard quick actions can silently drift from shell destination indexes.
  - Mitigation: do not change callback wiring or button intent.
- Medium: denser list styling can reduce readability.
  - Mitigation: keep line-height, contrast, and tap targets comfortable.
- Low: list redesign may expose overflow on narrow widths.
  - Mitigation: keep text truncation and avoid multi-column assumptions.

## Security Considerations

- Preserve role-based UI disabling already provided by current state.

## Next Steps

- Hand off to Phase 4 verification after Phase 3 lands.
