# Knowledge Base — Accumulated Learnings

> Project-level lessons learned across tracks. Updated by agents after each track completion.
> Format: `## [Technology/Domain]` → bullet lessons with track reference.

---

## PostgreSQL

<!-- Add lessons here as you discover them -->
<!-- Example:
- Use `gen_random_uuid()` not `uuid_generate_v4()` — no extension required (track-001)
- JSONB indexes: use GIN, not B-tree for `@>` operator queries (track-003)
- `timestamptz` is stored in UTC, displayed in session timezone — always use timestamptz (track-002)
-->

## NestJS

<!-- Example:
- `class-transformer` must be enabled in main.ts: `app.useGlobalPipes(new ValidationPipe({ transform: true }))` (track-001)
- Circular dependency between modules: use `forwardRef(() => ModuleB)` in both modules (track-004)
- TypeORM `findOne` returns null (not undefined) when not found — check `=== null` (track-002)
-->

## FastAPI

<!-- Example:
- `AsyncSession` must be committed explicitly — `await session.commit()` before returning (track-001)
- Pydantic v2: use `model_config = ConfigDict(from_attributes=True)` instead of `class Config` (track-002)
-->

## Next.js / React

<!-- Example:
- Server Components cannot use `useState`/`useEffect` — mark interactive parts with `'use client'` (track-001)
- `fetch()` in Server Components is automatically deduped per request — safe to call in multiple components (track-003)
- React Query `invalidateQueries` needs exact key match — use the key factory pattern (track-002)
-->

## AI / LLM

<!-- Example:
- Claude API: temperature 0 for structured outputs, 0.7 for creative tasks (track-005)
- Streaming: use `stream=True` with SSE, not WebSocket, for one-shot generations (track-005)
- Prompt caching: system prompts > 1024 tokens qualify — prefix with `cache_control` (track-006)
-->

## Chrome Extension (MV3)

<!-- Example:
- Service workers terminate after 30s idle — use `chrome.alarms` for long-running tasks (track-007)
- `chrome.storage.sync` has 8KB per-item limit — use `chrome.storage.local` for large data (track-007)
-->

## General Patterns

<!-- Cross-cutting lessons that apply everywhere -->
<!-- Example:
- Always define API contract before parallel execution — prevents integration mismatches (track-001)
- Track complexity estimate S=<1day, M=1-3days, L=3-5days, XL=>5days (track-000)
-->

---

## How to Update This File

When an agent discovers a lesson, append it here:

```markdown
- [Brief lesson description] (track-NNN)
```

Reference the track number so the original context can be found.
