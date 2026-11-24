# ADR-0001: Initial Platform & Application Architecture for RITMA

**Status:** Accepted  
**Date:** 2026-11-24  
**Decision Makers:** Principal Software Architect / Technical Lead

---

## 1. Context

RITMA must support both traditional open-floor gyms and boutique class-based studios across multi-branch organizations, serving eight distinct personas across Android, iOS, and Web. Core operations (QR facility access, class seat booking, waitlist promotion, credit consumption/refunds) require strict transactional integrity, multi-tenant data isolation, and low operational overhead.

---

## 2. Decisions

### D1. Modular Monolith Over Microservices
- **Choice:** Single Flutter codebase structured feature-first (`lib/features/<module>`) paired with a single Supabase PostgreSQL database organized into clear domain modules and transactional SQL RPCs.
- **Rationale:** Atomic cross-domain invariants (locking `class_sessions` while debiting `credit_ledger_entries` and validating `member_entitlements`) execute inside a single PostgreSQL ACID transaction without distributed saga complexity.

### D2. Strict Separation of Four Domain Engines
- **Choice:** Model **Membership & Entitlement Engine**, **Facility Access Engine**, **Booking Engine**, and **Credit Ledger** as separate schema and domain boundaries.
- **Rationale:** Prevents the classic fitness-software anti-pattern where gym memberships implicitly allow unlimited studio bookings or class packs grant open-gym entry. Supports gym-only, studio-only, PT-only, and hybrid packages uniformly.

### D3. Multi-Role, Multi-Scope Authorization with Database-Enforced RLS
- **Choice:** Use `user_role_assignments(user_id, organization_id, branch_id?, role_id)` mapped to granular permission codes evaluated by PostgreSQL RLS and hardened `SECURITY DEFINER` RPCs (`SET search_path = pg_catalog, public`, explicit caller checks, `REVOKE ALL FROM PUBLIC`).
- **Rationale:** One human can hold different roles across organizations and branches. Client-side guards provide UX routing only; PostgreSQL enforces true multi-tenant security.

### D4. Flutter Core Stack (`flutter_riverpod`, `go_router`, `freezed`, `json_serializable`, `logging`)
- **Choice:** Adopt Riverpod for DI/state, GoRouter for dual-shell (`/member/*` vs `/ops/*`) declarative routing, Freezed + JsonSerializable for immutable models and sealed `AppFailure` unions, and `package:logging` for structured logs.
- **Deferred:** `supabase_flutter` (Milestone 2), `mobile_scanner` / `qr_flutter` (Milestone 5), `firebase_messaging` (Phase 2), and `drift` local SQLite cache (Phase 2/3 if offline check-in becomes a validated requirement).

### D5. Compile-Time Environment Injection (`--dart-define`)
- **Choice:** Inject environment config via `--dart-define` / `--dart-define-from-file` into `AppEnv`, keeping `.env` files out of Flutter asset bundles and secrets out of Git.
- **Rationale:** Prevents accidental packaging of `.env` assets into client binaries and enforces production safety toggles (`enableDebugLogging = false`, `enableDemoMode = false`).

---

## 3. Consequences

### Positive
- Strong correctness guarantees against overbooking, double check-ins, duplicate credit deductions, and cross-tenant data leaks.
- Fast local iteration and minimal infrastructure footprint during MVP delivery.
- Clean separation between Member and Operations UX surfaces within one shared design-token system.

### Trade-Offs & Mitigations
- **RLS & SQL RPC complexity:** Mitigated via centralized `authz.has_permission()` helpers, composite tenant indexes, and mandatory automated PostgreSQL RLS/concurrency tests starting in Milestone 2.
- **Code generation overhead (`build_runner`):** Mitigated by scoping Freezed/JsonSerializable strictly to domain models, DTOs, and sealed failure unions (omitting `riverpod_generator` initially).
- **Online-first MVP:** Front-desk operations require active internet connectivity in MVP; mitigated by clear offline error feedback and an architectural seam in repositories for future Drift caching.
