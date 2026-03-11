# Claude Agent Team

A framework for integrating structured AI agent team workflows into any project.
Agents run natively in Claude Code via `.claude/agents/` — no manual prompt pasting needed.
Projects can now declare neutral engineering conventions in `.claude/conductor/project-conventions.md`
so agents follow the selected archetype, folder contract, and data/state patterns automatically.

## How It Works

1. Run the init script to scaffold your project
2. Open your project in Claude Code (VSCode or terminal)
3. Use `/agent-team` slash commands to advance through the pipeline
4. Each agent writes output to its section in the track file — the next agent picks up from there

---

## Architecture

```
~/Projects/AI/claude-agent-team/          ← Template hub (this repo)
├── templates/
│   ├── CLAUDE.md.template                ← Per-project CLAUDE.md
│   ├── .claude/agents/                   ← Native agent files (YAML frontmatter)
│   │   ├── ba-agent.md                   │  model: opus   | features only (spec + API contract)
│   │   ├── ba-agent-bug.md               │  model: sonnet | bugs, chores, refactors
│   │   ├── code-reviewer.md              │  model: sonnet | parallel 9-reviewer orchestrator
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
│   │   ├── project-conventions.md        ← Neutral archetype + pattern selection
│   │   ├── tech-stack.md                 ← Tech decisions template
│   │   ├── workflow.md                   ← Team rules template
│   │   ├── knowledge.md                  ← Accumulated lessons template
│   │   └── track-template.md             ← Track file format
│   ├── convention-presets/               ← Ready-to-copy neutral convention manifests
│   ├── team-configs/                     ← Pipeline configs per team type
│   ├── agent-prompts/                    ← Reference copies (plain markdown)
│   └── commands/agent-team.md            ← /agent-team slash command
├── scripts/
│   ├── init-new-project.sh               ← Scaffold new project
│   ├── add-to-existing.sh                ← Add to existing project
│   ├── remove-from-project.sh            ← Remove agent team from project
│   └── upgrade-project.sh                ← Sync latest templates into project
└── COMPARISON.md                         ← Analysis vs reference repos

my-project/                               ← Your project
├── CLAUDE.md                             ← Project context + stack
├── .claude/
│   ├── agents/                           ← Copied from templates, auto-detected
│   │   ├── ba-agent.md
│   │   ├── ba-agent-bug.md
│   │   ├── code-reviewer.md
│   │   └── ...
│   └── commands/agent-team.md            ← /agent-team slash command
└── .claude/conductor/
    ├── product.md
    ├── project-conventions.md            ← Project-specific convention manifest
    ├── tech-stack.md
    ├── workflow.md
    ├── knowledge.md                      ← Lessons learned across tracks
    ├── team-config.md
    └── tracks/
        └── track-001-feature.md          ← Full agent handoff chain
```

---

## Quick Start

### Install globally (recommended)

```bash
# Run in terminal (Warp, iTerm, zsh — any shell)
./setup.sh
source ~/.zshrc   # or ~/.bashrc

agent-init    ~/Projects/my-app --type fullstack-web --convention-preset feature-saas-react-query-zustand
agent-add     ~/Projects/existing-app --type api-only
agent-remove  ~/Projects/my-app
agent-upgrade ~/Projects/my-app
```

> After init, open the project in **VSCode** to use `/agent-team` slash commands.

### Run from terminal (Warp / iTerm2)

If you prefer the terminal, use the `agent-team` CLI alias (installed by `setup.sh`):

```bash
# Must be run from inside your project directory (with .claude/)
cd ~/Projects/my-app

agent-team init "User authentication with JWT"   # feature (Opus)
agent-team init --bug "Login crashes on mobile"  # bug/chore (Sonnet)
agent-team db track-001
agent-team backend track-001
agent-team frontend track-001
agent-team integrate track-001
agent-team review track-001
agent-team status
agent-team resume track-001
```

> The terminal CLI uses `claude --agent <name>` to invoke agents directly — no VSCode required.

### Or run scripts directly

```bash
./scripts/init-new-project.sh    ~/Projects/my-app --type fullstack-web --convention-preset feature-saas-react-query-zustand
./scripts/add-to-existing.sh     ~/Projects/existing-app --type api-only
./scripts/remove-from-project.sh ~/Projects/my-app
./scripts/upgrade-project.sh     ~/Projects/my-app
```

### Upgrade flags

