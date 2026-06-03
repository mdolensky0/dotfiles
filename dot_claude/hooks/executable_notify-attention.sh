#!/bin/bash
# Notification hook — macOS desktop notification when Claude Code needs your
# attention (waiting for permission or input). Fires on the Notification event,
# so it's not per-turn noise.
input=$(cat)
msg=$(printf '%s' "$input" | jq -r '.message // "Claude needs your attention"' 2>/dev/null)
osascript -e "display notification \"${msg//\"/}\" with title \"Claude Code\" sound name \"Submarine\"" 2>/dev/null || true
exit 0
