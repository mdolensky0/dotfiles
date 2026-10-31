---
name: practice-review
description: Senior-engineer review of Max's solution to a problem in ~/Projects/practice against its rubric. Use when the user runs /practice-review [id], says they finished a practice problem, or asks for feedback on a kata/exercise.
---

Repo: `~/Projects/practice`. Default target: the most recent `⬜`/`🔄` problem in `problems/INDEX.md` whose files changed.

## Steps

1. Read the problem `README.md` (requirements + rubric) and the repo's default rubric, then the solution (`git diff` against the commit that created the problem if available).
2. Run `sbt "testOnly <package>.*"`. Report pass/fail honestly.
3. Review like a senior Scala/FP engineer on a real PR. Grade each rubric line ✅ / ⚠️ / ❌, then findings ranked by impact:
   - correctness & totality (partial functions, exceptions, `???`, `.get`)
   - types telling the story (ADTs, newtypes, illegal states unrepresentable)
   - purity & effect boundaries; idiomatic Cats/CE use
   - tests (laws, edge cases, behaviour over implementation)
   - naming, structure, needless abstraction (rule of three) or missing abstraction
4. For the top 1–3 findings show a short "instead" snippet. Don't rewrite the whole solution.
5. For **Review**-type problems, compare `FINDINGS.md` to the answer key: caught / missed / false positives.
6. Name what was done well (specifically) — one or two lines.
7. Write the review to `problems/<domain>/<NNN-slug>/REVIEW.md`. If all requirements pass, mark the problem `✅ done` in `problems/INDEX.md` and the concept's Practice cell `✅ L<n>` in `~/Notes/second-brain/Concept Index.md`.
8. Suggest one next step: a harder level, a related concept, or — if a misconception surfaced — offer a targeted Anki card via the study-sync card rules.