```bash
agent-upgrade ~/Projects/my-app                  # update agents, commands, skills to latest
agent-upgrade ~/Projects/my-app --dry-run        # preview what would change
agent-upgrade ~/Projects/my-app --type api-only  # override team type (auto-detected by default)
agent-upgrade ~/Projects/my-app --convention-preset workspace-modular-rtk-query
```

### Convention Presets

The generated project convention manifest lives at `.claude/conductor/project-conventions.md`.
It controls:

- selected archetype
- required patterns
- forbidden patterns
- folder contract
- agent resolution rules
- project-level overrides

Built-in neutral presets:

| Preset | Archetype | Data/state pattern |
|--------|-----------|--------------------|
| `feature-saas-react-query-zustand` | `nextjs-feature-saas` | React Query + Zustand |
| `workspace-modular-rtk-query` | `nextjs-workspace-modular` | RTK Query |

Agents read this manifest before frontend, backend, integration, and review work. They record a short `Convention Resolution` section in the active track before proposing implementation details.

### Remove flags

```bash
agent-remove ~/Projects/my-app                   # remove everything (confirms CLAUDE.md)
agent-remove ~/Projects/my-app --keep-tracks     # preserve .claude/conductor/tracks/ history
agent-remove ~/Projects/my-app --dry-run         # preview without deleting
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

**In VSCode** (slash commands):
```bash
/agent-team setup
/agent-team init "User authentication with JWT"
/agent-team parallel db frontend track-001
/agent-team backend track-001
/agent-team integrate track-001
/agent-team review track-001
/agent-team status
```

**In terminal** (Warp / iTerm2):
```bash
cd ~/Projects/my-app

agent-team setup
agent-team init "User authentication with JWT"
agent-team db track-001
agent-team frontend track-001
agent-team backend track-001
agent-team integrate track-001
agent-team review track-001
agent-team status
```

> Note: `parallel` sub-command is VSCode-only. In terminal, run `db` and `frontend` sequentially.

---

## Agents Reference

| Agent | Model | Activates on |
|-------|-------|-------------|
| Setup | Sonnet | `/agent-team setup` |
| BA (feature) | **Opus** | `/agent-team init` — feature tracks |
| BA (bug/chore/refactor) | Sonnet | `/agent-team init` — bug, chore, refactor tracks |
| DB Engineer | Sonnet | `/agent-team db` |
| Backend (NestJS) | Sonnet | `/agent-team backend` (NestJS projects) |
| Backend (FastAPI) | Sonnet | `/agent-team backend` (FastAPI projects) |
| Frontend (Next.js) | Sonnet | `/agent-team frontend` |
| AI Engineer | Sonnet | `/agent-team ai` |
| Chrome Ext Dev | Sonnet | `/agent-team extension` |
| Integrator | Sonnet | `/agent-team integrate` |
| API Designer | Sonnet | `/agent-team api` |
| Code Reviewer | Sonnet | `/agent-team review` |

**Only the feature BA uses Opus** — writing full specs with API contracts requires the deepest reasoning. All other agents, including the Code Reviewer, run on Sonnet.

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
├── 🔗 Integrator       ← Selected data client wiring, API contract verification
└── 🔍 Code Review      ← Issues by severity, approval status
```

The **API Contract** is the key to parallel execution: once BA fills it in, DB Engineer and Frontend Developer can work simultaneously without depending on each other.

The **Project Conventions** manifest is the key to convention-aware implementation: once selected, all downstream agents resolve the same archetype and pattern set before making code decisions.

---

## Key Design Principles

**Confidence gate (BA):** Before writing any spec, the BA agent assesses confidence:
- ≥90% → proceeds directly
- 70–89% → presents interpretations, asks user to choose
- <70% → asks clarifying questions first

**Model tier strategy:**
- Opus for feature BA only (complex spec + API contract requires deep reasoning)
- Sonnet for bug/chore BA, Code Reviewer, and all implementation agents (cost-efficient)

**Accumulated knowledge:** `.claude/conductor/knowledge.md` persists lessons learned across tracks so agents don't repeat the same mistakes (PostgreSQL gotchas, NestJS patterns, etc.)

**Auto-approved permissions:** The generated `.claude/settings.json` grants Claude full Read/Write/Edit access across the project so agents never pause to ask for file permission. Git commands are also pre-approved. To restrict access, edit the `permissions.allow` list in `.claude/settings.json`.
