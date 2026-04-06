#!/usr/bin/env bash
# Usage: ./scripts/run_review.sh [--json] [--last-message <msg>] [--session <path>]
#
# Invokes the shared protocol reviewer for this claw-code-parity session.
# The reviewer reads the most recent session from .claude/sessions/ and
# evaluates protocol compliance against ~/.claude/docs/protocol-compliance-reference.md.
#
# Future wiring: when the Rust runtime adds a SessionEnd lane event, add to
# .claw/settings.json:
#   { "hooks": { "SessionEnd": ["./scripts/run_review.sh --json"] } }

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REVIEWER="$HOME/.claude/hooks/claw_stop.py"

if [[ ! -f "$REVIEWER" ]]; then
    echo "ERROR: claw reviewer not found at $REVIEWER" >&2
    exit 1
fi

uv run --script "$REVIEWER" "$PROJECT_ROOT" "$@"
