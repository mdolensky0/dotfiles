---
name: swift-ios
description: Code style and engineering best practices for Swift/iOS work (Swift 5.9+/6, iOS 18+, SwiftUI + @Observable, structured concurrency, grpc-swift-2, SwiftData, Keychain). Consult when writing, designing, or reviewing Swift/iOS code. Project rules (ENGINEERING_STANDARDS.md) take precedence.
---

# Swift / iOS: style + practices

Value-oriented, immutable, composable, testable Swift for a Scala/FP developer — plus where the community over-engineers.

## Style (functional-leaning Swift)
- **`struct` + `let` by default;** `class` only for identity/reference sharing or `@Observable` view state. Value semantics → local reasoning, no shared-mutable bugs.
- **Domain = structs (products) + enums with associated values (sum types/ADTs).** **Exhaustive `switch`, no needless `default`** — let the compiler force handling new cases. (Enums = finite states; use a struct with static factories for open/extensible sets.)
- **Optionals:** `map`/`flatMap`/`guard let`/`??`; **never force-unwrap (`!`)** outside tests. On collections use **`compactMap`** to drop nils (not `flatMap`); on optionals `flatMap` when the closure returns optional (avoid `Int??`).
- **Errors: prefer `throws`** (composes with `async`); `Result` only to *store/pass* an outcome. Typed `throws(E)` when the error set is genuinely narrow — don't over-specify.
- **Pure functions at the core, effects at the edges** (network/clock/persistence/randomness injected, not called inline).
- **Protocols are your seams**; **default-parameter constructor injection** is the idiomatic DI (`init(loader: Loading = LiveLoader())`) — no container until the graph demands one. Composition + protocol extensions over inheritance.
- **`some P`** (opaque) by default; **`any P`** only for heterogeneous storage; generics when the caller picks the type.
- **Concurrency:** structured (`async let`, `withTaskGroup`) over bare `Task`; **`actor` for shared mutable state** (not class+lock); **`@MainActor`** for UI; let value types be implicitly `Sendable` — don't reach for `@unchecked Sendable`/`nonisolated(unsafe)`. Turn on **complete** strict-concurrency checking.

## SwiftUI + @Observable
- **Use `@Observable`** (property-level dependency tracking → fewer re-renders), not `ObservableObject`/`@Published`.
- **Ownership (highest-value rule):** you *create* it → `@State`; you *receive* it → plain `let`; need `$binding` → `@Bindable`; app-wide → `@Environment(Model.self)`. Pitfall: `@State` on a received model, or `let m = Model()` in a non-`@State` view, silently re-creates it each redraw and loses state.
- **Logic lives in the `@Observable` model, not the view.** Keep `body` cheap; mark non-UI fields `@ObservationIgnored`. Keep model `init` cheap/side-effect-free (`@State` init can run on every rebuild).
- **Side effects in `.task`/`.task(id:)`/`.refreshable`** (lifetime-scoped, auto-cancel), not bare `Task {}` in `onAppear`. Unidirectional flow: view → intent method → state mutation → re-render.

## Networking (grpc-swift-2), persistence, security
- **grpc-swift-2:** RPCs are `async throws` (straight-line await); streaming = `for try await` over an `AsyncSequence` inside the run-scope. **Cancellation = Task cancellation**; use built-in **retries/hedging** (don't hand-roll). **Auth via interceptor + `actor AuthManager`** holding a single in-flight `refreshTask` so concurrent callers await the same refresh. Treat connectivity as state (offline UI), not an exception.
- **SwiftData:** respect `ModelContext` threading (main-created → main queue). Background work via **`@ModelActor` created from `Task.detached`** (a plain `Task` in a view inherits MainActor — classic gotcha). **Never pass `PersistentModel` across contexts — pass `PersistentIdentifier` and re-fetch.** Never recreate a context per redraw. Version the schema early.
- **Security:** **Keychain** for all tokens/secrets (`kSecAttrAccessibleWhenUnlocked`, never `…Always`); **never hardcode secrets** (extractable from the binary); enforce ATS (no `NSAllowsArbitraryLoads`). **S3:** fetch short-TTL pre-signed URLs from your backend; cache the bytes keyed by a stable media ID (not the expiring URL), refresh on 403.

## Performance / UX / testing / build
- **Main-thread discipline** (UI on MainActor, heavy work off-main). **`List` for large data** (recycles); `LazyVStack/Grid` don't recycle (memory grows). **`AsyncImage` doesn't cache** — use NSCache/Nuke + downsample to display size. `[weak self]` only for escaping closures that outlive the owner. Profile with Instruments (SwiftUI template) before optimizing re-renders.
- **Model every async surface as loading/loaded/empty/error states.** Accessibility is baseline: VoiceOver labels/hints (localized), Dynamic Type (semantic fonts, test at largest sizes), audit with Accessibility Inspector. **String Catalogs (`.xcstrings`)** even for single-locale.
- **Testing:** **Swift Testing** (`@Test`/`#expect`, parameterized) for logic; keep `XCUIApplication`/perf in XCTest. Unit-test models/mappers/token-refresh/state machines. DI via protocols/**swift-dependencies** (`@Dependency` + `withDependencies` — also fixes previews). **Snapshot tests** for a few stable screens.
- **Build:** SPM with pinned versions; **modularize for build speed/team boundaries only** (local packages = true incremental builds), not aesthetics. Separate Debug/Release via `.xcconfig`; wire one crash reporter (MetricKit/Sentry) day one behind a thin protocol.

## Honest cargo-cult flags
Over-modularization (#1) · VM-per-view dogma (`@Observable` makes many VMs unneeded) · premature TCA/Redux · hand-rolled retry/backoff (grpc-swift-2 has it) · `[weak self]` everywhere · snapshot-everything / 100% coverage · trusting SwiftData's auto queue-switching · a protocol with one conformer and no test seam.
