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
        │  writes: conductor/tracks/track-001-auth.md        │
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

The track file `conductor/tracks/track-NNN-slug.md` is the single source of truth —
each agent reads from it and writes into its own section:

```
conductor/tracks/track-001-auth.md
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
