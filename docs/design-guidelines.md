# Design Guidelines

## Status

Planned product design guidance only.

## Design Principles

- Operational first
- Camera first
- Low friction
- Clear trust boundaries
- No decorative complexity that hides state

## Visual Direction

- Neutral, high-contrast UI
- Strong emphasis on status states
- Clean card layout for people and events
- Large capture controls for operator use
- Sparse use of color, reserved for success, warning, and error

## Screen Types

### Capture Screen

- Full-screen camera preview
- Visible face framing guide
- One primary action: capture
- Immediate feedback on no face, multi-face, low quality, match, or deny

### Enrollment Screen

- Step-by-step wizard
- Clear count of required images
- Progress indicator for remaining samples
- Quality feedback after each image

### Admin Screen

- Searchable people list
- Person detail view
- Template list
- Event log with filters
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
