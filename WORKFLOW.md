# Agent Team — Orchestration Workflow

```
╔══════════════════════════════════════════════════════════════════╗
║                  AGENT TEAM ORCHESTRATION                        ║
║              Command  →  Agent  →  Track File                    ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## Case 1 — Sequential Pipeline

> Use when: standard feature, no rush, want full control over each step.

```
                    ┌──────────────────────────┐
                    │       User Request        │
                    │  "Add user auth feature"  │
                    └────────────┬─────────────┘
                                 │
                                 ▼
        ┌────────────────────────────────────────────────────┐
        │  /agent-team init "Add user auth feature"          │
        │  Command (Entry Point) — model: sonnet             │
        └────────────────────────┬───────────────────────────┘
                                 │
                            activates
                                 │
                                 ▼
        ┌────────────────────────────────────────────────────┐
        │  ba-agent  ● model: opus  ● color: purple          │
        │                                                    │
        │  reads:  CLAUDE.md, product.md, workflow.md        │
        │          knowledge.md                              │
        │  writes: .claude/conductor/tracks/track-001-auth.md        │
        │          ├── ## 📋 BA Output (spec + stories)      │
        │          └── ## 📐 API Contract  ← unlock key      │
        └────────────────────────┬───────────────────────────┘
                                 │
                    track-001-auth.md created
                                 │
                                 ▼
        ┌────────────────────────────────────────────────────┐
        │  /agent-team db track-001                         │
        └────────────────────────┬───────────────────────────┘
                                 │
                                 ▼
        ┌────────────────────────────────────────────────────┐
        │  db-engineer  ● model: sonnet  ● color: blue       │
        │                                                    │
        │  reads:  ## 📋 BA Output                           │
        │          tech-stack.md, knowledge.md               │
        │  writes: ## 🗄️ DB Engineer Output                  │
        │          (DDL, migrations, indexes)                │
        └────────────────────────┬───────────────────────────┘
                                 │
                                 ▼
        ┌────────────────────────────────────────────────────┐
        │  /agent-team backend track-001                    │
        └────────────────────────┬───────────────────────────┘
                                 │
                                 ▼
        ┌────────────────────────────────────────────────────┐
        │  backend-nestjs / backend-fastapi                  │
        │  ● model: sonnet  ● color: green                   │
        │                                                    │
        │  reads:  ## 📋 BA Output                           │
        │          ## 📐 API Contract  ← source of truth     │
        │          ## 🗄️ DB Engineer Output                  │
        │  writes: ## ⚙️ Backend Output                      │
        │          (endpoints, services, DTOs, tests)        │
        └────────────────────────┬───────────────────────────┘
                                 │
                                 ▼
        ┌────────────────────────────────────────────────────┐
        │  /agent-team frontend track-001                   │
        └────────────────────────┬───────────────────────────┘
                                 │
                                 ▼
        ┌────────────────────────────────────────────────────┐
        │  frontend-nextjs  ● model: sonnet  ● color: cyan   │
        │                                                    │
        │  reads:  ## 📋 BA Output                           │
        │          ## 📐 API Contract                        │
        │  writes: ## 🎨 Frontend Output                     │
        │          (routes, components, state, API hooks)    │
        └────────────────────────┬───────────────────────────┘
                                 │
                                 ▼
        ┌────────────────────────────────────────────────────┐
        │  /agent-team review track-001                     │
        └────────────────────────┬───────────────────────────┘
                                 │
                                 ▼
        ┌────────────────────────────────────────────────────┐
        │  code-reviewer  ● model: opus  ● color: red        │
        │                                                    │
        │  reads:  full track file + all code files          │
        │  writes: ## 🔍 Code Review                         │
        │          (Security / Perf / Arch / Test / Quality) │
        └────────────────────────┬───────────────────────────┘
                                 │
                         ┌───────┴────────┐
                         ▼                ▼
                   ✅ approved     🔄 changes-requested
