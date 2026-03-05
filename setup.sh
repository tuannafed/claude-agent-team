#!/usr/bin/env bash
set -euo pipefail

# setup.sh — Install claude-agent-team globally
#
# Adds shell aliases so you can run from any directory:
#   agent-init    <path> --type <type>   → init new project
#   agent-add     <path> --type <type>   → add to existing project
#   agent-remove  <path>                 → remove agent team from project
#   agent-upgrade <path>                 → sync latest templates into existing project
#
# Usage:
#   ./setup.sh              → install
#   ./setup.sh --uninstall  → remove aliases

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$REPO_DIR/scripts"

MARKER_START="# >>> claude-agent-team >>>"
MARKER_END="# <<< claude-agent-team <<<"

# ── Detect shell config file ──────────────────────────────────────────────────
detect_shell_rc() {
  if [[ -n "${ZDOTDIR:-}" ]] && [[ -f "$ZDOTDIR/.zshrc" ]]; then
    echo "$ZDOTDIR/.zshrc"
  elif [[ -f "$HOME/.zshrc" ]]; then
    echo "$HOME/.zshrc"
  elif [[ -f "$HOME/.bashrc" ]]; then
    echo "$HOME/.bashrc"
  elif [[ -f "$HOME/.bash_profile" ]]; then
    echo "$HOME/.bash_profile"
  else
    echo "$HOME/.profile"
  fi
}

# ── Uninstall ─────────────────────────────────────────────────────────────────
uninstall() {
  local rc_file
  rc_file="$(detect_shell_rc)"

  if ! grep -q "$MARKER_START" "$rc_file" 2>/dev/null; then
    echo "ℹ️  claude-agent-team is not installed in $rc_file"
    exit 0
  fi

  # Remove lines between markers (inclusive)
  local tmp
  tmp="$(mktemp)"
  awk "/$MARKER_START/{found=1} !found{print} /$MARKER_END/{found=0}" "$rc_file" > "$tmp"
  mv "$tmp" "$rc_file"

  echo "✅ Uninstalled from $rc_file"
  echo "   Run: source $rc_file"
}

# ── Install ───────────────────────────────────────────────────────────────────
install() {
  local rc_file
  rc_file="$(detect_shell_rc)"

  echo "🚀 Installing claude-agent-team"
  echo "   Repo: $REPO_DIR"
  echo "   Shell config: $rc_file"
  echo ""

  # Check if already installed
  if grep -q "$MARKER_START" "$rc_file" 2>/dev/null; then
    echo "⚠️  Already installed in $rc_file"
    echo ""
    echo "To reinstall: ./setup.sh --uninstall && ./setup.sh"
    echo "To remove:    ./setup.sh --uninstall"
    exit 0
  fi

  # Make scripts executable
  chmod +x "$SCRIPTS_DIR/init-new-project.sh"
  chmod +x "$SCRIPTS_DIR/add-to-existing.sh"
  chmod +x "$SCRIPTS_DIR/remove-from-project.sh"
  chmod +x "$SCRIPTS_DIR/upgrade-project.sh"

  # Append block to shell rc
  cat >> "$rc_file" <<EOF

$MARKER_START
# claude-agent-team — AI agent workflow framework
export AGENT_TEAM_HOME="$REPO_DIR"

# Init new project with agent team scaffolding
alias agent-init="$SCRIPTS_DIR/init-new-project.sh"

# Add agent team layer to an existing project
alias agent-add="$SCRIPTS_DIR/add-to-existing.sh"

# Remove agent team files from a project
alias agent-remove="$SCRIPTS_DIR/remove-from-project.sh"

# Sync latest agent/command/skill templates into an existing project
alias agent-upgrade="$SCRIPTS_DIR/upgrade-project.sh"
$MARKER_END
EOF

  echo "✅ Installed! Aliases added to $rc_file"
  echo ""
  echo "Commands:"
  echo "  agent-init    <path> --type <fullstack-web|api-only|ai-llm-app|chrome-extension>"
  echo "  agent-add     <path> --type <fullstack-web|api-only|ai-llm-app|chrome-extension>"
  echo "  agent-remove  <path> [--keep-tracks] [--dry-run]"
  echo "  agent-upgrade <path> [--type <team-type>] [--dry-run]"
  echo ""
  echo "Optional flags for agent-init:"
  echo "  --name <project-name>   override project name (default: dirname)"
  echo "  --chrome-ext            include Chrome Extension domain skills"
  echo "  --ai                    include AI/RAG domain skills"
  echo ""
  echo "Reload your shell:"
  echo "  source $rc_file"
}

# ── Main ──────────────────────────────────────────────────────────────────────
case "${1:-}" in
  --uninstall|-u) uninstall ;;
  --help|-h)
    echo "Usage: ./setup.sh [--uninstall]"
    echo ""
    echo "  ./setup.sh             Install global aliases"
    echo "  ./setup.sh --uninstall Remove aliases"
    echo ""
    echo "After install:"
    echo "  agent-init    <path> --type <type>     Init new project"
    echo "  agent-add     <path> --type <type>     Add to existing project"
    echo "  agent-remove  <path> [--keep-tracks]  Remove from project"
    echo "  agent-upgrade <path> [--dry-run]      Sync latest templates"
    ;;
  "") install ;;
  *) echo "Unknown option: $1"; echo "Usage: ./setup.sh [--uninstall]"; exit 1 ;;
esac
