---
name: study-sync
description: Turn Max's recent Obsidian learning notes into Anki flashcards and keep the Concept Index current. Use when the user runs /study-sync (daily shutdown), "/study-sync week" (Friday problem set + coverage report), or "/study-sync gaps [domain]" (backfill cards for older notes).
---

Vault: `~/Notes/second-brain` (git). Index: `~/Notes/second-brain/Concept Index.md`. Practice repo: `~/Projects/practice`.
Never read `5. Writings/` or `2. Todos/`.

## Modes

- **(no args)** — notes changed today: `git -C ~/Notes/second-brain log --since=midnight --name-only --pretty=format:` plus `git status --porcelain` (modified + untracked `.md`). Exclude `Concept Index.md`.
- **week** — notes changed since last Friday, then also run the weekly problem set (below).
- **gaps [domain]** — no diff; take up to 15 `⬜` card gaps from the index (optionally one domain), oldest sections first.

## Steps

1. **Read** only the changed sections (use `git diff` hunks / headings), not whole files — some notes are 5k lines.
2. **Extract concepts** — terms, not definitions. Classify depth using Max's `4. Mental Models/Learning Approach.md`:
   `understand` (recurring ideas, the why) · `recognize` (know it exists + rough shape) · `look-up` (details, APIs, syntax tables).
3. **Update the index** — add new rows under the right `## Domain` table (`Concept | Depth | Cards | Practice | Source`), source as `[[Note Name]]`. Don't duplicate an existing row; extend its Source instead.
4. **Draft cards** for card gaps only:
   - `understand`: 2–4 cards — how/why/when/trade-off, plus an "X vs Y" contrast card where a neighbour exists.
   - `recognize`: 1 card. `look-up`: none.
   - One idea per card. Front is a question. Back ≤ 3 lines, optional code ≤ 6 lines in `<pre><code>`.
   - No trivia, no syntax recall, no "what is the name of…". Ask the question a senior engineer would ask in review.
5. **Present for approval** as a numbered list grouped by concept (`front → back`). Max trims/edits; then write only the approved ones.
6. **Write to Anki** via the Anki MCP tools. Before adding, search for duplicates by `concept::<slug>` tag.
   - Note type `Basic`. Decks: `Scala::Essentials`, `Scala::Advanced`, `Scala::FP`, `Cats`, `Cats Effect`, `Spark`, `Spark::Optimization`, `Work::Systems` (create if missing).
   - Tags: `claude`, `concept::<kebab-slug>`, `src::<kebab-note-name>`.
   - If the Anki MCP is unavailable (Anki closed), say so and write approved cards to `~/Notes/second-brain/.anki-import/<date>.tsv` (front⇥back⇥tags) for manual import.
7. **Mark** written concepts `✅` in the Cards column.
8. **Suggest** 1–2 practice ideas (`/practice <concept> <level>`) for `understand` concepts with no practice yet. Don't generate them.
9. Report: notes scanned, concepts added, cards written, remaining gaps in touched domains. Don't commit the vault.

## Weekly problem set (`week` mode)

After steps 1–9: generate 3–5 problems following the `practice` skill — two L1 warm-ups, one L2, and one Refactor or Review, drawn from this week's concepts and older `⬜` practice gaps. ~60% work-shaped (Spark jobs, event pipelines, ETL, Investigations-style domains), ~40% general FP/design. Finish with a coverage report per domain: concepts, % with cards, % with practice.
