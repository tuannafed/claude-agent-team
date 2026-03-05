# Tech Stack: {{PROJECT_NAME}}

## Decided Stack

| Layer | Technology | Version | Reason |
|-------|-----------|---------|--------|
| Frontend | {{FRONTEND}} | {{VERSION}} | {{REASON}} |
| Backend | {{BACKEND}} | {{VERSION}} | {{REASON}} |
| Database | {{DATABASE}} | {{VERSION}} | {{REASON}} |
| Auth | {{AUTH}} | — | {{REASON}} |
| Cache | {{CACHE}} | {{VERSION}} | {{REASON}} |
| Queue | {{QUEUE}} | — | {{REASON}} |
| Deployment | {{DEPLOY_TARGET}} | — | {{REASON}} |

## Architecture Decisions (ADRs)

### ADR-001: {{DECISION_TITLE}}
- **Date:** {{DATE}}
- **Decision:** {{DECISION}}
- **Rationale:** {{RATIONALE}}
- **Consequences:** {{CONSEQUENCES}}

## Coding Conventions

- **Language:** {{LANGUAGE}} / {{STRICT_MODE}}
- **Formatter:** {{FORMATTER}}
- **Linter:** {{LINTER}}
- **Test framework:** {{TEST_FRAMEWORK}}
- **Package manager:** {{PKG_MANAGER}}

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://...` |
| `JWT_SECRET` | JWT signing secret | `...` |
| `{{ENV_VAR}}` | {{DESCRIPTION}} | `{{EXAMPLE}}` |

## Folder Structure

```
src/
├── {{LAYER_1}}/      # {{PURPOSE}}
├── {{LAYER_2}}/      # {{PURPOSE}}
└── {{LAYER_3}}/      # {{PURPOSE}}
```
