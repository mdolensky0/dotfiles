---
name: practice
description: Generate a coding practice problem in Max's ~/Projects/practice sbt repo (Scala 2.13, Cats, Cats Effect) for a concept from his Concept Index. Use when the user runs /practice <concept> [level], asks for a practice problem/kata/exercise, or the study-sync weekly set needs problems.
---

Repo: `~/Projects/practice` (read its `README.md` for layout and levels). Index: `~/Notes/second-brain/Concept Index.md`.

## Goal

Make Max a better engineer, not a faster trivia-solver: design, types, clean code, patterns, testing, problem decomposition. Problems should feel like real work in miniature. His coding approach (`4. Mental Models/Coding Approach.md`): figure things out by writing types first.

## Steps

1. **Locate the concept** in the index; read its source note section so the problem uses his vocabulary. Unknown concept → ask, or add it to the index first.
2. **Pick a level** if not given: no practice yet → L1 (or L2 if the concept builds on ones he's practised); has L1 → L2/Refactor/Review; Fridays → L3. Say which and why in one line.
3. **Pick framing**: ~60% work-shaped (event ingestion, Delta/ETL pipelines, validation, retries, investigations events), ~40% general (classic FP/design). Never a toy "Foo/Bar".
4. **Next ID** from `problems/INDEX.md` (zero-padded). Slug is short kebab-case.
5. **Create**:
   - `problems/<domain>/<NNN-slug>/README.md` — level, concepts, source `[[Note]]`, goal, numbered requirements, constraints, rubric (problem-specific bullets + "see default rubric"), run command.
   - `HINTS.md` — 3–5 progressive hints in `<details>` blocks.
   - Code under package `practice.<domain>.p<NNN>_<slug_snake>`.
6. **By level**:
   - **L1/L2** — stubs with `???` bodies and real signatures; munit (or munit-cats-effect for IO) tests that fail until solved. Tests encode behaviour and laws/edge cases, not implementation.
   - **Refactor** — working but ugly code (vars, nulls, exceptions, god-method, stringly-typed) + passing characterisation tests. Task: make it clean FP without breaking tests; README lists the smells to hunt only in HINTS.
   - **Review** — `PR.diff` against a small provided module, seeded with 4–7 issues (bug, effect leak, partiality, naming, missing test, wrong abstraction). Task: write `FINDINGS.md`. Answer key goes in the last `<details>` of HINTS.md.
   - **L3 Design** — requirements + acceptance criteria, no stubs; ask for algebra/types first (a `DESIGN.md` sketch), then implementation and tests. Provide one acceptance test as a target.
   - **L4 Capstone** — multi-part README with milestones + `ADR-001.md` template.
7. **Verify** `sbt Test/compile` succeeds (tests should compile and fail, except Refactor which passes). Fix until it does.
8. **Record**: append to `problems/INDEX.md` (`⬜ todo`); set the concept's Practice cell to `🔄 L<n>` in the index.
9. Reply with the README path, level, est. time, and the run command. Don't solve it or show hints.
