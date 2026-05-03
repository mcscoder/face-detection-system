---
phase: 5
title: "Client"
status: in-progress
priority: P2
effort: "4d"
dependencies: [1, 4]
---

# Phase 5: Client

## Context Links

- [`deep-research-report.md`](../../deep-research-report.md)
- [`docs/design-guidelines.md`](../../docs/design-guidelines.md)
- [`docs/system-architecture.md`](../../docs/system-architecture.md)

## Overview

Build the Flutter mobile-first client with web fallback: login, capture/upload, recognition result display, person/admin management, enrollment wizard, and event views.

## Key Insights

- Mobile app over LAN is the primary demo path.
- Flutter web camera over LAN IP may require HTTPS; localhost web is secondary.
- Client only captures and displays. No local inference.

## Requirements

- Functional: auth session, camera/upload, identify flow, enrollment flow, people CRUD, event list, admin settings.
- Non-functional: operational UI, high contrast, short labels, explicit error states, no internal stack trace display.

## Architecture

Client layers:

| Layer | Purpose |
|---|---|
| API client | typed HTTP calls, token handling, upload multipart |
| State | auth/session, current role, server config |
| Screens | capture, result, people, enrollment, events, settings |
| Widgets | status banners, person card, image picker/camera control |

Use server response codes to drive UI states.

## Related Code Files

- Create/modify: `client/lib/`
- Create: `client/test/`
- Create: `client/integration_test/`

## Implementation Steps

1. Add login screen and token persistence appropriate for local demo.
2. Add API client for auth, server info, people, faces, recognitions, events, and config.
3. Build capture screen with camera preview or image upload fallback.
4. Build recognition result screen for allow/deny/no-face/multi-face/low-score/system-error states.
5. Build people list/detail/edit screens for Admin and Enrollment Operator.
6. Build enrollment wizard requiring 3-5 accepted samples and quality feedback after each upload.
7. Build event log list with filters by date, person, device, and decision.
8. Build settings UI for Admin threshold and retention fields.
9. Add widget tests for core screens and API error mapping.

## Todo List

- [x] Auth flow shell implemented.
- [x] Capture and upload shell implemented.
- [x] Result states implemented.
- [x] People/admin screens shell implemented.
- [x] Enrollment wizard shell implemented.
- [x] Events/settings views shell implemented.
- [ ] Mobile and web smoke runs documented.

## Success Criteria

- [ ] Mobile client can login and call local API over LAN.
- [x] Capture flow reaches `/v1/recognitions/identify` through API abstraction.
- [x] Result UI shows score, threshold, event ID, and decision.
- [x] Enrollment wizard shell tracks required sample count.
- [x] Admin-only screens are blocked for non-admin roles.
- [ ] Web client works on localhost; LAN web HTTPS need documented if not implemented.

## Risk Assessment

- Risk: camera support differs between platforms. Mitigation: provide upload fallback and test mobile primary path first.
- Risk: UI scope grows. Mitigation: keep v1 operational screens only; no marketing/landing pages.

## Security Considerations

- Store tokens minimally for local demo.
- Do not expose admin routes in UI for lower roles.
- Do not display raw internal errors.

## Next Steps

Phase 6 validates client behavior against the real API and key failure states.
