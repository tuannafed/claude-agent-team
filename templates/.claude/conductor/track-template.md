# Track: {{TRACK_TITLE}}

**Track ID:** track-{{NNN}}-{{slug}}
**Created:** {{DATE}}
**Team type:** {{TEAM_TYPE}}

## Status

**Current status:** `pending`
**Current phase:** `ba`
**Next step:** Run `/agent-team init` or paste BA agent prompt

---

## 📋 BA Output — Specification

<!-- BA Agent writes here -->

### Feature Description

_[To be filled by BA agent]_

### User Stories

- As a **[role]**, I want to **[action]** so that **[benefit]**

### Acceptance Criteria

- [ ] _[Criterion 1]_
- [ ] _[Criterion 2]_

### Out of Scope

- _[What this track does NOT include]_

### Open Questions

- _[Any unresolved decisions]_

---

## 📐 API Contract

<!-- BA Agent defines this — unlocks parallel execution of DB + Frontend -->
<!-- DB Engineer reads: Specification above -->
<!-- Frontend Dev reads: this section (does NOT need DB schema) -->
<!-- Backend Dev reads: DB schema + this section -->

### Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| _[To be filled by BA agent]_ | | | |

### Request Schemas

```typescript
// [To be filled by BA agent]
```

### Response Schemas

```typescript
// [To be filled by BA agent]
```

### Error Responses

| Status | Code | When |
|--------|------|------|
| 400 | VALIDATION_ERROR | Invalid input |
| 401 | UNAUTHORIZED | Missing/invalid token |
| 404 | NOT_FOUND | Resource doesn't exist |

---

## 🗄️ DB Engineer Output — Schema

<!-- DB Engineer writes here after BA is complete -->

### Tables / Collections

```sql
-- [Schema DDL here]
```

### Migrations

```
migration-NNN-<description>
```

### Indexes

```sql
-- [Index definitions]
```

### Notes

_[Any DB design decisions or trade-offs]_

---

## ⚙️ Backend Output — API & Logic

<!-- Backend Dev writes here after DB is complete -->

### Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/api/...` | JWT | ... |

### Request/Response Schemas

```typescript
// [TypeScript interfaces or Pydantic models]
```

### Business Logic Notes

_[Key logic decisions, edge cases handled]_

### Files to Create/Modify

- `src/...` — [purpose]

---

## 🎨 Frontend Output — UI & Components

<!-- Frontend Dev writes here after Backend is complete -->

### Pages / Routes

| Route | Component | Description |
|-------|-----------|-------------|
| `/...` | `<ComponentName>` | ... |

### Components to Create

- `components/...` — [description]

### State Management

_[What state, how managed]_

### API Integration Notes

_[How frontend calls backend APIs]_

---

## 🤖 AI Engineer Output

<!-- AI Engineer writes here (ai-llm-app team type only) -->

### LLM Configuration

_[Model, temperature, streaming — to be filled by AI Engineer]_

### Prompt Templates

_[System + user prompt templates]_

### RAG Pipeline

_[Chunking, embedding, retrieval — if applicable]_

### Cost Estimate

_[Tokens per request × daily volume × price]_

### Files to Create/Modify

- _[AI integration files]_

---

## 🔌 Extension Output

<!-- Chrome Extension Dev writes here (chrome-extension team type only) -->

### Extension Architecture

_[Popup, content scripts, service worker structure]_

### manifest.json Summary

_[Key permissions, host permissions]_

### Message Passing Protocol

_[Message types between components]_

### Files to Create/Modify

- _[Extension files]_

---

## 🔗 Integrator Output

<!-- Integrator writes here (fullstack-web only) -->

### Integration Points

_[Frontend ↔ Backend connection notes]_

### Data Transformation

_[Any mapping between API response and UI state]_

---

## 🔍 Code Review

<!-- Code Reviewer writes here -->

### Review Status: `pending`

### Issues Found

| Severity | File | Line | Issue | Resolution |
|----------|------|------|-------|------------|
| — | — | — | — | — |

### Approval

- [ ] Approved by reviewer
- [ ] All issues resolved

---

## 📝 Notes & Decisions

_[Any cross-cutting concerns, decisions made during the track]_
