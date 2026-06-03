---
description: Stage and commit changes with a clear message in the repo's style
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git commit:*), Bash(git log:*)
---
Create a commit:
1. Review what changed — `git status` and `git diff` (staged + unstaged).
2. Stage the relevant files (don't blindly `git add -A`; exclude unrelated/debug/secret files).
3. Match the repo's existing style — `git log --oneline -10`.
4. Write a concise message: imperative subject line, and a body explaining the **why** if non-trivial.

Never commit secrets or generated artifacts. For a large/ambiguous change, show me the message before committing.
