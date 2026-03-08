---
model: claude-sonnet-4-6
---

Run the agent team workflow command: $ARGUMENTS

## Instructions

Parse $ARGUMENTS to determine which action to take:

---

### `/agent-team parallel db frontend <track-id>`

⚡ **Parallel execution** — Run DB Engineer and Frontend Dev simultaneously on the same track.

**Prerequisite:** BA must have completed BOTH `## 📋 BA Output` AND `## 📐 API Contract` sections.

You will perform BOTH roles in sequence within this single session, treating them as parallel work:

**Step 1 — DB Engineer role:**
1. Read `.claude/conductor/tracks/<track-id>*.md` — BA Spec section
2. Read `.claude/conductor/tech-stack.md` for DB conventions
3. Read `.claude/conductor/knowledge.md` for accumulated DB lessons
4. Design schema, write DDL + migrations
5. Fill in `## 🗄️ DB Engineer Output` section
6. If you discovered any lessons, append them to `.claude/conductor/knowledge.md`
7. Mark DB phase as complete

**Step 2 — Frontend role (immediately after, same session):**
1. Read `## 📐 API Contract` section (NOT the DB schema — Frontend is independent)
2. Read `## 📋 BA Output` for user stories
3. Read `.claude/conductor/knowledge.md` for accumulated frontend lessons
4. Design routes, components, state management
5. Fill in `## 🎨 Frontend Output` section
6. Note any mock/fixture needed while Backend is not ready yet
7. If you discovered any lessons, append them to `.claude/conductor/knowledge.md`

Update track after both complete:
- `## Current Phase` → `parallel-done`
- `## Next Step` → `Run /agent-team backend <track-id> (needs DB schema above)`

Report:
```
✅ Parallel phase complete for <track-id>:
   🗄️  DB: [brief summary of tables created]
   🎨  Frontend: [brief summary of pages/components]

Next: /agent-team backend <track-id>
```

---

### `/agent-team init "<feature description>"`

You are acting as the **BA Agent**.

> **Model routing:** Detect the track type first (step 6 below), then use the appropriate agent:
> - `feature` → delegate to **ba-agent** (Opus — full spec + API contract)
> - `bug` / `chore` / `refactor` → delegate to **ba-agent-bug** (Sonnet — focused report, no API contract)

**MANDATORY — Check conductor state before creating or writing anything:**

1. **Read** `.claude/conductor/tracks.md` if it exists (full content).
2. **List** `.claude/conductor/tracks/` and parse existing track file names (e.g. `track-001-*.md`, `track-002-*.md`, …) to see which track numbers are already used.
3. **Compute the next track number** `NNN`: the smallest positive integer (001, 002, …) such that no file `track-NNN-*.md` exists in `.claude/conductor/tracks/` and (if `tracks.md` exists) no row in the table uses that ID. Examples: no tracks yet → **001**; 001..004 exist → **005**. Do **not** assume track-001 when other tracks already exist.
4. **Do NOT write to conductor config during init.** For `.claude/conductor/product.md`, `workflow.md`, `tech-stack.md`, `knowledge.md`: you may **read** them for context only. Do **not** create, overwrite, or edit these files in this command — use `/agent-team setup` to fill them, or they are created by `agent-init` when scaffolding a new project.

Then:

5. Read `CLAUDE.md` for project context. You may read `.claude/conductor/product.md`, `workflow.md`, `knowledge.md` for context **only** — do not write, edit, or create these files.
6. **Detect track type** — classify as `feature | bug | chore | refactor`
7. **Assess your confidence** in understanding the requirements:
   - ≥ 90%: proceed directly
   - 70–89%: present 2-3 interpretations, ask user to pick one
   - < 70%: list open questions, do NOT write spec until answered
8. **Create exactly one new file:** `.claude/conductor/tracks/track-NNN-<slug>.md` (e.g. `track-005-post-engine.md`). Do **not** create, overwrite, or delete any existing file in `.claude/conductor/tracks/` (e.g. do not create `track-001-<anything>.md` if `track-001-*.md` already exists).
9. Fill in the spec section based on **track type**:
   - `feature` → `## 📋 BA Output` + `## 📐 API Contract` (required for parallel)
   - `bug` → `## 📋 BA Output — Bug Report` only
   - `chore`/`refactor` → `## 📋 BA Output — Chore/Refactor Spec` only