```

---

## Case 2 — Parallel Pipeline ⚡ (Recommended)

> Use when: want faster delivery. DB and Frontend run simultaneously after BA defines the API Contract.
> **3x faster** than sequential for medium/large tracks.

```
                    ┌──────────────────────────┐
                    │       User Request        │
                    │  "Add user auth feature"  │
                    └────────────┬─────────────┘
                                 │
                                 ▼
        ┌────────────────────────────────────────────────────┐
        │  /agent-team init "Add user auth feature"          │
        └────────────────────────┬───────────────────────────┘
                                 │
                                 ▼
        ┌────────────────────────────────────────────────────┐
        │  ba-agent  ● model: opus                           │
        │                                                    │
        │  MUST complete BOTH sections before parallel:      │
        │  ├── ## 📋 BA Output      (spec, stories, ACs)     │
        │  └── ## 📐 API Contract   (endpoints + schemas)    │
        │             ↑                                      │
        │       This is the unlock key for parallel          │
        └──────────────────┬─────────────────────────────────┘
                           │
              API Contract defined ✓
                           │
         ┌─────────────────┴──────────────────┐
         │  /agent-team parallel db frontend  │
         │         track-001                  │
         └────────┬──────────────┬────────────┘
                  │              │
          Step 1  │              │  Step 2
    (same session,│              │  same session)
                  ▼              ▼
   ┌──────────────────┐  ┌──────────────────────────┐
   │  db-engineer     │  │  frontend-nextjs          │
   │  ● sonnet ● blue │  │  ● sonnet ● cyan          │
   │                  │  │                           │
   │  reads:          │  │  reads:                   │
   │  ## 📋 BA Output │  │  ## 📐 API Contract ONLY  │
   │                  │  │  (does NOT need DB schema) │
   │  writes:         │  │                           │
   │  ## 🗄️ DB Output │  │  writes:                  │
   │  (DDL, indexes,  │  │  ## 🎨 Frontend Output    │
   │   migrations)    │  │  (components built        │
   │                  │  │   against mock API)        │
   └────────┬─────────┘  └────────────┬──────────────┘
            │                         │
            └──────────┬──────────────┘
                       │
               both complete
                       │
                       ▼
        ┌────────────────────────────────────────────────────┐
        │  /agent-team backend track-001                    │
        └────────────────────────┬───────────────────────────┘
                                 │
                                 ▼
        ┌────────────────────────────────────────────────────┐
        │  backend-nestjs / backend-fastapi  ● sonnet ● green│
        │                                                    │
        │  reads:  ## 📐 API Contract  (must match exactly)  │
        │          ## 🗄️ DB Engineer Output                  │
        │  writes: ## ⚙️ Backend Output                      │
        └────────────────────────┬───────────────────────────┘
                                 │
                                 ▼
        ┌────────────────────────────────────────────────────┐
        │  /agent-team integrate track-001                  │
        └────────────────────────┬───────────────────────────┘
                                 │
                                 ▼
        ┌────────────────────────────────────────────────────┐
        │  integrator  ● model: sonnet  ● color: yellow      │
        │                                                    │
        │  reads:  ## ⚙️ Backend Output                      │
        │          ## 🎨 Frontend Output + actual code       │
        │  writes: ## 🔗 Integrator Output                   │
        │          (React Query hooks, API wiring,           │
        │           contract verification)                   │
        └────────────────────────┬───────────────────────────┘
                                 │
                                 ▼
        ┌────────────────────────────────────────────────────┐
        │  /agent-team review track-001                     │
        └────────────────────────┬───────────────────────────┘
                                 │
                                 ▼
        ┌────────────────────────────────────────────────────┐
        │  code-reviewer  ● model: opus  ● color: red        │
        │  reads: full track + all code files                │
        └────────────────────────┬───────────────────────────┘
                                 │
                         ┌───────┴────────┐
                         ▼                ▼
                   ✅ approved     🔄 changes-requested
```

---

## Track File as Shared State

The track file `.claude/conductor/tracks/track-NNN-slug.md` is the single source of truth —
each agent reads from it and writes into its own section:

```
.claude/conductor/tracks/track-001-auth.md
│
├── ## Status          ← updated by each agent (current phase + next step)
├── ## 📋 BA Output    ← written by ba-agent
├── ## 📐 API Contract ← written by ba-agent  ← READ by frontend + backend
├── ## 🗄️ DB Output   ← written by db-engineer ← READ by backend
├── ## ⚙️ Backend Output ← written by backend agent
├── ## 🎨 Frontend Output ← written by frontend agent
├── ## 🔗 Integrator Output ← written by integrator
└── ## 🔍 Code Review  ← written by code-reviewer
```

---

---

## Case 3 — New Feature (Decision Flow)

> Quick guide: pick the right pipeline based on feature scope.

```
          Start: "I need to build a new feature"
                        │
                        ▼
        ┌───────────────────────────────┐
        │  Does it need new DB tables?  │
        └───────────────────────────────┘
               │              │
              Yes              No
               │              │
               ▼              ▼
    Run full pipeline    Skip DB step
    (Case 1 or Case 2)   (BA → Backend → Frontend → Review)
```

### Step-by-Step: New Feature

```
Step 1  /agent-team init "feature name"
        → ba-agent writes spec + API contract
        → Review output, confirm scope before proceeding

Step 2  Choose pipeline:

        SIMPLE (no DB change)
        ─────────────────────────────────────────────────
        /agent-team backend track-NNN   → implement API
        /agent-team frontend track-NNN  → build UI
        /agent-team review track-NNN    → final gate

        STANDARD (with DB schema)
        ─────────────────────────────────────────────────
        /agent-team db track-NNN        → schema + migration
        /agent-team backend track-NNN   → implement API
        /agent-team frontend track-NNN  → build UI
        /agent-team integrate track-NNN → wire frontend ↔ backend
        /agent-team review track-NNN    → final gate

        PARALLEL ⚡ (recommended for medium/large)
        ─────────────────────────────────────────────────
        /agent-team parallel db frontend track-NNN
        ↓ (both complete)
        /agent-team backend track-NNN
        /agent-team integrate track-NNN
        /agent-team review track-NNN
