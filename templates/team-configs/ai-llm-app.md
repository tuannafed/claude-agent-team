# Team Config: AI/LLM Application

**Stack:** FastAPI (or NestJS) + Next.js + PostgreSQL + vector DB (pgvector/Qdrant)

## Agent Pipeline

```
BA → Backend Dev → AI Engineer → Frontend Dev → Code Reviewer
```

## Agent Responsibilities

| Order | Agent | Phase Key | Input | Output |
|-------|-------|-----------|-------|--------|
| 1 | BA | `ba` | CLAUDE.md + product.md | Spec, AI feature requirements, prompts design |
| 2 | Backend Dev | `backend` | BA spec | API endpoints, data models, storage |
| 3 | AI Engineer | `ai` | Backend APIs + BA spec | LLM integration, RAG, prompt templates, embeddings |
| 4 | Frontend Dev | `frontend` | AI/Backend APIs | Chat UI, streaming, AI output rendering |
| 5 | Code Reviewer | `review` | All above | Issues, prompt safety, cost analysis |

## Slash Commands

```
/agent-team init "<feature>"    → BA (creates track)
/agent-team backend <track-id>  → Backend Dev
/agent-team ai <track-id>       → AI Engineer
/agent-team frontend <track-id> → Frontend Dev
/agent-team review <track-id>   → Code Reviewer
/agent-team status              → Track summary
```

## Agent Prompts

- BA: `~/Projects/AI/claude-agent-team/templates/agent-prompts/ba.md`
- Backend (FastAPI): `~/Projects/AI/claude-agent-team/templates/agent-prompts/backend-fastapi.md`
- AI Engineer: `~/Projects/AI/claude-agent-team/templates/agent-prompts/ai-engineer.md`
- Frontend (Next.js): `~/Projects/AI/claude-agent-team/templates/agent-prompts/frontend-nextjs.md`
- Code Reviewer: `~/Projects/AI/claude-agent-team/templates/agent-prompts/code-reviewer.md`

## AI-Specific Quality Gates

- Prompt templates must be version-controlled
- LLM costs estimated per feature
- Rate limiting and error handling for LLM calls required
- Streaming responses must handle partial failures
- No sensitive data sent to external LLM APIs without review
