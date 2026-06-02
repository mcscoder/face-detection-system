# Design Guidelines

## Status

Implemented direction for the current Flutter demo UI.

## Design Principles

- Operational first
- Camera first
- Low friction
- Clear trust boundaries
- No decorative complexity that hides state

## Visual Direction

- Neutral, high-contrast UI
- Face ID-inspired public surfaces with dark camera-first presentation
- Public verify uses a fixed camera surface with a real oval face guide and public-only pass/fail/retry results
- Public enrollment uses separate name and guided face-capture steps
- Light manager console surfaces with rail navigation, dashboard metrics, compact panels, and clear status chips
- Strong emphasis on status states
- Clean card layout for people and events
- Large capture controls for operator use
- Sparse use of color, reserved for success, warning, and error

## Screen Types

### Public User Home

- Only two primary actions: Verify Face and Enroll Face
- Manager entry is secondary
- Use a dark Face ID demo presentation with one strong primary action
- Avoid exposing operational controls

### Capture Screen

- Full-screen public camera preview
- Visible oval face framing guide
- One primary action: capture
- Public mode hides score, threshold, event ID, person ID, and manager diagnostics

### Enrollment Screen

- Step 1 collects public user name
- Step 2 runs guided five-pose face capture
- Clear count of required images
- Progress indicator for remaining samples
- Quality feedback after each image

### Manager Screen

- Dashboard-first console
- Rail navigation on authenticated manager shell
- Searchable people list
- Person detail view
- Template list
- Event log with compact decision filters
- Threshold and retention settings

## Content Rules

- Show `person_id` only when needed
- Prefer short labels over dense copy
- Do not expose internal errors to operators
- Keep biometric explanations simple and factual

## Interaction Rules

- Minimize taps for capture
- Make destructive actions explicit
- Confirm removal or disable actions
- Keep thresholds and retention clearly labeled

## Accessibility Notes

- Support high contrast
- Use readable type sizes on mobile
- Do not rely on color alone for success or failure
- Keep buttons large enough for one-hand operation

## Trust And Safety

- Biometrics should feel controlled, not flashy
- Use audit and state labels to make decisions explainable
- Do not imply biometric certainty beyond thresholded similarity

## References

- Product source: [`../deep-research-report.md`](../deep-research-report.md)
- Current client screens: [`../client/lib/screens`](../client/lib/screens)
