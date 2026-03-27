#!/usr/bin/env bash
# install.sh — Install agentic-learning skill
#
# Works with any AgentSkills-compatible agent (Cursor, Claude Code, Windsurf,
# GitHub Copilot, Gemini CLI, Amp, Warp, Cline, and more).
#
# Usage:
#   Workspace (current project):  bash install.sh
#   Global for specific agent:    bash install.sh --global --agent claude
#   Uninstall:                    bash install.sh --uninstall [--global] [--agent claude]
#
# Project scope installs to .agents/skills/ — the standard path all AgentSkills-
# compatible agents read from. --agent only needed for global installs.
#
# Supported --agent values (global only):
#   universal (default), claude, windsurf, augment, continue,
#   goose, roo, zencoder, kilo, junie, openhands

set -e

SKILL_NAME="agentic-learning"
REPO="https://github.com/FavioVazquez/agentic-learning"
GLOBAL=false
UNINSTALL=false
AGENT="universal"

for arg in "$@"; do
  case $arg in
    --global)       GLOBAL=true ;;
    --uninstall)    UNINSTALL=true ;;
    --agent=*)      AGENT="${arg#--agent=}" ;;
    --agent)        shift; AGENT="$1" ;;
  esac
done

# Project scope: always .agents/skills/ (AgentSkills standard for all agents)
WORKSPACE_DIR=".agents/skills/$SKILL_NAME"

# Global scope: agent-specific home directory
case "$AGENT" in
  universal|amp|cursor|copilot|cline|codex|gemini|warp|opencode|replit)
    GLOBAL_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/agents/skills/$SKILL_NAME"
    ;;
  claude|claude-code)
    GLOBAL_DIR="$HOME/.claude/skills/$SKILL_NAME"
    ;;
  windsurf)
    GLOBAL_DIR="$HOME/.codeium/windsurf/skills/$SKILL_NAME"
    ;;
  augment)
    GLOBAL_DIR="$HOME/.augment/skills/$SKILL_NAME"
    ;;
  continue)
    GLOBAL_DIR="$HOME/.continue/skills/$SKILL_NAME"
    ;;
  goose)
    GLOBAL_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/goose/skills/$SKILL_NAME"
    ;;
  roo)
    GLOBAL_DIR="$HOME/.roo/skills/$SKILL_NAME"
    ;;
  zencoder)
    GLOBAL_DIR="$HOME/.zencoder/skills/$SKILL_NAME"
    ;;
  kilo)
    GLOBAL_DIR="$HOME/.kilocode/skills/$SKILL_NAME"
    ;;
  junie)
    GLOBAL_DIR="$HOME/.junie/skills/$SKILL_NAME"
    ;;
  openhands)
    GLOBAL_DIR="$HOME/.openhands/skills/$SKILL_NAME"
    ;;
  *)
    echo "❌ Unknown agent: $AGENT" >&2
    echo "Supported: universal, claude, windsurf, augment, continue, goose, roo, zencoder, kilo, junie, openhands" >&2
    exit 1
    ;;
esac

if [ "$GLOBAL" = true ]; then
  SKILLS_DIR="$GLOBAL_DIR"
  SCOPE="global ($AGENT)"
else
  SKILLS_DIR="$(pwd)/$WORKSPACE_DIR"
  SCOPE="workspace"
fi

# Uninstall
if [ "$UNINSTALL" = true ]; then
  if [ -d "$SKILLS_DIR" ]; then
    rm -rf "$SKILLS_DIR"
    echo "✅ Uninstalled $SKILL_NAME ($SCOPE)"
  else
    echo "ℹ️  $SKILL_NAME not found at $SKILLS_DIR — nothing to remove"
  fi
  exit 0
fi

# Install
echo "Installing $SKILL_NAME → $SKILLS_DIR"

if command -v git &>/dev/null; then
  if [ -d "$SKILLS_DIR/.git" ]; then
    echo "Updating existing installation..."
    git -C "$SKILLS_DIR" pull --ff-only
  else
    mkdir -p "$(dirname "$SKILLS_DIR")"
    git clone --depth 1 "$REPO" "$SKILLS_DIR"
  fi
elif command -v curl &>/dev/null; then
  echo "git not found — downloading archive via curl..."
  mkdir -p "$SKILLS_DIR"
  curl -sL "$REPO/archive/refs/heads/main.tar.gz" \
    | tar -xz --strip-components=1 -C "$SKILLS_DIR"
else
  echo "❌ Neither git nor curl found. Please install one and retry." >&2
  exit 1
fi

echo ""
echo "✅ $SKILL_NAME installed ($SCOPE)"
echo ""
echo "Usage: @agentic-learning <action>"
echo "  learn, quiz, reflect, space, brainstorm, explain-first,"
echo "  struggle, either-or, explain, interleave, cognitive-load"
