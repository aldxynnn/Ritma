# RITMA — Quality & Test Strategy

## 1. Testing Philosophy

Fitness operations involve real money, physical access control, and tight class capacities. Bugs like overbooking a Pilates class, double-deducting credits, or leaking member data across organizations destroy operator trust immediately. RITMA therefore invests in a **balanced, behavior-driven testing pyramid** across both Flutter and PostgreSQL/Supabase.

---

## 2. Test Layers

### 2.1 Dart / Flutter Unit Tests (`test/core/`, `test/features/*/domain/`, `test/features/*/application/`)
- **Focus:** Domain value objects, state transitions, error mapping (`ErrorMapper`), `Result<T>` repository guards, environment config (`AppEnv`), Riverpod notifier state machines, and entitlement/credit display logic.
- **Execution:** Fast (< 5s), deterministic, zero network dependency. Uses Riverpod `ProviderContainer` with repository overrides.

### 2.2 Flutter Widget Tests (`test/features/*/presentation/`, `test/widget_test.dart`)
- **Focus:** Critical UI flows, role-based shell switching (Member vs Operations), `AsyncStateView` states (loading, empty, error + retry, success), accessibility labels, dynamic text scaling (`MediaQuery.textScalerOf` at 1.5x–2.0x), and light/dark theme rendering without overflow.

### 2.3 PostgreSQL & RLS Security Tests (`supabase/tests/`)
- **Focus:** Highest-leverage tests in the entire platform, implemented as self-contained transactional SQL test suites (`01_rls_tenant_branch_isolation.sql`, `02_entitlement_and_ledger_integrity.sql`, `03_booking_concurrency_and_waitlist.sql`, `04_qr_checkin_and_security.sql`) that simulate Supabase JWT claims (`request.jwt.claims`, `role = authenticated`) and clean up via rollback/assertions:
  - **Tenant & Composite FK Isolation Tests:** Verify User in Org A receives 0 rows and `permission denied` on Org B tables/RPCs, and cross-tenant FK inserts fail at PostgreSQL constraint layer (F1).
  - **Branch & Role Hierarchy Isolation Tests:** Verify Branch Manager of Branch 1 cannot mutate schedules or check in at Branch 2, `org_admin` cannot assign/revoke `org_owner`, and last `org_owner` cannot be revoked (F3, F8).
  - **Entitlement Separation & Multi-Grant Ledger Tests:** Verify active Gym Membership allows QR check-in and rejects Pilates booking with `INSUFFICIENT_CREDITS`; verify Class Pack books Pilates and fails gym QR check-in with `NO_FACILITY_ENTITLEMENT`; verify multi-grant (`credit_cost > 1`) FIFO consumption and per-grant early-cancel refund uniqueness (F5).
  - **Concurrency, Capacity & Idempotency Tests:**
    - Concurrent/back-to-back last-seat bookings -> `confirmed_count <= capacity`; `BEFORE UPDATE` trigger rejects shrinking capacity below `confirmed_count` (F9).
    - Waitlist promotion skips members lacking unexpired credits (writing `audit_logs`) and enforces canonical lock order (F6).
    - Duplicate `idempotency_key` replay -> single booking, single ledger consumption; double QR check-in within cooldown -> `DUPLICATE_COOLDOWN`; forged/expired/wrong-org QR token -> denied (`QR_INVALID_SIGNATURE`, `QR_TOKEN_EXPIRED`, `QR_ORG_MISMATCH`) (F7).

### 2.4 End-to-End Integration Tests (`integration_test/` — Milestone 5+)
- **Focus:** Smoke coverage of critical user journeys against a dedicated local/staging Supabase instance:
  1. Owner creates organization & branch.
  2. Staff assigns gym & class packages to member.
  3. Member generates QR pass -> Staff checks member in.
  4. Member books class -> Instructor marks attendance -> Owner dashboard reflects live count.

---

## 3. Quality Gates (Mandatory Per Milestone)

Before any milestone commit or pull request is accepted:
1. `dart format --output=none --set-exit-if-changed .` passes with 0 formatting diffs.
2. `flutter analyze` passes with **0 errors and 0 warnings**.
3. `flutter test` passes 100% of unit and widget tests.
4. Generated files (`*.freezed.dart`, `*.g.dart`) are up to date via `dart run build_runner build`.
5. For backend milestones: Supabase migrations apply cleanly from scratch (`supabase db reset`) and all RLS/RPC SQL tests pass.