```

**Which agents to run by feature type:**

| Feature type | Agents needed |
|---|---|
| Simple API endpoint | BA → Backend → Review |
| Frontend-only UI | BA → Frontend → Review |
| Full-stack CRUD | BA → DB → Backend → Frontend → Integrate → Review |
| AI/LLM feature | BA → Backend → AI Engineer → Frontend → Review |
| Chrome Extension | BA → Frontend → Chrome Ext → Review |

---

## Case 4 — Bug Fix

> Skip BA + DB when possible. Only run affected layers.

```
        Start: "There's a bug in X"
                     │
                     ▼
        ┌──────────────────────────────────┐
        │  Which layer is broken?          │
        └──────────────────────────────────┘
          │           │           │
       DB only    Backend only  Frontend only
          │           │           │
          ▼           ▼           ▼
      /agent-team  /agent-team  /agent-team
      db track-NNN backend NNN  frontend NNN
          │           │           │
          └─────┬─────┘           │
                │                 │
                ▼                 ▼
        /agent-team review track-NNN   ← always required
```

### Bug Fix Flow

```
Step 1  Create a minimal track:
        /agent-team init "fix: <what is broken>"
        → ba-agent writes a SHORT spec (bug description + expected vs actual)
        → Skip full API contract if no endpoint changes

Step 2  Run ONLY the affected agents:

        BUG in DB (wrong schema, index, migration)
        ──────────────────────────────────────────
        /agent-team db track-NNN
        /agent-team review track-NNN

        BUG in Backend (wrong logic, missing validation, auth issue)
        ─────────────────────────────────────────────────────────────
        /agent-team backend track-NNN
        /agent-team review track-NNN

        BUG in Frontend (UI, state, API call)
        ─────────────────────────────────────────────────────────────
        /agent-team frontend track-NNN
        /agent-team review track-NNN

        BUG spans Backend + Frontend (contract mismatch, wiring)
        ─────────────────────────────────────────────────────────────
        /agent-team backend track-NNN
        /agent-team integrate track-NNN
        /agent-team review track-NNN

Step 3  Branch naming: fix/track-NNN-<bug-slug>
        Commit: fix(track-NNN): <what was wrong>
```

**Checklist before marking bug fixed:**
- [ ] Root cause identified and fixed (not just symptom)
- [ ] Regression test added
- [ ] `/agent-team review` approved
- [ ] Track status → `done`

---

## Case 5 — Daily Work Guide

> How to start each day and maintain momentum.

### Morning Routine (5 min)

```
1. Check track status
   /agent-team status
   → lists all tracks with current phase + last updated

2. Pick up where you left off
   /agent-team resume track-NNN
   → reads track file, summarizes current state + next step

3. Check for blocked tracks
   → Look for tracks with status = "blocked"
   → Resolve the blocker before starting new work
```

### During the Day

```
Starting a task:
   Read the track file first
   → .claude/conductor/tracks/track-NNN-slug.md
   → Check "## Current Phase" and "## Next Step"

After each agent run:
   → Review the agent's output section
   → If something looks wrong, fix before calling next agent
   → Do NOT chain all agents blindly — review each step

When you learn something new:
   /learn "lesson about X"
   → Adds to .claude/conductor/knowledge.md
   → Future agents will read this and avoid the same mistake
```

### End of Day Checklist

```
[ ] Track file updated with current phase
[ ] Uncommitted changes staged (git add) or noted
[ ] Blocked reasons documented in track file
[ ] Tomorrow's next step written in "## Next Step"
```

### Weekly Rhythm

| Day | Focus |
|-----|-------|
| Mon | Review open tracks, plan the week |
| Tue–Thu | Feature development (init → agents → review) |
| Fri | Code review + mark tracks done + update knowledge.md |

---

## Command Reference

| Command | Agent activated | Model |
|---------|----------------|-------|
| `/agent-team init "<feature>"` | ba-agent | opus |
| `/agent-team db <track-id>` | db-engineer | sonnet |
| `/agent-team backend <track-id>` | backend-nestjs / backend-fastapi | sonnet |
| `/agent-team frontend <track-id>` | frontend-nextjs | sonnet |
| `/agent-team parallel db frontend <track-id>` | db-engineer → frontend-nextjs | sonnet |
| `/agent-team integrate <track-id>` | integrator | sonnet |
| `/agent-team ai <track-id>` | ai-engineer | sonnet |
| `/agent-team extension <track-id>` | chrome-ext | sonnet |
| `/agent-team api <track-id>` | api-designer | sonnet |
| `/agent-team review <track-id>` | code-reviewer | opus |
| `/agent-team resume <track-id>` | — (status check) | sonnet |
| `/agent-team status` | — (list all tracks) | sonnet |
