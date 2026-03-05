# Claude Agent Team

A framework for integrating structured AI agent team workflows into any project.
Agents run natively in Claude Code via `.claude/agents/` — no manual prompt pasting needed.

## How It Works

1. Run the init script to scaffold your project
2. Claude Code auto-detects agents in `.claude/agents/`
3. Use `/agent-team` slash commands to advance through the pipeline
4. Each agent writes output to its section in the track file — the next agent picks up from there

---

## Architecture

```
~/Projects/AI/claude-agent-team/          ← Template hub (this repo)
├── templates/
│   ├── CLAUDE.md.template                ← Per-project CLAUDE.md
│   ├── .claude/agents/                   ← Native agent files (YAML frontmatter)
│   │   ├── ba-agent.md                   │  model: opus  | confidence gate
│   │   ├── code-reviewer.md              │  model: opus
│   │   ├── db-engineer.md                │  model: sonnet
│   │   ├── backend-nestjs.md             │  model: sonnet
│   │   ├── backend-fastapi.md            │  model: sonnet
│   │   ├── frontend-nextjs.md            │  model: sonnet
│   │   ├── integrator.md                 │  model: sonnet
│   │   ├── ai-engineer.md                │  model: sonnet
│   │   ├── chrome-ext.md                 │  model: sonnet
│   │   └── api-designer.md               │  model: sonnet
│   ├── .claude/conductor/
│   │   ├── product.md                    ← Product vision template
│   │   ├── tech-stack.md                 ← Tech decisions template
│   │   ├── workflow.md                   ← Team rules template
│   │   ├── knowledge.md                  ← Accumulated lessons template
│   │   └── track-template.md             ← Track file format
│   ├── team-configs/                     ← Pipeline configs per team type
│   ├── agent-prompts/                    ← Reference copies (plain markdown)
│   └── commands/agent-team.md            ← /agent-team slash command
├── scripts/
│   ├── init-new-project.sh               ← Scaffold new project
│   └── add-to-existing.sh                ← Add to existing project
└── COMPARISON.md                         ← Analysis vs reference repos

my-project/                               ← Your project
├── CLAUDE.md                             ← Project context + stack
├── .claude/
│   ├── agents/                           ← Copied from templates, auto-detected
│   │   ├── ba-agent.md
│   │   ├── code-reviewer.md
│   │   └── ...
│   └── commands/agent-team.md            ← /agent-team slash command
└── .claude/conductor/
    ├── product.md
    ├── tech-stack.md
    ├── workflow.md
    ├── knowledge.md                      ← Lessons learned across tracks
    ├── team-config.md
    └── tracks/
        └── track-001-feature.md          ← Full agent handoff chain
```

---

## Quick Start

### New Project

```bash
./scripts/init-new-project.sh ~/Projects/my-app --type fullstack-web
```

### Existing Project

```bash
./scripts/add-to-existing.sh ~/Projects/existing-app --type api-only
```

### Team Types

| Type | Pipeline |
|------|---------|
| `fullstack-web` | BA → DB → Backend → Frontend → Integrator → Reviewer |
| `api-only` | BA → DB → Backend → API Designer → Reviewer |
| `ai-llm-app` | BA → Backend → AI Engineer → Frontend → Reviewer |
| `chrome-extension` | BA → Frontend → Chrome Ext Dev → Reviewer |

---

## Daily Workflow

```bash
# Start a new feature — BA agent activates automatically
/agent-team init "User authentication with JWT"

# Parallel: DB schema + Frontend UI simultaneously (recommended)
/agent-team parallel db frontend track-001

# Or sequential
/agent-team db track-001
/agent-team frontend track-001

# Backend reads DB schema + API contract
/agent-team backend track-001

# Wire frontend to backend (fullstack-web only)
/agent-team integrate track-001

# Review before merge
/agent-team review track-001

# Check all active tracks
/agent-team status
```

---

## Agents Reference

| Agent | Model | Activates on |
|-------|-------|-------------|
| BA | Opus | `/agent-team init` |
| DB Engineer | Sonnet | `/agent-team db` |
| Backend (NestJS) | Sonnet | `/agent-team backend` (NestJS projects) |
| Backend (FastAPI) | Sonnet | `/agent-team backend` (FastAPI projects) |
| Frontend (Next.js) | Sonnet | `/agent-team frontend` |
| AI Engineer | Sonnet | `/agent-team ai` |
| Chrome Ext Dev | Sonnet | `/agent-team extension` |
| Integrator | Sonnet | `/agent-team integrate` |
| API Designer | Sonnet | `/agent-team api` |
| Code Reviewer | Opus | `/agent-team review` |

**BA and Code Reviewer use Opus** — they make the highest-stakes decisions (spec correctness, security).

---

## Track File Format

Each `.claude/conductor/tracks/track-NNN-slug.md` captures the full agent handoff chain:

```
Track header (ID, status, phase, next step)
├── 📋 BA Output        ← Spec, user stories, acceptance criteria, complexity estimate
├── 📐 API Contract     ← Endpoints + schemas defined by BA — unlocks parallel execution
├── 🗄️ DB Output        ← Schema DDL, migrations, indexes
├── ⚙️ Backend Output   ← Module structure, business logic, files created
├── 🎨 Frontend Output  ← Routes, component tree, state management
├── 🔗 Integrator       ← React Query hooks, API wiring, contract verification
└── 🔍 Code Review      ← Issues by severity, approval status
```

The **API Contract** is the key to parallel execution: once BA fills it in, DB Engineer and Frontend Developer can work simultaneously without depending on each other.

---

## Key Design Principles

**Confidence gate (BA):** Before writing any spec, the BA agent assesses confidence:
- ≥90% → proceeds directly
- 70–89% → presents interpretations, asks user to choose
- <70% → asks clarifying questions first

**Model tier strategy:**
- Opus for BA + Reviewer (critical decisions — spec accuracy, security)
- Sonnet for all implementation agents (cost-efficient for dev work)

**Accumulated knowledge:** `.claude/conductor/knowledge.md` persists lessons learned across tracks so agents don't repeat the same mistakes (PostgreSQL gotchas, NestJS patterns, etc.)
