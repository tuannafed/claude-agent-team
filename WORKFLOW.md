# Agent Team — Workflow Guide

## How It Works

Each feature is a **track file** (`.claude/conductor/tracks/track-NNN-slug.md`).
Agents read from it, write their output section, and the next agent picks up from there.

```
/agent-team <step> <track-id>
       │
       ▼
   Agent reads track file
       │
       ▼
   Agent writes its section
       │
       ▼
   Next agent can proceed
```

---

## Pipelines

### Sequential (default)

> Full control, step by step.

```
/agent-team init "feature"     → BA writes spec + API Contract
/agent-team db track-NNN       → DB schema + migrations
/agent-team backend track-NNN  → Services, endpoints, DTOs
/agent-team frontend track-NNN → Routes, components, hooks
/agent-team integrate track-NNN→ Wire frontend ↔ backend
/agent-team review track-NNN   → Final gate (Sonnet, parallel 9-reviewer)
```

---

### Parallel ⚡ (recommended for medium/large)

> Once BA defines the API Contract, DB and Frontend can run simultaneously.
> ~3x faster than sequential.

```
/agent-team init "feature"                    → BA: spec + API Contract
/agent-team parallel db frontend track-NNN    → DB + Frontend run in order*
/agent-team backend track-NNN                 → Backend reads both outputs
/agent-team integrate track-NNN               → Wire everything
/agent-team review track-NNN                  → Final gate (Sonnet, parallel 9-reviewer)
```

 `parallel db frontend` runs DB first, then Frontend — both use the API Contract, not each other.

---

## Which Pipeline to Use


| Feature type            | Pipeline                                                             |
| ----------------------- | -------------------------------------------------------------------- |
| Simple API endpoint     | `init` → `backend` → `review`                                        |
| Frontend-only           | `init` → `frontend` → `review`                                       |
| Full-stack CRUD         | `init` → `db` → `backend` → `frontend` → `integrate` → `review`      |
| Full-stack (fast)       | `init` → `parallel db frontend` → `backend` → `integrate` → `review` |
| AI/LLM feature          | `init` → `backend` → `ai` → `frontend` → `review`                    |
| Chrome Extension        | `init` → `frontend` → `extension` → `review`                         |
| Bug (backend)           | `init` → `backend` → `review`                                        |
| Bug (frontend)          | `init` → `frontend` → `review`                                       |
| Bug (contract mismatch) | `init` → `backend` → `integrate` → `review`                          |


---

## Track File Structure

`.claude/conductor/tracks/track-NNN-slug.md` is the single source of truth.


| Section                   | Written by      | Read by                       |
| ------------------------- | --------------- | ----------------------------- |
| `## 📋 BA Output`         | ba-agent        | all agents                    |
| `## 📐 API Contract`      | ba-agent        | backend, frontend, integrator |
| `## 🗄️ DB Output`        | db-engineer     | backend                       |
| `## ⚙️ Backend Output`    | backend agent   | integrator, reviewer          |
| `## 🎨 Frontend Output`   | frontend-nextjs | integrator, reviewer          |
| `## 🔗 Integrator Output` | integrator      | reviewer                      |
| `## 🔍 Code Review`       | code-reviewer   | —                             |


> **API Contract** is the unlock key for parallel execution — once BA fills it, DB and Frontend no longer depend on each other.

---

## Agents Reference


| Command                            | Agent                         | Model      | Role                                |
| ---------------------------------- | ----------------------------- | ---------- | ----------------------------------- |
| `/agent-team setup`                | —                             | Sonnet     | Scan codebase, auto-fill context    |
| `/agent-team init` (feature)       | ba-agent                      | **Opus**   | Full spec, user stories, API Contract |
| `/agent-team init` (bug/chore)     | ba-agent-bug                  | Sonnet     | Focused bug report / chore spec     |
| `/agent-team db`                   | db-engineer                   | Sonnet     | DDL, migrations, indexes            |
| `/agent-team backend`              | backend-nestjs / fastapi      | Sonnet     | Services, endpoints, tests          |
| `/agent-team frontend`             | frontend-nextjs               | Sonnet     | Routes, components, state           |
| `/agent-team ai`                   | ai-engineer                   | Sonnet     | LLM chains, RAG, prompts            |
| `/agent-team extension`            | chrome-ext                    | Sonnet     | MV3 extension, background, popup    |
| `/agent-team api`                  | api-designer                  | Sonnet     | OpenAPI spec, contract design       |
| `/agent-team integrate`            | integrator                    | Sonnet     | React Query hooks, API wiring       |
| `/agent-team review`               | code-reviewer                 | Sonnet     | Parallel 9-reviewer, verdict        |
| `/agent-team resume`               | —                             | Sonnet     | Summarize current state + next step |
| `/agent-team status`               | —                             | Sonnet     | List all tracks and phases          |
| `/agent-team parallel db frontend` | db-engineer → frontend-nextjs | Sonnet     | Parallel execution                  |


---

## Bug Fix Flow

```
1. " "fix: <what is broken>"
   → BA writes SHORT spec (bug description, expected vs actual)
   → Skip full API Contract if no endpoint changes

2. Run ONLY the affected layer:
   /agent-team db track-NNN        ← broken schema/migration
   /agent-team backend track-NNN   ← broken logic/validation/auth
   /agent-team frontend track-NNN  ← broken UI/state/API call

3. Always end with:
   /agent-team review track-NNN
```

**Before marking fixed:**

- Root cause fixed (not just symptom)
- Regression test added
- Review approved
- Track status → `done`

---

## Daily Workflow

### Morning (5 min)

```
/agent-team status              → see all open tracks + phases
/agent-team resume track-NNN   → pick up where you left off
```

### During the Day

- Read the track file before running any agent
- After each agent: review the output section before calling the next
- Do **not** chain agents blindly — review each step
- When you learn something: `/learn "lesson"` → saved to `knowledge.md`

### End of Day

- Track file reflects current phase
- Blockers documented with reason
- Next step written in `## Next Step`

---

## Weekly Rhythm


| Day       | Focus                                                  |
| --------- | ------------------------------------------------------ |
| Monday    | Review open tracks, plan the week                      |
| Tue – Thu | Feature development (init → agents → review)           |
| Friday    | Code review, mark tracks `done`, update `knowledge.md` |