10. Set status to `in-progress`, phase to `ba`
11. **Update the registry without dropping existing rows:**
    - If `.claude/conductor/tracks.md` **exists:** read its full content, **append** one new row for the new track (table columns: Status | ID | Title | Type | Phase | Created | Updated — see existing `tracks.md`), then write the file back with **all original rows plus the new row**. Do **not** replace the entire table with only the new track.
    - If `.claude/conductor/tracks.md` **does not exist:** create it with a single-row table for the new track (and optional header/legend as in current format).
12. Report:
```
Type: [feature|bug|chore|refactor]
Confidence: X%

✅ Track created: .claude/conductor/tracks/track-NNN-<slug>.md
   Registered in: .claude/conductor/tracks.md

Next options:
```

**For feature:**
```
  ⚡ Parallel (recommended): /agent-team parallel db frontend track-NNN
  📦 Sequential DB first:    /agent-team db track-NNN
```

**For bug:**
```
  🔧 Backend fix:  /agent-team backend track-NNN
  🎨 Frontend fix: /agent-team frontend track-NNN
```

**For chore/refactor:**
```
  ⚙️  Backend:  /agent-team backend track-NNN
  🎨 Frontend: /agent-team frontend track-NNN
```

---

### `/agent-team db <track-id>`

You are acting as the **DB Engineer Agent**.

1. Read `.claude/conductor/tracks/<track-id>*.md` — BA Spec section
2. Read `.claude/conductor/tech-stack.md` for DB conventions
3. Read `.claude/conductor/knowledge.md` for accumulated DB lessons
4. Design schema, write DDL + migrations, fill in `## 🗄️ DB Engineer Output` section
5. Update phase to `db`
6. If you discovered any lessons (gotchas, decisions), append to `.claude/conductor/knowledge.md`
7. Report: "Schema complete. Next: `/agent-team backend <track-id>`"

---

### `/agent-team backend <track-id>`

You are acting as the **Backend Dev Agent**.

1. Check `CLAUDE.md` for backend stack (NestJS or FastAPI)
2. Read `.claude/conductor/tracks/<track-id>*.md` — BA Spec + API Contract + DB schema sections
3. Read `.claude/conductor/tech-stack.md` for naming conventions
4. Read `.claude/conductor/knowledge.md` for accumulated backend lessons
5. Implement the backend feature and fill in `## ⚙️ Backend Output` section
6. Update phase to `backend`
7. If you discovered any lessons, append to `.claude/conductor/knowledge.md`
8. Report: "Backend complete. Next: `/agent-team frontend <track-id>` or `/agent-team integrate <track-id>`"

---

### `/agent-team frontend <track-id>`

You are acting as the **Frontend Dev Agent**.

1. Read `.claude/conductor/tracks/<track-id>*.md` — BA Output + API Contract sections
2. Read `CLAUDE.md` for frontend stack
3. Read `.claude/conductor/knowledge.md` for accumulated frontend lessons
4. Implement frontend feature and fill in `## 🎨 Frontend Output` section
5. Update phase to `frontend`
6. If you discovered any lessons, append to `.claude/conductor/knowledge.md`
7. Report: "Frontend complete. Next: `/agent-team integrate <track-id>` or `/agent-team review <track-id>`"

---

### `/agent-team ai <track-id>`

You are acting as the **AI Engineer Agent**.

1. Read `.claude/conductor/tracks/<track-id>*.md` — BA Spec + Backend sections
2. Read `.claude/conductor/tech-stack.md` for LLM/vector DB stack
3. Read `.claude/conductor/knowledge.md` for accumulated AI engineering lessons
4. Implement AI/LLM integration and fill in `## 🤖 AI Engineer Output` section
5. Update phase to `ai`
6. If you discovered any lessons (prompt patterns, cost gotchas), append to `.claude/conductor/knowledge.md`
7. Report: "AI integration complete. Next: `/agent-team frontend <track-id>`"

---

### `/agent-team api <track-id>`

You are acting as the **API Designer Agent**.

