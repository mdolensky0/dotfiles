---
name: java-backend
description: Code style and engineering best practices for Java backend work (Java 21–25, Spring Boot, Spring Modulith, gRPC, Postgres/JPA, Flyway, JWT, OpenTelemetry). Consult when writing, designing, or reviewing Java backend code. Project rules (docs/adr + CONTRIBUTING.md) take precedence.
---

# Java backend: style + practices

FP-leaning Java for a Scala/FP developer: push Java toward immutability, data-as-data, and pure functions as far as it idiomatically goes — then stop before fighting the ecosystem. The wins are records + sealed types + pattern matching + a pure core, not emulating cats/zio.

## Style (functional-leaning Java)
- **Records by default** for data/DTOs/value objects; compact constructor validates at the boundary. Builders only for many-optional fields.
- **Sealed interface + records = ADTs (sum types).** Match with **exhaustive `switch` (no `default`)** + record deconstruction, so a new variant breaks the build.
- **`Optional` only as a return type.** Never fields/params/collection elements (breaks JPA/Jackson). `orElseGet` not `orElse`; never `isPresent()+get()`; never `Optional<Optional>`. For absent collections return empty, not `Optional<List>`.
- **Kill nulls at compile time:** JSpecify `@NullMarked` (package-info) + NullAway breaking the build; reserve `Optional` for genuine domain optionality, not null-defense.
- **Streams for collection transformation; loops for side effects/orchestration.** No stateful lambdas; `.parallel()` only when measured. Break "wall of text" pipelines into named steps.
- **Expected failures = data** (small sealed `Result`); exceptions for the truly exceptional (Spring `@ControllerAdvice`/`GrpcExceptionHandler` maps them). Pull in **Vavr only for `Validation` accumulation**, confined to the domain core — not as a blanket wrapper.
- **Functional core / imperative shell:** pure, framework-free domain logic (no Spring/JPA imports, no I/O, no `Instant.now()`/`UUID` inside — inject them); all side effects in the `@Service` shell. This is what makes the core trivially testable.
- **Composition over inheritance; constructor injection only** (final fields, no field `@Autowired`); strategy = a `Function`/`@FunctionalInterface` parameter, not a class hierarchy. Interfaces only at real seams; obey the rule of three.
- **Entities are mutable, thin, and quarantined in infra** (Hibernate needs no-arg ctor/non-final fields). **Records as DTOs**; map entity⇄DTO; **never expose entities at the API boundary.**

## gRPC / proto API design
- **Status codes are the contract** (translate at the boundary via one `GrpcExceptionHandler`): `INVALID_ARGUMENT` (bad input regardless of state, don't retry) vs `FAILED_PRECONDITION` (valid input, wrong state) vs `NOT_FOUND`/`ALREADY_EXISTS`; `ABORTED`/`UNAVAILABLE` = retryable, `UNAUTHENTICATED` vs `PERMISSION_DENIED`. Reserve `INTERNAL`/`UNKNOWN` for real faults — never leak stack traces.
- **Deadlines on every call**; check `Context.current().isCancelled()` in long/streaming work.
- **Rich errors:** attach `ErrorInfo` (machine `reason`+`domain`) + `BadRequest.FieldViolation`; keep debug info out of prod.
- **Proto compat (hard rules):** never change/reuse a field number; `reserved` deleted numbers *and* names; adding fields/enum values is safe. Enforce with **`buf breaking`** + `buf lint` in CI.
- **Keyset/cursor pagination only** (opaque `next_page_token`), never offset. Idempotency keys for non-idempotent writes.

## Persistence & transactions
- `@Transactional` **short**; never wrap remote/gRPC/long compute. **Self-invocation bypasses the proxy** — put the boundary on the public entry. `readOnly=true` for queries.
- **Kill N+1:** `LAZY` by default + explicit `JOIN FETCH`/`@EntityGraph`; `hibernate.default_batch_fetch_size`; **`spring.jpa.open-in-view=false`**.
- **DTO/constructor projections** across boundaries — only needed columns, no entity leakage, no `LazyInitializationException`.
- `@Version` optimistic locking → map `OptimisticLockException` to gRPC `ABORTED`.
- **Flyway: migrations are immutable** (never edit a shipped script — add a new one); **expand–contract** for breaking changes across separate deploys; `CREATE INDEX CONCURRENTLY` needs `executeInTransaction=false`.

## Security / observability / testing / ops
- **BOLA is #1 (OWASP API1):** verify the authenticated principal may access *that specific ID*, server-side, every path. **JWT per RFC 8725** (reject `alg:none`, pin alg, verify JWKS, check iss/aud/exp). Validate all input → `INVALID_ARGUMENT`. Secrets externalized (never in code/yaml/git); least-privilege DB user.
- **Structured JSON logs with trace IDs (Micrometer MDC), no PII/secrets.** RED metrics per RPC; OTel ratio sampling (~0.1) in prod; liveness vs readiness probes + gRPC health.
- **Test pyramid:** many unit (pure domain, mappers, status mapping); **in-process gRPC** (`InProcessServer/Channel`) for service tests; **Testcontainers real Postgres** (never H2). `buf breaking` is the contract test.
- **12-factor config + profiles; graceful shutdown** (`server.shutdown=graceful`). **Small HikariCP pool** ≈ `(cores*2)+1`; cap total across instances under Postgres `max_connections`. BOM-managed deps; SBOM + CI vuln scan.

## Performance — the 90% of real wins
Right-size the pool → kill N+1 (`open-in-view=false` + projections + batch fetch) → batch writes (`hibernate.jdbc.batch_size`, `reWriteBatchedInserts=true`) → projections for reads. **Virtual threads** (`spring.threads.virtual.enabled=true`) for I/O scaling on JDK 24+ (JEP 491 fixed `synchronized` pinning — the "purge synchronized" advice is obsolete there); they do nothing for CPU-bound work. G1 GC default; don't hand-tune GC early.

## Honest cargo-cult flags
Oversized connection pools (actively harmful) · hard coverage-% gates (test what matters; prefer mutation tests on core) · circuit breakers on your own single Postgres · H2-as-Postgres in tests · premature GC tuning · over-eventing simple synchronous cross-module reads · Vavr to wrap every call · a one-caller interface/abstraction.
