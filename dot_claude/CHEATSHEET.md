# Claude Code — power-user cheat-sheet (personal reference)

## Workflow
- **Explore → Plan → Code → Commit.** Use **plan mode** (Shift+Tab) for any change beyond a one-sentence diff; press **Ctrl+G** to open your prompt in `$EDITOR` (nvim) for long/multi-line input.
- Fuzzy/large feature? `/grill-me` (interview) → write a SPEC → implement in a **fresh session**.
- `/handoff` to compress a session into a handoff doc (context limits / passing work to another worktree).
- Want a review/plan/report for *you* to read? Ask for a self-contained **HTML artifact** (web-artifacts-builder skill).

## Reasoning effort
Set with `/effort`: `low` < `medium` < `high` (default on Opus 4.8 / Sonnet 4.6) < `xhigh` < `max`. **Option+T** cycles it. The only prompt keyword still recognized is **`ultrathink`** — the old `think` / `think hard` / `megathink` ladder is now plain text, not a dial. Pair `/clear` + max effort for genuinely hard problems.

## Context discipline
- `/clear` between unrelated tasks (corrected twice on the same thing → `/clear`).
- `/compact <focus>` — summarize while steering what survives.
- `/rewind` or double-**Esc** — restore conversation / code / both. Single **Esc** interrupts; "undo that" reverts changes.

## Parallel work (worktrees)
- `cwt <branch>` → new git worktree + tmux window running `claude`. `cwtls`, `cwtrm <branch>`.
- Or Superpowers' `using-git-worktrees` / `dispatching-parallel-agents`.

## Commands
- **backend:** `/verify` `/grpc-ls` `/new-module` `/adr`
- **Dido:** `/build` `/test` `/run` (builds, launches, and drives the simulator) `/sync-protos` `/new-feature`
- **global:** `/commit` `/create-pr` `/security-review`

## Installed skills/plugins
superpowers (TDD · brainstorm · systematic-debugging · subagent review · worktrees), grill-me, handoff, web-artifacts-builder, skill-creator, mcp-builder, document-skills (pdf/docx/pptx/xlsx), security-guidance, **java-backend**, **swift-ios**. MCP: context7 (live docs), ios-simulator (Dido only).

## Safety
A Bash guardrail hook blocks catastrophic commands (`rm -rf /`, force-push to main, fork bombs). `.env`/keys are deny-listed from reads. Push/commit/destructive actions still prompt.
