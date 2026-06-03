#!/bin/bash
# PreToolUse(Bash) guardrail — a last-resort block for catastrophic commands,
# beyond the settings.json deny rules. Outputs a deny decision as JSON.
input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)

deny() {
  jq -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
}

case "$cmd" in
  *"rm -rf /"|*"rm -fr /"|*"rm -rf ~"*|*'rm -rf $HOME'*) \
      deny "Blocked by guardrail: recursive force-delete of a root/home path." ;;
  *":(){ :|:& };:"*) deny "Blocked by guardrail: fork bomb." ;;
  *"mkfs"*|*"> /dev/disk"*|*"> /dev/sd"*) \
      deny "Blocked by guardrail: destructive disk operation." ;;
esac

# Force-push to a protected branch
case "$cmd" in
  *"git push"*"--force"*|*"git push"*" -f"*)
    case "$cmd" in
      *" main"*|*" master"*|*":main"*|*":master"*) \
          deny "Blocked by guardrail: force-push to main/master." ;;
    esac ;;
esac
exit 0
