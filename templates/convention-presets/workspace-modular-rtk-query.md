# Project Conventions

**Project:** {{PROJECT_NAME}}
**Team type:** {{TEAM_TYPE}}
**Preset:** {{CONVENTION_PRESET}}

---

## Selected Archetype

- Archetype ID: `nextjs-workspace-modular`
- Summary: Modular workspace-style Next.js application with route shells, area modules, and a central store driven by RTK Query for server state.
- Primary surfaces:
  - Frontend shell: `app/(workspace)`
  - Backend style: bounded modules aligned to workspace capabilities
  - Integration boundary: typed client + RTK Query API slices

## Required Patterns

- `.claude/skills/shared/convention-resolution.md`
- `.claude/skills/archetypes/nextjs-workspace-modular.md`
- `.claude/skills/patterns/feature-folder-architecture.md`
- `.claude/skills/patterns/rtk-query-standard.md`
- `.claude/skills/patterns/typed-api-client-standard.md`
- `.claude/skills/patterns/permission-aware-ui.md`

## Forbidden Patterns

- Route-level API logic that bypasses module boundaries
- Mixing RTK Query with a second global server-state library
- Feature ownership spread across multiple unrelated root folders
- Inline permission logic duplicated in page components

## Folder Contract

| Area | Required location | Notes |
|------|-------------------|-------|
| Workspace shell | `app/(workspace)/...` | Shell composes modules and shared layouts |
| Module code | `src/modules/<area>/...` | Screens, api slices, selectors, tests stay together |
| Shared UI | `src/components/...` | Reusable UI primitives and layout helpers |
| Shared libraries | `src/lib/...` | Typed API client, permissions, utilities |
| Store root | `src/store/...` | Redux store setup and shared middleware |
| API slices | `src/modules/<area>/api/...` | RTK Query endpoints and cache tags |

## Agent Resolution Rule

1. Read this file first.
2. Load every skill listed in `## Required Patterns`.
3. Apply precedence:
   `Optional Overrides` → this file → referenced skills → generic project docs.
4. Mark non-applicable rules explicitly in the track.
5. Treat `Forbidden Patterns` as review failures unless an override says otherwise.

## Optional Overrides

### Frontend

- Data/state pattern: `rtk-query-standard`
- Feature root: `src/modules`
- API client entrypoint: `src/lib/api/client.ts`

### Backend

- Response contract strategy: `stable DTOs optimized for typed client adapters`
- Module root: `src/modules`

### Integrator

- Contract verification focus: `RTK Query endpoints, tags, invalidation, normalization boundaries`

### Reviewer

- Convention compliance priority: `module boundaries and forbidden pattern violations are blocking`
