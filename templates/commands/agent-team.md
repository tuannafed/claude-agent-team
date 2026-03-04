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
1. Read `conductor/tracks/<track-id>*.md` — BA Spec section
2. Read `conductor/tech-stack.md` for DB conventions
3. Read `conductor/knowledge.md` for accumulated DB lessons
4. Design schema, write DDL + migrations
5. Fill in `## 🗄️ DB Engineer Output` section
6. If you discovered any lessons, append them to `conductor/knowledge.md`
7. Mark DB phase as complete

**Step 2 — Frontend role (immediately after, same session):**
1. Read `## 📐 API Contract` section (NOT the DB schema — Frontend is independent)
2. Read `## 📋 BA Output` for user stories
3. Read `conductor/knowledge.md` for accumulated frontend lessons
4. Design routes, components, state management
5. Fill in `## 🎨 Frontend Output` section
6. Note any mock/fixture needed while Backend is not ready yet
7. If you discovered any lessons, append them to `conductor/knowledge.md`

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

1. Read `CLAUDE.md` for project context
2. Read `conductor/product.md` for product context
3. Read `conductor/workflow.md` for team rules
4. Read `conductor/knowledge.md` for accumulated lessons
5. **Assess your confidence** in understanding the requirements:
   - ≥ 90%: proceed directly
   - 70–89%: present 2-3 interpretations, ask user to pick one
   - < 70%: list open questions, do NOT write spec until answered
6. Create a new track file in `conductor/tracks/` with the next available number
   - Format: `conductor/tracks/track-NNN-<slug>.md`
   - Copy structure from `conductor/tracks/` (look at existing tracks for format, or use the standard template)
7. Fill in the `## 📋 BA Output` section based on the feature description
8. Fill in the `## 📐 API Contract` section — this is REQUIRED to enable parallel execution
9. Set status to `in-progress`, phase to `ba`
10. Report:
```
Confidence: X%

✅ Track created: conductor/tracks/track-NNN-<slug>.md

Next options:
  ⚡ Parallel (recommended): /agent-team parallel db frontend track-NNN
  📦 Sequential:             /agent-team db track-NNN
```

---

### `/agent-team db <track-id>`

You are acting as the **DB Engineer Agent**.

1. Read `conductor/tracks/<track-id>*.md` — BA Spec section
2. Read `conductor/tech-stack.md` for DB conventions
3. Read `conductor/knowledge.md` for accumulated DB lessons
4. Design schema, write DDL + migrations, fill in `## 🗄️ DB Engineer Output` section
5. Update phase to `db`
6. If you discovered any lessons (gotchas, decisions), append to `conductor/knowledge.md`
7. Report: "Schema complete. Next: `/agent-team backend <track-id>`"

---

### `/agent-team backend <track-id>`

You are acting as the **Backend Dev Agent**.

1. Check `CLAUDE.md` for backend stack (NestJS or FastAPI)
2. Read `conductor/tracks/<track-id>*.md` — BA Spec + API Contract + DB schema sections
3. Read `conductor/tech-stack.md` for naming conventions
4. Read `conductor/knowledge.md` for accumulated backend lessons
5. Implement the backend feature and fill in `## ⚙️ Backend Output` section
6. Update phase to `backend`
7. If you discovered any lessons, append to `conductor/knowledge.md`
8. Report: "Backend complete. Next: `/agent-team frontend <track-id>` or `/agent-team integrate <track-id>`"

---

### `/agent-team frontend <track-id>`

You are acting as the **Frontend Dev Agent**.

1. Read `conductor/tracks/<track-id>*.md` — BA Output + API Contract sections
2. Read `CLAUDE.md` for frontend stack
3. Read `conductor/knowledge.md` for accumulated frontend lessons
4. Implement frontend feature and fill in `## 🎨 Frontend Output` section
5. Update phase to `frontend`
6. If you discovered any lessons, append to `conductor/knowledge.md`
7. Report: "Frontend complete. Next: `/agent-team integrate <track-id>` or `/agent-team review <track-id>`"

---

### `/agent-team ai <track-id>`

You are acting as the **AI Engineer Agent**.

1. Read `conductor/tracks/<track-id>*.md` — BA Spec + Backend sections
2. Read `conductor/tech-stack.md` for LLM/vector DB stack
3. Read `conductor/knowledge.md` for accumulated AI engineering lessons
4. Implement AI/LLM integration and fill in `## 🤖 AI Engineer Output` section
5. Update phase to `ai`
6. If you discovered any lessons (prompt patterns, cost gotchas), append to `conductor/knowledge.md`
7. Report: "AI integration complete. Next: `/agent-team frontend <track-id>`"

---

### `/agent-team api <track-id>`

You are acting as the **API Designer Agent**.

1. Read `conductor/tracks/<track-id>*.md` — Backend Output section
2. Read `conductor/tech-stack.md` for API versioning strategy
3. Read the actual backend controller/router files referenced in the track
4. Generate OpenAPI 3.1 spec, verify REST conventions, document all error responses
5. Fill in `## 📐 API Designer Output` section
6. Update phase to `api-design`
7. Report: "API spec complete. Next: `/agent-team review <track-id>`"

---

### `/agent-team extension <track-id>`

You are acting as the **Chrome Extension Dev Agent**.

1. Read `conductor/tracks/<track-id>*.md` — BA Spec + Frontend sections
2. Read `conductor/knowledge.md` for accumulated extension lessons
3. Implement extension architecture and fill in `## 🔌 Extension Output` section
4. Update phase to `extension`
5. If you discovered any lessons (MV3 gotchas, permissions), append to `conductor/knowledge.md`
6. Report: "Extension complete. Next: `/agent-team review <track-id>`"

---

### `/agent-team integrate <track-id>`

You are acting as the **Integrator Agent**.

1. Read `conductor/tracks/<track-id>*.md` — Backend + Frontend sections
2. Read the actual frontend and backend code files referenced in the track
3. Connect frontend to backend, implement React Query hooks, fill in `## 🔗 Integrator Output` section
4. Update phase to `integration`
5. Report: "Integration complete. Next: `/agent-team review <track-id>`"

---

### `/agent-team review <track-id>`

You are acting as the **Code Reviewer Agent**.

1. Read the full track file
2. Read the actual code files referenced in the track
3. Review across 5 dimensions: Security, Performance, Architecture, Testing, Code Quality
4. Fill in `## 🔍 Code Review` section
5. Set approval status: `approved` or `changes-requested`
6. Report: "Review complete. Status: [approved | changes-requested]"

---

### `/agent-team resume <track-id>`

Resume work on an in-progress track.

1. Read `conductor/tracks/<track-id>*.md`
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

### `/agent-team status`

Show a summary of all tracks:

1. List all files in `conductor/tracks/`
2. Read each file's `## Status` section
3. Output a table:

```
Track ID                        | Status       | Phase      | Next Step
track-001-auth                  | in-progress  | backend    | /agent-team frontend track-001
track-002-dashboard             | pending      | —          | /agent-team init
track-003-notifications         | done         | —          | —
```
