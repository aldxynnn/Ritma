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

### 2.3 PostgreSQL & RLS Security Tests (`supabase/tests/` — introduced in Milestone 2)
- **Focus:** Highest-leverage tests in the entire platform. Using `pgTAP` (or SQL transaction assertions run via Supabase CLI):
  - **Tenant Isolation Tests:** Verify User in Org A receives 0 rows and `permission denied` on every table/RPC belonging to Org B.
  - **Branch Isolation Tests:** Verify Branch Manager of Branch 1 cannot mutate schedules or check in members at Branch 2.
  - **Entitlement Separation Tests:** Verify active Gym Membership allows QR check-in and fails Pilates class booking with `INSUFFICIENT_CREDITS`; verify Class Pack books Pilates and fails gym QR check-in with `NO_FACILITY_ENTITLEMENT`.
  - **Concurrency & Idempotency Tests:**
    - Concurrent bookings for the last remaining seat -> exactly 1 `confirmed`, 1 `waitlisted` (or `CAPACITY_EXCEEDED`), `confirmed_count <= capacity`.
    - Duplicate `idempotency_key` replay -> single booking, single `-1` ledger entry.
    - Double QR check-in within cooldown -> rejected with `DUPLICATE_COOLDOWN`.
    - Repeated booking cancellation -> at most 1 `+cost` refund ledger entry.

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
