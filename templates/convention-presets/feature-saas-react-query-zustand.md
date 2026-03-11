# Project Conventions

**Project:** {{PROJECT_NAME}}
**Team type:** {{TEAM_TYPE}}
**Preset:** {{CONVENTION_PRESET}}

---

## Selected Archetype

- Archetype ID: `nextjs-feature-saas`
- Summary: Feature-oriented Next.js application with a clear boundary between app routes, feature modules, shared UI, and integration utilities.
- Primary surfaces:
  - Frontend shell: `app/(marketing)` and `app/(app)`
  - Backend style: stable REST modules aligned to feature names
  - Integration boundary: typed API client consumed from feature modules

## Required Patterns

- `.claude/skills/shared/convention-resolution.md`
- `.claude/skills/archetypes/nextjs-feature-saas.md`
- `.claude/skills/patterns/feature-folder-architecture.md`
- `.claude/skills/patterns/react-query-zustand.md`
- `.claude/skills/patterns/typed-api-client-standard.md`
- `.claude/skills/patterns/permission-aware-ui.md`

## Forbidden Patterns

- Business logic embedded directly inside route files
- Raw `fetch` calls scattered across client components
- Copying server state into Zustand stores
- Permission checks implemented as repeated inline role string comparisons

## Folder Contract

| Area | Required location | Notes |
|------|-------------------|-------|
| Route groups | `app/(marketing)` and `app/(app)` | Routes compose feature modules, not own them |
| Feature modules | `src/features/<feature>/...` | UI, API, hooks, schemas, tests stay together |
| Shared UI | `src/components/ui/...` | Generic, design-system-like components only |
| Shared libraries | `src/lib/...` | API client, auth, permissions, utilities |
| Feature state | `src/features/<feature>/store/...` | Zustand for local UI/workflow state only |
| Feature queries | `src/features/<feature>/api/...` | React Query hooks and endpoint adapters |

## Agent Resolution Rule

1. Read this file first.
2. Load every skill listed in `## Required Patterns`.
3. Apply precedence:
   `Optional Overrides` → this file → referenced skills → generic project docs.
4. Mark non-applicable rules explicitly in the track.
5. Treat `Forbidden Patterns` as review failures unless an override says otherwise.

## Optional Overrides

### Frontend

- Data/state pattern: `react-query-zustand`
- Feature root: `src/features`
- API client entrypoint: `src/lib/api/client.ts`

### Backend

- Response contract strategy: `stable DTOs that map cleanly to the typed client`
- Module root: `src/modules`

### Integrator

- Contract verification focus: `React Query keys, mutation invalidation, adapter mapping`

### Reviewer

- Convention compliance priority: `folder contract and forbidden pattern violations are blocking`
