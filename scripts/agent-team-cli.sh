#!/usr/bin/env bash
set -euo pipefail

# agent-team-cli.sh — Run agent-team workflow from terminal (Warp, iTerm2, zsh)
#
# Usage:
#   agent-team init "User authentication with JWT"
#   agent-team init --bug "Login page crashes on mobile"
#   agent-team db track-001
#   agent-team backend track-001
#   agent-team frontend track-001
#   agent-team ai track-001
#   agent-team integrate track-001
#   agent-team review track-001
#   agent-team api track-001
#   agent-team extension track-001
#   agent-team setup
#   agent-team status
#   agent-team resume track-001

SUBCOMMAND="${1:-}"

# Ensure we're in a project with .claude/
if [[ "$SUBCOMMAND" != "help" && "$SUBCOMMAND" != "-h" && "$SUBCOMMAND" != "--help" ]]; then
  if [[ ! -d "$(pwd)/.claude" ]]; then
    echo "Error: No .claude/ directory found in $(pwd)"
    echo "Run agent-init first, or cd into your project directory."
    exit 1
  fi
fi

shift || true

# ── Helpers ───────────────────────────────────────────────────────────────────

run_agent() {
  local agent="$1"
  local prompt="$2"
  echo "Launching agent: $agent"
  echo ""
  claude --agent "$agent" "$prompt"
}

run_prompt() {
  local prompt="$1"
  echo ""
  claude "$prompt"
}

# ── Subcommands ───────────────────────────────────────────────────────────────

case "$SUBCOMMAND" in

  init)
    # Check for --bug / --chore / --refactor flag
    BUG_MODE=false
    ARGS=()
    for arg in "$@"; do
      case "$arg" in
        --bug|--fix)    BUG_MODE=true ;;
        --chore)        BUG_MODE=true ;;
        --refactor)     BUG_MODE=true ;;
        *)              ARGS+=("$arg") ;;
      esac
    done

    DESCRIPTION="${ARGS[*]:-}"

    if [[ -z "$DESCRIPTION" ]]; then
      echo "Usage: agent-team init [--bug] \"<description>\""
      exit 1
    fi

    if [[ "$BUG_MODE" == true ]]; then
      run_agent "ba-agent-bug" "Run the BA bug/chore/refactor init flow for: $DESCRIPTION"
    else
      run_agent "ba-agent" "Run the BA feature init flow for: $DESCRIPTION"
    fi
    ;;

  db)
    TRACK="${1:-}"
    [[ -z "$TRACK" ]] && { echo "Usage: agent-team db <track-id>"; exit 1; }
    run_agent "db-engineer" "Run the DB engineer flow for track: $TRACK"
    ;;

  backend)
    TRACK="${1:-}"
    [[ -z "$TRACK" ]] && { echo "Usage: agent-team backend <track-id>"; exit 1; }
    # Auto-detect NestJS vs FastAPI from CLAUDE.md or agent presence
    if [[ -f ".claude/agents/backend-fastapi.md" ]] && ! [[ -f ".claude/agents/backend-nestjs.md" ]]; then
      BACKEND_AGENT="backend-fastapi"
    elif grep -qi "fastapi" "CLAUDE.md" 2>/dev/null && ! grep -qi "nestjs" "CLAUDE.md" 2>/dev/null; then
      BACKEND_AGENT="backend-fastapi"
    else
      BACKEND_AGENT="backend-nestjs"
    fi
    run_agent "$BACKEND_AGENT" "Run the backend dev flow for track: $TRACK"
    ;;

  frontend)
    TRACK="${1:-}"
    [[ -z "$TRACK" ]] && { echo "Usage: agent-team frontend <track-id>"; exit 1; }
    run_agent "frontend-nextjs" "Run the frontend dev flow for track: $TRACK"
    ;;

  ai)
    TRACK="${1:-}"
    [[ -z "$TRACK" ]] && { echo "Usage: agent-team ai <track-id>"; exit 1; }
    run_agent "ai-engineer" "Run the AI engineer flow for track: $TRACK"
    ;;

  integrate)
    TRACK="${1:-}"
    [[ -z "$TRACK" ]] && { echo "Usage: agent-team integrate <track-id>"; exit 1; }
    run_agent "integrator" "Run the integrator flow for track: $TRACK"
    ;;

  review)
    TRACK="${1:-}"
    [[ -z "$TRACK" ]] && { echo "Usage: agent-team review <track-id>"; exit 1; }
    run_agent "code-reviewer" "Run the parallel code review for track: $TRACK"
    ;;

  api)
    TRACK="${1:-}"
    [[ -z "$TRACK" ]] && { echo "Usage: agent-team api <track-id>"; exit 1; }
    run_agent "api-designer" "Run the API designer flow for track: $TRACK"
    ;;

  extension)
    TRACK="${1:-}"
    [[ -z "$TRACK" ]] && { echo "Usage: agent-team extension <track-id>"; exit 1; }
    run_agent "chrome-ext" "Run the Chrome Extension dev flow for track: $TRACK"
    ;;

  setup)
    run_prompt "Run the /agent-team setup workflow: scan this codebase and auto-fill CLAUDE.md, .claude/conductor/product.md, and .claude/conductor/tech-stack.md with detected project context."
    ;;

  status)
    run_prompt "Run the /agent-team status workflow: read .claude/conductor/tracks.md and show a summary table of all tracks with their current phase and suggested next steps."
    ;;

  resume)
    TRACK="${1:-}"
    [[ -z "$TRACK" ]] && { echo "Usage: agent-team resume <track-id>"; exit 1; }
    run_prompt "Run the /agent-team resume workflow for track: $TRACK. Read the track file, report current phase and next step."
    ;;

  help|-h|--help)
    echo ""
    echo "agent-team — Run agent team workflows from terminal"
    echo ""
    echo "Usage:"
    echo "  agent-team init \"<description>\"       BA spec + API contract (feature)"
    echo "  agent-team init --bug \"<description>\"  Bug report / chore spec (Sonnet)"
    echo "  agent-team db <track-id>               DB schema + migrations"
    echo "  agent-team backend <track-id>          Backend services + endpoints"
    echo "  agent-team frontend <track-id>         Frontend routes + components"
    echo "  agent-team ai <track-id>               AI/LLM integration"
    echo "  agent-team integrate <track-id>        Wire frontend ↔ backend"
    echo "  agent-team review <track-id>           Parallel 9-reviewer code review"
    echo "  agent-team api <track-id>              OpenAPI spec generation"
    echo "  agent-team extension <track-id>        Chrome Extension dev"
    echo "  agent-team setup                       Scan codebase, auto-fill context files"
    echo "  agent-team status                      Show all track statuses"
    echo "  agent-team resume <track-id>           Resume an in-progress track"
    echo ""
    echo "Note: Must be run from inside a project directory (with .claude/)"
    echo ""
    ;;

  "")
    echo "Usage: agent-team <subcommand> [args]"
    echo "Run 'agent-team help' for full command list."
    exit 1
    ;;

  *)
    echo "Unknown subcommand: $SUBCOMMAND"
    echo "Run 'agent-team help' for full command list."
    exit 1
    ;;
esac