1. Read `.claude/conductor/tracks/<track-id>*.md` — Backend Output section
2. Read `.claude/conductor/tech-stack.md` for API versioning strategy
3. Read the actual backend controller/router files referenced in the track
4. Generate OpenAPI 3.1 spec, verify REST conventions, document all error responses
5. Fill in `## 📐 API Designer Output` section
6. Update phase to `api-design`
7. Report: "API spec complete. Next: `/agent-team review <track-id>`"

---

### `/agent-team extension <track-id>`

You are acting as the **Chrome Extension Dev Agent**.

1. Read `.claude/conductor/tracks/<track-id>*.md` — BA Spec + Frontend sections
2. Read `.claude/conductor/knowledge.md` for accumulated extension lessons
3. Implement extension architecture and fill in `## 🔌 Extension Output` section
4. Update phase to `extension`
5. If you discovered any lessons (MV3 gotchas, permissions), append to `.claude/conductor/knowledge.md`
6. Report: "Extension complete. Next: `/agent-team review <track-id>`"

---

### `/agent-team integrate <track-id>`

You are acting as the **Integrator Agent**.

1. Read `.claude/conductor/tracks/<track-id>*.md` — Backend + Frontend sections
2. Read the actual frontend and backend code files referenced in the track
3. Connect frontend to backend, implement React Query hooks, fill in `## 🔗 Integrator Output` section
4. Update phase to `integration`
5. Report: "Integration complete. Next: `/agent-team review <track-id>`"

---

### `/agent-team review <track-id>`

Run a comprehensive parallel code review with specialized sub-reviewers.

**Step 1 — Present reviewer menu**

Ask the user which reviewers to run:

```
🔍 Code Review — track-NNN

Select reviewers to run (Enter = all, or pick numbers e.g. 1 3 4):

  [1]  Test Runner              — Run tests, report pass/fail
  [2]  Linter & Static Analysis — Run linters + type checks
  [3]  Code Reviewer            — Up to 5 improvements ranked by impact/effort
  [4]  Security Reviewer        — Injection, auth, secrets, error leaks
  [5]  Quality & Style          — Complexity, dead code, naming, conventions
  [6]  Test Quality             — Coverage ROI, flakiness, behavior vs implementation
  [7]  Performance              — N+1 queries, blocking ops, re-renders, memory leaks
  [8]  Dependency & Deployment  — New deps, breaking changes, migration safety, rollback
  [9]  Simplification           — Could this be simpler? Change atomicity & reviewability

Which reviewers? [1-9 or Enter for all]:
```

**Step 2 — Read context**

Before launching agents, read:
- `.claude/conductor/tracks/<track-id>*.md` — full track (BA spec + all outputs)
- `CLAUDE.md` — project stack and conventions
- The actual code files referenced in the track

**Step 3 — Launch selected reviewers in parallel**

Run all selected reviewers simultaneously as parallel sub-tasks. Each reviewer gets:
- The list of changed files from the track
- The project tech stack from CLAUDE.md
- Their specific review focus below

---

**Reviewer 1 — Test Runner**
```
Run the relevant tests for files changed in this track.
Report:
- Which test command was run
- Pass/fail status with counts
- Any failures with file:line and error message
If no tests exist for these files, report that clearly.
```

**Reviewer 2 — Linter & Static Analysis**
```
Run the project linter (eslint, ruff, mypy, tsc --noEmit, etc.) on changed files.
Report:
- Tool(s) used
- Errors and warnings with file:line
- Which are auto-fixable vs manual
- Type errors or unresolved references
```

**Reviewer 3 — Code Reviewer**
```
Check CLAUDE.md for project conventions.
Provide up to 5 concrete improvements, ranked by impact/effort:

Format each as:
[HIGH/MED/LOW Impact, HIGH/MED/LOW Effort] Title
- What: description
- Why: why it matters
- How: concrete fix

Focus on non-obvious issues. Skip what linters catch.
```

**Reviewer 4 — Security Reviewer**
```
Review for:
- Input validation and sanitization
- Injection risks (SQL, command, XSS)
- Auth/authorization gaps
- Secrets or credentials in code
- Error handling that leaks sensitive info

Report with severity (Critical/High/Medium/Low) and file:line.
If clean: "No security concerns identified."
```

