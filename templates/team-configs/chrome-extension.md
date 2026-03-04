# Team Config: Chrome Extension / Tools

**Stack:** TypeScript + Manifest V3 + React (popup/options) + Chrome APIs

## Agent Pipeline

```
BA → Frontend Dev → Chrome Ext Dev → Code Reviewer
```

## Agent Responsibilities

| Order | Agent | Phase Key | Input | Output |
|-------|-------|-----------|-------|--------|
| 1 | BA | `ba` | CLAUDE.md + product.md | Spec, Chrome API requirements, permissions needed |
| 2 | Frontend Dev | `frontend` | BA spec | Popup UI, options page, content script UI |
| 3 | Chrome Ext Dev | `extension` | Frontend + BA | Background service worker, content scripts, manifest.json |
| 4 | Code Reviewer | `review` | All above | Issues, permission audit, store policy compliance |

## Slash Commands

```
/agent-team init "<feature>"     → BA (creates track)
/agent-team frontend <track-id>  → Frontend Dev
/agent-team extension <track-id> → Chrome Ext Dev
/agent-team review <track-id>    → Code Reviewer
/agent-team status               → Track summary
```

## Agent Prompts

- BA: `~/Projects/AI/claude-agent-team/templates/agent-prompts/ba.md`
- Frontend: `~/Projects/AI/claude-agent-team/templates/agent-prompts/frontend-nextjs.md`
- Chrome Ext Dev: `~/Projects/AI/claude-agent-team/templates/agent-prompts/chrome-ext.md`
- Code Reviewer: `~/Projects/AI/claude-agent-team/templates/agent-prompts/code-reviewer.md`

## Extension-Specific Quality Gates

- Manifest V3 compliance (no Manifest V2 patterns)
- Minimum permissions principle — only request what's needed
- Content Security Policy (CSP) headers correct
- No remote code execution
- Chrome Web Store policy compliance check
