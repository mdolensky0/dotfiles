# Environment
- macOS (Apple Silicon), zsh, editor nvim, terminal Ghostty. Modern CLI tools available: rg, fd, ast-grep (`sg`), jq, bat, eza, gh, grpcurl, delta, lazygit. (The built-in Grep tool already uses ripgrep — no need to shell out to `rg`.)
- **Dotfiles are managed by chezmoi** (`~/.local/share/chezmoi`, private repo `mdolensky0/dotfiles`). To change a tracked config, edit the real file then run `chezmoi re-add <file>` — don't edit the chezmoi source directly.
- **Two coupled repos:** `dido-grpc-backend` (Java 25 / Spring Modulith / gRPC) owns the proto contract in `src/main/proto`; `Dido` (Swift/iOS, grpc-swift-2) regenerates its client from it via `DidoSwiftProtos/RUNME`.

# Code philosophy (Max prefers — FP background)
Apply by default; clarity over dogma. Language specifics live in the **java-backend** and **swift-ios** skills.
- **Functional-leaning:** immutable values, pure functions, sum types + exhaustive matching, **functional core / imperative shell** (side effects — DB, network, time, UUIDs — at the edges).
- **DRY & composable:** small reusable units, interface/protocol seams, constructor/default-param DI — but **obey the rule of three; duplication beats the wrong abstraction**, and a one-caller abstraction is negative value.
- **Testable by construction:** logic pure and framework-free; effects behind injected seams; inject time/uuid/randomness.

# Working style
- Use **plan mode** for any change beyond a one-sentence diff. For fuzzy/large features, interview me first (the `grill-me` skill) → write a SPEC → implement in a fresh session.
- Emit plans/reviews/reports as **self-contained HTML artifacts** when they're for me to read (not for code or short replies). Use `handoff` when context fills.
- Read targeted line ranges, not whole large files; extract from big JSON with `jq`.
- **Ask before destructive or outward actions** (push, force-push, `rm -rf`, publishing, sending).
- When writing/reviewing **Java backend** code follow the **java-backend** skill; for **Swift/iOS** the **swift-ios** skill. Per-project rules take precedence (backend `docs/adr/` + `CONTRIBUTING.md`; Dido `ENGINEERING_STANDARDS.md`).