**Reviewer 5 — Quality & Style**
```
Check CLAUDE.md for project conventions.
Review for:
- Complexity: functions too long, deeply nested, high cyclomatic complexity
- Dead code: unused imports, unreachable code
- Duplication: copy-paste that should be abstracted
- Naming: matches project patterns?
- File organization: right place?
- Consistency: matches surrounding code style?

If clean: "No quality or style issues identified."
```

**Reviewer 6 — Test Quality**
```
Evaluate test coverage and quality:
- Are critical paths tested? (auth, payments, data integrity)
- Do tests verify behavior, not implementation details?
- Flakiness risks: timing, external state, async not awaited?
- Anti-patterns: testing internals, over-mocking, no real assertions?
- Test code quality: duplication, could be parameterized?

If solid: "Test coverage is appropriate and behavior-focused."
```

**Reviewer 7 — Performance**
```
Review for:
- N+1 queries or inefficient data fetching
- Blocking operations in async contexts
- Unnecessary re-renders or recomputations (React)
- Memory leaks (unclosed resources, growing collections)
- Missing pagination for large datasets
- Expensive operations in hot paths

If clean: "No performance concerns identified."
```

**Reviewer 8 — Dependency & Deployment Safety**
```
Review for:
Dependencies (if package files changed):
- New deps justified? Could existing deps handle it?
- Well-maintained? Known vulnerabilities?
- Bundle size impact?

Breaking Changes:
- Public interfaces, types, or exports modified?
- Existing consumers would break?

Deployment Safety:
- DB migrations that could fail or lock tables?
- Backwards compatible with existing production data?
- Safe to roll back if issues arise?
- Would a feature flag help?

Observability:
- If this fails in prod, how would we know?
- Are error cases logged/alerted?

If clean: "No dependency, compatibility, or deployment concerns."
```

**Reviewer 9 — Simplification & Maintainability**
```
Review with fresh eyes — could this be simpler?
- Abstractions that don't pull their weight?
- Same result with less code?
- Solving problems we don't have?
- Clever code sacrificing clarity?
- Premature abstractions (helpers used once)?

Change Atomicity:
- Does this represent one logical unit of work?
- Unrelated changes mixed in that should be separate commits?
- Sized appropriately for review?

If simple and atomic: "Code complexity is proportionate and changes are well-scoped."
```

---

**Step 4 — Synthesize results**

After all selected reviewers complete, produce a prioritized summary:

```
## 🔍 Code Review — <track-id>

### Needs Attention (<N> issues)
1. [Security] <title> — file:line
   <brief description>
2. [Tests] <title> — file:line
   <brief description>

### Suggestions (<N> items)
1. [Quality] <title> (HIGH impact, LOW effort)
   <brief description>
2. [Perf] <title> (MED impact, MED effort)
   <brief description>

### All Clear
Tests (N passed), Linter (no issues), [other clean reviewers...]

### Verdict: Ready to Merge | Needs Attention | Needs Work
<One sentence: what to do next>
```

**Verdict guidelines:**
- **Ready to Merge** — tests pass, no critical/high issues, suggestions optional
- **Needs Attention** — medium issues or important suggestions worth addressing
- **Needs Work** — critical/high issues or failing tests that must be fixed

**Step 5 — Write to track file**

Write the full synthesis into `## 🔍 Code Review` section of the track file.
Set `### Review Status` to `approved` (Ready to Merge) or `changes-requested` (Needs Attention / Needs Work).

---

### `/agent-team resume <track-id>`

Resume work on an in-progress track.

1. Read `.claude/conductor/tracks/<track-id>*.md`
2. Read `## Status` → `## Current Phase` and `## Next Step`
3. Report current state and ask what to do next:

```
📋 Track: <track-id>
   Status: in-progress
   Phase:  backend
   Next:   /agent-team frontend <track-id>

What would you like to do?
  a) Continue with next step: /agent-team frontend <track-id>
  b) Re-run current phase: /agent-team backend <track-id>
  c) Show full track summary
```

---

### `/agent-team setup`

Scan this codebase and auto-fill the project context files so agents have accurate, project-specific information from day one.

**What this does:**
1. Scans the project for tech stack signals
2. Infers product domain and purpose
3. Writes findings to `CLAUDE.md`, `.claude/conductor/product.md`, and `.claude/conductor/tech-stack.md`
4. Reports what was auto-detected and what needs manual review

