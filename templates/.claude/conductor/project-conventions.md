# Project Conventions

Use this file to declare the neutral engineering conventions for this project.
Agents must treat it as the source of truth for architecture choices that can vary
between projects.

**Project:** {{PROJECT_NAME}}
**Team type:** {{TEAM_TYPE}}
**Preset:** {{CONVENTION_PRESET}}

---

## Selected Archetype

- Archetype ID: `custom`
- Summary: Replace this with the neutral product archetype that best matches the project.
- Primary surfaces:
  - Frontend shell: `[define if applicable]`
  - Backend style: `[define if applicable]`
  - Integration boundary: `[define if applicable]`

## Required Patterns

List each required skill path explicitly. Agents must load these files before proposing architecture or code.

- `.claude/skills/shared/convention-resolution.md`
- `.claude/skills/patterns/typed-api-client-standard.md`

## Forbidden Patterns

- Hardcoded business/domain terminology copied from prior projects
- Global state rules that contradict the selected project pattern
- Ad-hoc folder layouts that bypass the folder contract below
- Raw API usage in components when a typed client convention exists

## Folder Contract

Document only the paths that matter for this project. Delete unused rows.

| Area | Required location | Notes |
|------|-------------------|-------|
| App routes | `app/...` | Keep route files thin |
| Feature code | `src/features/<feature>/...` | Colocate UI, API, schemas, tests |
| Shared UI | `src/components/...` | Reusable presentational components only |
| Shared libraries | `src/lib/...` | Typed API client, auth, permissions, utilities |
| Permissions | `src/lib/permissions/...` | Permission checks, capability helpers |

## Agent Resolution Rule

1. Read this file before designing architecture, code, or review feedback.
2. Load every skill listed in `## Required Patterns`.
3. Apply precedence in this order:
   `Optional Overrides` → `Project Conventions` → referenced skills → generic project docs.
4. If a rule is not relevant to the current layer, mark it `not-applicable` in the track's `Convention Resolution` section instead of ignoring it silently.
5. Treat `Forbidden Patterns` as review failures unless an override explicitly allows them.

## Optional Overrides

Use this section for project-specific decisions that should override a generic archetype or pattern.

### Frontend

- Data/state pattern: `[react-query-zustand | rtk-query-standard | custom]`
- Feature root: `[e.g. src/features or src/modules]`
- API client entrypoint: `[e.g. src/lib/api/client.ts]`

### Backend

- Response contract strategy: `[e.g. stable DTOs mirrored to typed client]`
- Module root: `[e.g. src/modules or app/services]`

### Integrator

- Contract verification focus: `[e.g. endpoint adapters, cache tags, invalidation rules]`

### Reviewer

- Convention compliance priority: `[e.g. folder contract is blocking, naming is warning]`
