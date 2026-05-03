# Project Overview and PDR

## Purpose

Build a local-first face recognition access-control system that runs on one machine with an NVIDIA GPU 8GB.

## Product Summary

- Server is the center of the system
- Client only captures images, uploads them, and displays results
- AI inference stays on the server
- Primary demo client: Flutter mobile
- Secondary demo client: Flutter web

## Current Repository State

- Implementation: backend foundation and Flutter mobile demo flows in progress
- Application code: backend plus Flutter live identify, guided enrollment, and People management present
- Current source of truth: [`deep-research-report.md`](../deep-research-report.md)
- This document: product requirements and current scope, not a setup guide

## Problem Statement

The system needs to identify a person from a probe image, compare it against enrolled face templates, and return a stable identifier for access-control decisions.

## Scope

### In Scope

- Person enrollment with 3-5 face images
- Template generation on the server
- 1:N face identification
- Person CRUD with flexible metadata
- Access decisions with audit logs
- Authentication and RBAC
- Local storage and retention rules

### Out Of Scope For v1

- Client-side inference
- Cloud deployment
- Multi-machine scaling
- Commercial-grade anti-spoofing beyond roadmap placeholders
- Full HR or attendance workflows

## Primary User Roles

- Admin
- Enrollment operator
- Guard/operator
- Registered device client

## Functional Requirements

### Identity and Access

- Login required for operator actions
- Role-based access for admin features
- Device/client identity for API use

### People Management

- Create, update, soft delete, and search people
- Support fixed profile fields and flexible `extra_data`
- Fetch a person by stable `person_id`

### Enrollment

- Accept 3-5 enrollment images per person
- Reject invalid uploads
- Allow only one face per enrollment image
- Create one or more active templates

### Recognition

- Accept a probe image over HTTP
- Reject no-face and multi-face images
- Extract embedding server-side
- Match against enrolled templates
- Return `person_id`, `similarity_score`, `threshold`, `event_id`, and `decision`

### Audit

- Log every recognition event
- Record success and failure reasons
- Support retention policy for probe images

## Non-Functional Requirements

- Local only after setup
- GPU-first inference with CPU fallback
- Low operational complexity
- Minimal probe storage by default
- Clear auditability
- Flexible schema for profile expansion
- Stable model and template versioning

## Data Classification

Biometric data is sensitive. Treat face images, embeddings, and probe artifacts as restricted data with tighter access, storage, and retention rules.

## Acceptance Criteria

- Server starts locally on the target machine
- Inference runs on the NVIDIA GPU path
- Enrollment creates usable templates
- Recognition returns stable IDs and scores
- Logs capture access-control decisions
- Admin-only data stays restricted
- Repository docs describe current implementation state accurately

## Success Metrics

- Demo can identify enrolled people locally
- False accept / false reject behavior can be tuned by threshold
- Operator workflow stays under a few steps
- Audit trail is complete enough for review

## Open Questions

- Final authentication method for v1
- Exact retention window for probe images
- Final model pack choice between speed and accuracy tradeoff
- Whether liveness detection enters v1 or a later phase

## References

- Product source: [`../deep-research-report.md`](../deep-research-report.md)
- Current backend surface: [`../backend/app`](../backend/app)
- Current client shell: [`../client/lib`](../client/lib)