---

**Step 1 — Scan the codebase**

Read and analyze these files (if they exist):

| File | What to extract |
|------|----------------|
| `package.json` | framework, dependencies, scripts, project name/description |
| `pyproject.toml` / `requirements.txt` | Python framework, dependencies |
| `README.md` | project purpose, features, architecture overview |
| `docker-compose.yml` / `Dockerfile` | services, ports, database type |
| `.env.example` / `.env` | service names, API keys hinting at integrations |
| `src/` / `app/` folder structure | monorepo vs flat, frontend vs backend layout |
| `tsconfig.json` / `next.config.*` | Next.js version, path aliases |
| `nest-cli.json` | NestJS presence |
| `alembic.ini` / `migrations/` | migration tool, database presence |

**Step 2 — Detect tech stack**

From your scan, identify:
- **Frontend:** framework + version (Next.js, React, Vue, etc.)
- **Backend:** framework + version (NestJS, FastAPI, Express, etc.)
- **Database:** type + ORM (PostgreSQL + Prisma, MySQL + TypeORM, etc.)
- **Auth:** JWT, OAuth, session-based, etc.
- **AI/LLM:** OpenAI, Anthropic, LangChain, vector DB, etc.
- **Deployment:** Docker, Vercel, AWS, Railway, etc.
- **Package manager:** pnpm, npm, yarn, uv, pip

**Step 3 — Infer product domain**

From README, folder names, route names, model/entity names, and env vars — infer:
- What does this product do? (1-2 sentences)
- Who are the users?
- What are the core entities/resources? (e.g., User, Order, Product)
- What integrations exist? (Stripe, Sendgrid, S3, etc.)

**Step 4 — Update CLAUDE.md**

Read the current `CLAUDE.md`. Replace placeholder values (lines containing `[Fill in` or `[e.g.`) with detected values. Do NOT overwrite lines that already have real content.

Fields to fill:
- Project description
- Frontend stack
- Backend stack
- Database
- Auth solution
- Deployment

**Step 5 — Update product.md**

Read `.claude/conductor/product.md`. Fill in:
- Product vision (inferred from README/description)
- Core user roles (inferred from auth patterns, entity names)
- Core features (inferred from routes, controllers, pages)
- Key constraints (inferred from env vars, integrations)

Only fill sections that contain placeholder text. Preserve any real content.

**Step 6 — Update tech-stack.md**

Read `.claude/conductor/tech-stack.md`. Fill in all detected stack details:
- Exact versions where found
- Naming conventions (inferred from existing code style)
- Key dependencies and their roles

Only fill sections that contain placeholder text.

**Step 7 — Report**

```
✅ Setup complete for: <project-name>

Detected stack:
  Frontend  : [e.g. Next.js 15 + React 19 + Tailwind CSS]
  Backend   : [e.g. NestJS 10 + TypeORM]
  Database  : [e.g. PostgreSQL 16 + Prisma]
  Auth      : [e.g. JWT + refresh tokens]
  Deployment: [e.g. Docker + Railway]

Updated files:
  ✅ CLAUDE.md
  ✅ .claude/conductor/product.md
  ✅ .claude/conductor/tech-stack.md

Needs manual review:
  ⚠️  [list any fields that could not be auto-detected]

Ready to build:
  /agent-team init "Your first feature"
```

---

### `/agent-team status`

Show a summary of all tracks:

1. Read `.claude/conductor/tracks.md` directly
2. Display the table as-is, then annotate each in-progress track with its next step:

```
📋 Agent Team — Track Status

| Status | ID                      | Title              | Type    | Phase    | Updated    |
|--------|-------------------------|--------------------|---------|----------|------------|
| [~]    | track-001-auth          | User Auth          | feature | backend  | 2025-01-15 |
| [x]    | track-002-dashboard     | Admin Dashboard    | feature | done     | 2025-01-14 |
| [ ]    | track-003-notifications | Push Notifications | feature | pending  | 2025-01-16 |

Legend: [ ] pending  [~] in-progress  [x] done

Suggested next steps:
  track-001-auth  → /agent-team frontend track-001
```
