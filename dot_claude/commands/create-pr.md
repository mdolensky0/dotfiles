---
description: Push the current branch and open a pull request via gh
allowed-tools: Bash(git push:*), Bash(gh pr create:*), Bash(git diff:*), Bash(git log:*), Bash(gh pr view:*)
---
Open a PR for the current branch:
1. Review the diff vs the base branch (`git diff <base>...HEAD`, `git log <base>..HEAD`).
2. Push the branch (set upstream if needed).
3. `gh pr create` with a clear title and a body containing: **summary**, **why**, and a **test plan**.
4. Return the PR URL.

Confirm the base branch and title with me if ambiguous. Don't open a PR with secrets or WIP debug code in the diff.
