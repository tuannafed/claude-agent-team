# Comparative Analysis: Claude Agent Team Frameworks

> Reviewed: 2026-03-04
> Repos analyzed vs our `claude-agent-team` implementation

---

## Repos Reviewed

| Repo | Focus | Stars pattern |
|------|-------|--------------|
| [shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice) | Best practices & native Claude Code features | Reference impl |
| [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) | Production-ready cross-platform plugin | 13 agents, 50+ skills |
| [wshobson/agents](https://github.com/wshobson/agents) | Plugin marketplace | 72 plugins, 112 agents, 146 skills |
| [SuperClaude-Org/SuperClaude_Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) | Python package + PM Agent patterns | installable via pipx |

---

## Repo Profiles

### 1. shanraisshan/claude-code-best-practice

**Pattern:** `Command → Agent → Skill` orchestration hierarchy

**Key architecture:**
```
.claude/
├── agents/*.md          ← YAML frontmatter (name, model, tools, skills, hooks, context)
├── skills/<name>/SKILL.md
├── commands/*.md
└── settings.json        ← hooks config
```

**YAML frontmatter example:**
```yaml
---
name: weather-agent
description: PROACTIVELY fetch weather when user asks about temperature
model: haiku
tools: Read, Bash
skills:
  - weather-fetcher
context: fork          # isolated subagent execution
hooks:
  Stop: echo "done"
---
[agent instructions here]
```

**Key insights:**
- Agent Skills = preloaded into agent context via `skills:` field (không phải invoke thủ công)
- `context: fork` = chạy trong isolated subagent, không pollute main context
- Self-evolving agents: agent tự update skills của mình sau mỗi lần chạy
- Hooks: PreToolUse, PostToolUse, SessionStart/End, SubagentStart/Stop, TaskCompleted...
- **Lesson:** CLAUDE.md < 150 lines; dùng commands cho workflows, không dùng standalone agents

---

### 2. affaan-m/everything-claude-code

**Pattern:** Agent-First + proactive auto-delegation (không cần user prompt)

**Key architecture:**
```
.agents/         ← cross-platform agent definitions
.claude/         ← Claude Code specific
.cursor/         ← Cursor IDE
.codex/          ← OpenAI Codex
.opencode/       ← OpenCode
agents/          ← 13 specialized subagents
skills/          ← 50+ workflow skills
commands/        ← 33 slash commands
hooks/           ← trigger-based automations
rules/           ← always-follow guidelines per language
mcp-configs/     ← 14 pre-configured MCP server configs
```

**Core principles:**
- Agent-First: delegate to specialized agents for domain tasks
- Proactive orchestration: agent tự activate khi phát hiện context phù hợp
- Security-First + TDD mandatory (80%+ coverage)
- AGENTS.md = central instruction file (cả Codex + Claude đọc)

**Orchestration rules:**
```
Complex feature     → planner agent
Code just written   → code-reviewer agent (auto, no prompt)
Bug fix / new feat  → tdd-guide agent
Arch decision       → architect agent
Security code       → security-reviewer agent
```

---

### 3. wshobson/agents

**Pattern:** Plugin marketplace + progressive disclosure + three-tier model strategy

**Key architecture:**
```
plugins/
├── python-development/
│   ├── agents/       ← specialized agents
│   ├── commands/     ← tools
│   └── skills/       ← 5 specialized skills
├── conductor/        ← rất giống approach của chúng ta!
└── agent-teams/      ← 7 team presets
.claude-plugin/
└── marketplace.json  ← 72 plugin definitions
```

**Three-tier model strategy:**
| Tier | Model | Use case |
|------|-------|---------|
| 1 | Opus 4.6 | Critical: architecture, ALL code review, security, BA |
| 2 | Inherit | Complex: AI/ML, backend, frontend (user controls) |
| 3 | Sonnet 4.6 | Support: docs, testing, debugging, API docs |
| 4 | Haiku 4.5 | Fast ops: SEO, deployment, simple queries, status |

**Progressive disclosure (token efficiency):**
```
Tier 1: Metadata only (always loaded — name + when to activate)
Tier 2: Instructions (loaded when skill activated)
Tier 3: Resources/examples (loaded on demand)
```

**Conductor plugin** (giống chúng ta nhất):
- `/conductor:setup` → tạo product vision, tech stack, workflow rules
- `/conductor:new-track` → spec + phased implementation plan
- `/conductor:implement` → TDD workflow với verification checkpoints
- State persistence across sessions

**Agent Teams presets:** review, debug, feature, fullstack, research, security, migration

---

### 4. SuperClaude-Org/SuperClaude_Framework

**Pattern:** Confidence-First + Wave→Checkpoint→Wave parallel execution

**Key architecture:**
```
src/superclaude/
├── pm_agent/
│   ├── confidence.py      ← ConfidenceChecker
│   ├── self_check.py      ← SelfCheckProtocol
│   └── reflexion.py       ← ReflexionPattern
└── execution/
    └── parallel.py        ← Wave→Checkpoint→Wave
.claude/commands/           ← 30 slash commands (installed via pipx)
PLANNING.md                 ← Architecture & absolute rules
TASK.md                     ← Current tasks
KNOWLEDGE.md                ← Accumulated learnings ← KEY
```

**PM Agent — 3 patterns:**
```
ConfidenceChecker:
  ≥ 90% → proceed
  70–89% → present alternatives
  < 70%  → ask questions first (prevent wasted work)

SelfCheckProtocol:
  Post-implementation validation with evidence (no speculation)

ReflexionPattern:
  Error learning + cross-session pattern matching
```

**Token budgeting:**
```
Simple (typo fix):        200 tokens
Medium (bug fix):       1,000 tokens
Complex (new feature):  2,500 tokens
Confidence check ROI: spend 100–200 to save 5,000–50,000
```

**Wave→Checkpoint→Wave parallel:**
```
[Read file A] [Read file B] [Read file C]   ← Wave 1 (parallel)
         ↓ Checkpoint: analyze
[Edit file A] [Edit file B]                 ← Wave 2 (parallel)
```
→ 3.5x faster than sequential

---

## Comparison: Chúng ta vs Họ

### Chúng ta LÀM TỐT HƠN

| Điểm mạnh | Chi tiết |
|-----------|---------|
| **Domain team pipelines** | Không repo nào có explicit BA→DB→Backend→Frontend với handoff documents |
| **Track-based state** | Full agent decision chain trong 1 file, resumable bất kỳ lúc nào |
| **Parallel via API Contract** | BA defines contract → DB + Frontend unlock song song — design rõ ràng |
| **Business context layers** | product.md + tech-stack.md + workflow.md = persistent project memory |
| **Scaffolding scripts** | init-new-project.sh + add-to-existing.sh cho cả new lẫn existing project |

### Họ LÀM TỐT HƠN — Gaps cần cải thiện

#### 🔴 Gap 1: Không dùng Claude Code native agent format (Critical)

**Hiện tại:** Markdown templates phải paste thủ công vào conversation.

**Đúng phải là:** `.claude/agents/*.md` với YAML frontmatter → Claude Code tự detect, tự activate:
```yaml
---
name: ba-agent
description: PROACTIVELY activate when user runs /agent-team init or starts a new feature
model: opus
tools: Read, Write, Glob, Grep
context: fork
---
[ba prompt content]
```
→ Không cần paste. Claude tự dùng đúng model, đúng tools, isolated context.

#### 🔴 Gap 2: Không có model tier strategy

**Hiện tại:** Tất cả agents dùng cùng model (mặc định session model).

**Nên làm:**
```
BA Agent        → opus   (critical: spec phải chính xác)
Code Reviewer   → opus   (critical: security + quality)
Backend Dev     → sonnet (main dev work)
Frontend Dev    → sonnet (main dev work)
DB Engineer     → sonnet (schema design)
Integrator      → sonnet
Status check    → haiku  (fast, cheap)
```

#### 🟡 Gap 3: Không có confidence gate

**Hiện tại:** BA bắt đầu viết spec ngay.

**Nên làm (SuperClaude pattern):**
```
Trước khi viết spec, BA tự đánh giá:
- ≥ 90% confident về requirements → proceed
- 70–89% → đưa ra 2-3 interpretations, hỏi user chọn
- < 70%  → list questions, KHÔNG viết spec vội
```
→ Tránh viết spec sai hướng, tốn tokens toàn team

#### 🟡 Gap 4: Không có KNOWLEDGE.md

**Hiện tại:** Learnings bị mất sau mỗi session.

**Nên làm:** `conductor/knowledge.md` lưu lessons learned:
```markdown
## Lessons Learned

### PostgreSQL
- Dùng `gen_random_uuid()` không phải `uuid_generate_v4()` (cần extension)
- JSONB index: dùng GIN, không phải B-tree

### NestJS
- class-transformer phải enable trong main.ts
- Circular dependency: dùng forwardRef()
```

#### 🟢 Gap 5: Không có progressive disclosure

**Hiện tại:** Load toàn bộ agent prompt mỗi lần (~500-1000 tokens/agent).

**Nên làm:** Split agent prompts thành 3 tiers (metadata → instructions → resources).

#### 🟢 Gap 6: Không có hooks

**Nên làm (low priority):**
- `SessionStart`: auto show `/agent-team status`
- `PostToolUse` (Write): remind update track file

---

## Improvements Roadmap

### Priority 1 — High Impact, Low Effort

- [ ] Convert `templates/agent-prompts/*.md` → `templates/.claude/agents/*.md` với YAML frontmatter
- [ ] Thêm model assignments (opus/sonnet/haiku) vào từng agent
- [ ] Thêm confidence check section vào BA agent prompt
- [ ] Thêm `templates/conductor/knowledge.md` template
- [ ] Update `scripts/init-new-project.sh` để tạo `.claude/agents/` directory

### Priority 2 — Medium Impact

- [ ] Thêm model tier guide vào `templates/CLAUDE.md.template`
- [ ] Token budget estimate per track size (S/M/L/XL)
- [ ] `context: fork` cho BA và Reviewer agents (isolated execution)

### Priority 3 — Low Priority

- [ ] Hooks: SessionStart → auto `/agent-team status`
- [ ] Cross-platform support (`.cursor/`, `.codex/`) cho agent prompts
- [ ] Progressive disclosure: split agent prompts thành metadata/instructions/resources

---

## Key Takeaway

**Kiến trúc của chúng ta unique ở domain-specific team workflows và track-based handoff.**
**Điều cần fix ngay là format: convert sang native `.claude/agents/` để không phải paste thủ công.**

Sau khi fix Gap 1+2: open project → Claude tự detect agents → `/agent-team init "feature"` → BA agent tự activate với Opus, không cần làm gì thêm.
