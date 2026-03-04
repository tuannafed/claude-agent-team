# Team Config: Full-Stack Web

**Stack:** Next.js 15 + NestJS (or FastAPI) + PostgreSQL

## Agent Pipeline

**Sequential (simple):**
```
BA → DB → Backend → Frontend → Integrator → Reviewer
```

**Parallel (recommended — faster):**
```
BA (spec + API contract)
    ↓
    ├── DB Engineer ─────────────────────────────┐
    └── Frontend (builds against API contract) ──┤
                                                 ↓
                                           Backend (DB schema + contract)
                                                 ↓
                                           Integrator → Reviewer
```

## Agent Responsibilities

| Order | Agent | Phase Key | Input | Output |
|-------|-------|-----------|-------|--------|
| 1 | BA | `ba` | CLAUDE.md + product.md | Spec + **API Contract** |
| 2a ⚡ | DB Engineer | `db` | BA spec | Schema, migrations, indexes |
| 2b ⚡ | Frontend Dev | `frontend` | **API Contract** (not DB!) | Pages, components, mocks |
| 3 | Backend Dev | `backend` | DB schema + API contract | REST APIs, business logic |
| 4 | Integrator | `integration` | Frontend + Backend | Connected flow, real API |
| 5 | Code Reviewer | `review` | All above | Issues list, approval |

⚡ = runs in parallel after BA completes

## Slash Commands

```
/agent-team init "<feature>"                 → BA (spec + API contract)
/agent-team parallel db frontend <track-id>  → ⚡ DB + Frontend simultaneously
/agent-team db <track-id>                    → DB Engineer only
/agent-team frontend <track-id>              → Frontend only
/agent-team backend <track-id>               → Backend (after parallel done)
/agent-team integrate <track-id>             → Integrator
/agent-team review <track-id>                → Code Reviewer
/agent-team status                           → Track summary
```

## Agent Prompts

- BA: `~/Projects/AI/claude-agent-team/templates/agent-prompts/ba.md`
- DB Engineer: `~/Projects/AI/claude-agent-team/templates/agent-prompts/db-engineer.md`
- Backend (NestJS): `~/Projects/AI/claude-agent-team/templates/agent-prompts/backend-nestjs.md`
- Backend (FastAPI): `~/Projects/AI/claude-agent-team/templates/agent-prompts/backend-fastapi.md`
- Frontend (Next.js): `~/Projects/AI/claude-agent-team/templates/agent-prompts/frontend-nextjs.md`
- Integrator: `~/Projects/AI/claude-agent-team/templates/agent-prompts/integrator.md`
- Code Reviewer: `~/Projects/AI/claude-agent-team/templates/agent-prompts/code-reviewer.md`

## Quality Gates

- BA output must have acceptance criteria before DB starts
- DB schema must be reviewed by Backend Dev before implementation
- API contract must be stable before Frontend starts
- Integration must pass before Code Review
