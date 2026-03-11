# Skills Manifest

Quick reference: which skills each agent reads.

## Shared Skill Categories

- Root skills: framework-agnostic or legacy compatibility skills copied into `.claude/skills/*.md`
- `shared/`: workflow helpers that all convention-aware agents can read
- `archetypes/`: neutral structural conventions for project shapes
- `patterns/`: focused implementation patterns that vary per project

## Convention-Aware Skills

| Skill Path | BA | DB | NestJS | FastAPI | Frontend | Integrator | Reviewer |
|-----------|----|----|--------|---------|----------|------------|----------|
| `shared/convention-resolution.md` | | | ✅ | ✅ | ✅ | ✅ | ✅ |
| `archetypes/nextjs-feature-saas.md` | | | | | ✅ | ✅ | ✅ |
| `archetypes/nextjs-workspace-modular.md` | | | | | ✅ | ✅ | ✅ |
| `patterns/feature-folder-architecture.md` | | | ✅ | ✅ | ✅ | ✅ | ✅ |
| `patterns/react-query-zustand.md` | | | | | ✅ | ✅ | ✅ |
| `patterns/rtk-query-standard.md` | | | | | ✅ | ✅ | ✅ |
| `patterns/typed-api-client-standard.md` | | | ✅ | ✅ | ✅ | ✅ | ✅ |
| `patterns/permission-aware-ui.md` | | | | | ✅ | ✅ | ✅ |

## Core Skill → Agent Matrix

| Skill | BA | DB | NestJS | FastAPI | Frontend | Integrator | Reviewer |
|-------|----|----|--------|---------|----------|------------|----------|
| `api-contract` | ✅ | | ✅ | ✅ | ✅ | ✅ | |
| `security-baseline` | | | ✅ | ✅ | | | ✅ |
| `testing-strategy` | | | ✅ | ✅ | ✅ | | ✅ |
| `git-workflow` | | | ✅ | ✅ | ✅ | ✅ | |
| `typescript-patterns` | | | ✅ | | ✅ | | ✅ |
| `database-patterns` | | ✅ | | | | | ✅ |
| `nestjs-patterns` | | | ✅ | | | | ✅ |
| `fastapi-patterns` | | | | ✅ | | | ✅ |
| `nextjs-patterns` | | | | | ✅ | ✅ | ✅ |
| `react-query-patterns` | | | | | optional | optional | |
| `error-handling-patterns` | | | ✅ | ✅ | | ✅ | ✅ |
| `form-validation-patterns` | | | | | ✅ | | ✅ |

## Domain-Specific Skills (copy only for relevant projects)

| Skill | When to copy | Agents |
|-------|-------------|--------|
| `chrome-extension-mv3` | Chrome extension projects | chrome-ext, code-reviewer |
| `prompt-engineering` | AI/LLM projects | ai-engineer |
| `rag-architecture` | RAG/chatbot projects | ai-engineer |

## Convention Presets

- `feature-saas-react-query-zustand`
- `workspace-modular-rtk-query`

Each preset writes `.claude/conductor/project-conventions.md` and references neutral archetype/pattern skills. Local project overrides in that manifest take precedence over the preset defaults.
