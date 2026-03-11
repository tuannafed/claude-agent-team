# Changelog — Claude Agent Team Framework

All improvements adopted from external repos, ordered chronologically.

---

## [Fix] `/agent-team init` conductor state and no-overwrite (2025-03)

- **Check conductor before creating:** Init must read `.claude/conductor/tracks.md` (if exists) and list `.claude/conductor/tracks/` to infer used track numbers. Compute next `NNN` as the smallest positive integer with no existing `track-NNN-*.md`; do not assume track-001.
- **Append-only registry:** When updating `tracks.md`, append one new row; never replace the entire table with only the new track.
- **No overwrite of config:** Do not overwrite `product.md`, `workflow.md`, `tech-stack.md`, or `knowledge.md` if they already exist; create only when missing.
- Updated: `templates/commands/agent-team.md`, `templates/.claude/agents/ba-agent.md`, `templates/.claude/agents/ba-agent-bug.md`.

---

## [Feature] Neutral project conventions and preset-driven agent resolution (2026-03)

- Added `.claude/conductor/project-conventions.md` as the per-project convention manifest.
- Added neutral convention presets:
  - `feature-saas-react-query-zustand`
  - `workspace-modular-rtk-query`
- Added convention skill taxonomy:
  - `shared/`
  - `archetypes/`
  - `patterns/`
- Added neutral convention skills:
  - `feature-folder-architecture`
  - `nextjs-feature-saas`
  - `nextjs-workspace-modular`
  - `react-query-zustand`
  - `rtk-query-standard`
  - `typed-api-client-standard`
  - `permission-aware-ui`
- Updated frontend, backend, integrator, and reviewer agents to:
  - read `project-conventions.md`
  - load referenced convention skills
  - write `Convention Resolution` into the active track before continuing
- Updated bootstrap and upgrade scripts to scaffold convention manifests and nested convention skills.

---

## [Adopted from shanraisshan/claude-code-config]

### Agent Frontmatter Enhancements

- `**color**` — visual identity per agent (purple=BA, blue=DB, green=backend, cyan=frontend, yellow=integrator, magenta=AI, orange=chrome-ext, red=reviewer)
- `**maxTurns**` — per-agent token guard (BA:10, DB:8, backend:20, frontend:20, integrator:15, AI:15, chrome:15, reviewer:10)
- `**permissionMode: acceptEdits**` — all agents except code-reviewer auto-approve edits (reviewer is read-only)

### Environment & Permissions

- `**CLAUDE_AUTOCOMPACT_PCT_OVERRIDE: "80"**` in `settings.json` — compact at 80% context instead of 95%, prevents mid-task truncation
- **Explicit permission rules** in `settings.json`:
  - `allow`: Read, Write/Edit `conductor/`**
  - `ask`: Write/Edit `src/**`, `app/**`, any `git` command
- `**model: claude-sonnet-4-6**` frontmatter on `commands/agent-team.md`

---

## [Adopted from wshobson/agents]

### tracks.md Registry

- `**templates/conductor/tracks.md**` — master registry table of all tracks
  - Columns: Status `[ ]`/`[~]`/`[x]`, ID, Title, Type, Phase, Created, Updated
- `**init-new-project.sh**` updated to copy `tracks.md` into new projects

### Track Type System

- 4 track types: `feature` | `bug` | `chore` | `refactor`
- `/agent-team init` detects type, generates type-conditional spec sections:
  - `feature` → BA Output + API Contract (unlocks parallel execution)
  - `bug` → Bug Report only
  - `chore`/`refactor` → Scope spec only
- Type-aware next-step suggestions in init output

### BA Agent Rewrite (`ba-agent.md`)

- Full rewrite with 7-step workflow
- **Confidence gate**: ≥90% proceed, 70-89% present alternatives, <70% ask questions first
- Track type detection built in
- tracks.md registration as final step

### `/agent-team status` Optimization

- Reads `conductor/tracks.md` directly (1 file) instead of globbing N track files
- Displays table + annotates in-progress tracks with suggested next command

---

## [Adopted from affaan-m/everything-claude-code]

### Hooks (settings.json)

- `**PreToolUse: Bash`** — remind to use tmux when running dev server outside tmux session (non-blocking tip)
- `**PostToolUse: Edit**` — warn when `console.log`/`console.debug` detected in JS/TS files after edits

### New Commands

- `**/checkpoint**` (`commands/checkpoint.md`) — git-backed workflow checkpoints
  - `create <name>` → git commit + log entry in `conductor/checkpoints.log`
  - `verify <name>` → diff files, run tests, compare to checkpoint
  - `list` → table of all checkpoints
  - Typical use: checkpoint at each track phase boundary, verify before PR
- `**/learn**` (`commands/learn.md`) — extract reusable patterns from session
  - Reviews session for non-trivial insights (error patterns, workarounds, architectural decisions)
  - Confirms with user before writing
  - Appends to `conductor/knowledge.md` or saves as `conductor/notes/<date>-<slug>.md`

### Init Script

- `init-new-project.sh` now loops over all commands (`agent-team`, `checkpoint`, `learn`) instead of hardcoding

---

## [Adopted from SuperClaude-Org/SuperClaude_Framework]

### Anti-Hallucination: The Four Questions (`code-reviewer.md`)

Added to both `templates/.claude/agents/code-reviewer.md` and `templates/agent-prompts/code-reviewer.md`:

Reviewer must answer with **actual evidence** before writing output:

1. Are tests passing? → show actual output
2. Are all requirements met? → list each criterion
3. No assumptions? → show code/docs
4. Is there evidence? → file:line citations for every issue

Red flags that trigger a rewrite: `"probably fine"`, `"should pass"`, `"everything works"` without evidence.

### knowledge.md Template Structure

Restructured `conductor/knowledge.md` with 5 clear sections:

- 💡 Core Insights (high-ROI discoveries)
- Tech-specific sections (PostgreSQL, NestJS, FastAPI, Next.js, AI/LLM, Chrome Ext)
- ⚠️ Pitfalls & Solutions (Problem → Solution → Prevention format)
- 🔧 Troubleshooting (specific errors + confirmed fixes)
- 🎓 Lessons Learned (big-picture reflections)

---

## Files Modified / Created


| File                                        | Action                                   | Source                  |
| ------------------------------------------- | ---------------------------------------- | ----------------------- |
| `templates/.claude/agents/*.md` (10 files)  | Updated frontmatter                      | shanraisshan            |
| `templates/.claude/settings.json`           | Permissions + env + hooks                | shanraisshan + ECC      |
| `templates/commands/agent-team.md`          | model frontmatter + init/status handlers | shanraisshan + wshobson |
| `templates/conductor/tracks.md`             | Created                                  | wshobson                |
| `templates/.claude/agents/ba-agent.md`      | Full rewrite                             | wshobson                |
| `templates/commands/checkpoint.md`          | Created                                  | ECC                     |
| `templates/commands/learn.md`               | Created                                  | ECC                     |
| `templates/.claude/agents/code-reviewer.md` | Four Questions section                   | SuperClaude             |
| `templates/agent-prompts/code-reviewer.md`  | Four Questions section                   | SuperClaude             |
| `templates/conductor/knowledge.md`          | Restructured                             | SuperClaude             |
| `scripts/init-new-project.sh`               | tracks.md + commands loop                | wshobson + ECC          |
| `WORKFLOW.md`                               | Created (sequential + parallel diagrams) | Original                |

