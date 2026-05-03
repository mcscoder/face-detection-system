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

Build the Flutter mobile-first client with web fallback: login, live-camera recognition capture, guided server-gated live-camera enrollment, recognition result display, person/admin management, and event views.

## Key Insights

- Mobile app over LAN is the primary demo path.
- Flutter web camera over LAN IP may require HTTPS; localhost web is secondary.
- Client only captures and displays. No local inference.
- Enrollment must feel like phone or bank face setup: camera opens once, the app prompts the user what to do next, and accepted samples are captured automatically.
- Identification must use a live camera session, not a gallery/image-picker-first flow.
- Enrollment must not advance on timer alone; it advances only when the backend accepts the current prompt sample.

## Requirements

- Functional: auth session, live camera identify flow, server-gated guided camera enrollment flow, people CRUD, event list, admin settings.
- Non-functional: operational UI, high contrast, short labels, explicit error states, no internal stack trace display.

## Architecture

Client layers:

| Layer | Purpose |
|---|---|
| API client | typed HTTP calls, token handling, upload multipart |
| State | auth/session, current role, server config |
| Screens | live capture, result, people, guided enrollment, events, settings |
| Widgets | status banners, person card, camera preview, face guide, pose prompt, enrollment progress, live identify controls |

Use server response codes to drive UI states.

## Related Code Files

- Create/modify: `client/lib/`
- Create: `client/test/`
- Create: `client/integration_test/`

## Implementation Steps

1. Add login screen and token persistence appropriate for local demo.
2. Add API client for auth, server info, people, faces, recognitions, events, and config.
3. Replace identify image selection with a live camera preview and one-tap live probe capture.
4. Build recognition result screen for allow/deny/no-face/multi-face/low-score/system-error states.
5. Build people list/detail/edit screens for Admin and Enrollment Operator.
6. Replace the enrollment upload wizard with guided live-camera enrollment.
7. Add enrollment prompts for center face, turn left, turn right, look up or down, and current natural look.
8. Auto-capture candidate samples from the camera stream and upload them with expected prompt metadata to `/v1/faces/{person_id}/samples`.
9. Advance enrollment only after the backend accepts the current prompt; retry the same prompt on no-face, multi-face, low-quality, or wrong-pose feedback.
10. Build event log list with filters by date, person, device, and decision.
11. Build settings UI for Admin threshold and retention fields.
12. Add widget tests for core screens and API error mapping.

## Todo List

- [x] Auth flow shell implemented.
- [x] Capture and image upload implemented through live camera.
- [x] Live transport sanitizes multipart filenames.
- [x] Android APK release build passes.
- [x] Result states implemented.
- [x] People/admin screens shell implemented.
- [x] Enrollment wizard creates people and uploads accepted samples.
- [x] Events/settings views shell implemented.
- [x] Mobile and web smoke runs documented.
- [x] Replace one-photo-at-a-time enrollment upload UI with guided live-camera enrollment.
- [x] Add pose prompt sequence and automatic accepted-sample capture.
- [x] Keep user inside one enrollment camera session until required samples are accepted or canceled.
- [x] Upload accepted camera samples automatically to the existing enrollment API.
- [x] Replace identify image-picker flow with live camera preview/capture.
- [x] Keep identify user inside one camera session while sending probe frames.
- [x] Gate enrollment step advancement on backend sample acceptance, not countdown completion.
- [x] Show current-prompt rejection feedback and retry the same prompt without moving forward.

## Success Criteria

- [x] Mobile client can login and call local API over LAN on phone.
- [x] Capture flow reaches `/v1/recognitions/identify` with camera image bytes.
- [x] Identify opens a live camera session and submits camera captures to `/v1/recognitions/identify`.
- [x] Result UI shows score, threshold, event ID, and decision.
- [x] Enrollment opens the camera once, guides the user through required poses, and captures accepted samples automatically.
- [x] Enrollment creates a person and uploads accepted camera samples to `/v1/faces/{person_id}/samples`.
- [x] Enrollment does not advance to the next prompt until backend validation accepts the current prompt.
- [x] Enrollment shows retry feedback for no-face, multiple-face, low-quality, and wrong-pose states.
- [x] Admin-only screens are blocked for non-admin roles.
- [ ] Web client works on localhost after web platform files exist; LAN web HTTPS need documented if not implemented.

## Risk Assessment

- Risk: camera support differs between platforms. Mitigation: make Android camera the primary path and keep hardware checks in manual smoke.
- Risk: UI scope grows. Mitigation: keep v1 operational screens only; no marketing/landing pages.

## Security Considerations

- Store tokens minimally for local demo.
- Do not expose admin routes in UI for lower roles.
- Do not display raw internal errors.

## Next Steps

Phase 6 validates client behavior against the real API and key failure states.
