# RITMA — Domain Model

## 1. Architectural Boundary: Four Distinct Core Engines

A common failure in fitness software is conflating **membership**, **facility access**, **class booking**, and **credit accounting** into a single subscription table. RITMA strictly separates these four domain engines:

| Engine | Core Responsibility | Owns | Must NEVER Assume |
|---|---|---|---|
| **1. Membership & Entitlement Engine** | Defines commercial packages, tracks subscription lifecycles, and materializes explicit rights (`entitlements`) | `packages`, `package_entitlement_templates`, `member_subscriptions`, `member_entitlements` | That every subscription grants gym entry or class bookings automatically |
| **2. Facility Access Engine** | Evaluates physical branch entry eligibility, validates rotating QR tokens, enforces cooldowns, logs visits | `member_qr_tokens`, `facility_visits`, `facility_access_attempts` | That class credits or PT packs allow open-gym access |
| **3. Booking Engine** | Manages class templates, materialized sessions, room/instructor assignments, seat capacities, bookings, waitlists, and attendance | `class_types`, `class_templates`, `class_sessions`, `class_bookings` | That an active gym membership allows booking credit-gated classes |
| **4. Credit Ledger** | Immutable append-only ledger tracking credit grants, consumptions, refunds, expirations, and manual adjustments | `credit_grants`, `credit_ledger_entries` | Mutable balance overwrites without an auditable ledger trail |

### Illustrative Scenario (Mandatory Domain Invariant)
> **Member A** holds an active *All-Access Gym Monthly* membership (grants `facility_access` for Branch 1 & Branch 2) and **0** Pilates class credits.
> - **Scan QR at Branch 1 Gym:** Facility Access Engine checks `member_entitlements` (`type = facility_access`, `status = active`, `branch = Branch 1`) -> **ALLOWED**.
> - **Book Reformer Pilates (1 credit):** Booking Engine checks Credit Ledger (`credit_type = class_credit`, matching class category/branch) -> Balance = `0` -> **REJECTED (`INSUFFICIENT_CREDITS`)**.
>
> **Member B** holds a *10-Class Pilates Pack* (`credit_type = class_credit`, balance = 8) and **no** gym membership.
> - **Book Reformer Pilates:** Credit Ledger shows 8 unexpired eligible credits -> **CONFIRMED**, ledger posts `-1` entry.
> - **Scan QR for open-gym entry:** Facility Access Engine finds no active `facility_access` entitlement -> **DENIED (`NO_FACILITY_ENTITLEMENT`)**.

---

## 2. Bounded Contexts & Core Entities

### 2.1 Tenant & Identity Context
- **Organization (`organizations`):** Root tenant boundary (name, slug, timezone, currency, status).
- **Branch (`branches`):** Physical location under an organization (name, address, timezone override, status).
- **Room (`rooms`):** Bookable studio/zone inside a branch (name, default capacity, room type).
- **User Profile (`user_profiles`):** 1:1 extension of `auth.users` (full name, phone, avatar URL).
- **Role Definition (`roles` & `permissions`):** System-defined role templates mapped to granular permissions.
- **Role Assignment (`user_role_assignments`):** Links a `user_id` to an `organization_id`, optional `branch_id`, and `role_id`. Supports multi-org and multi-branch roles for the same user.
- **Member Profile (`members`):** Organization-scoped fitness customer record (optionally linked to `user_id` once the member activates their app account), home `branch_id`, status, emergency contact.

### 2.2 Commercial Catalog & Entitlement Context
- **Package (`packages`):** Commercial offering (`gym_membership`, `class_pack`, `pt_pack`, `hybrid`).
- **Package Entitlement Rule (`package_entitlement_rules`):** Declarative rules describing what buying a package provisions, backed by normalized join tables (`package_rule_branches`, `package_rule_class_types`):
  - Facility access rule: duration days, branch access mode (`single_branch`, `selected_branches`, `all_branches`), allowed branches via `package_rule_branches`.
  - Class credit rule: credit quantity, expiry days, class scope (`all_classes`, `selected_classes`) via `package_rule_class_types` and `package_rule_branches`.
  - PT credit rule: session quantity, expiry days, eligible branches via `package_rule_branches`.
- **Member Subscription (`member_subscriptions`):** Commercial contract instance (`pending`, `active`, `frozen`, `expired`, `cancelled`) with start/end timestamps and cumulative freeze duration tracking (`total_frozen_seconds`). Freezing a subscription atomically freezes its derived `member_entitlements`; unfreezing extends `ends_at` and `valid_until` by the exact frozen interval.
- **Member Entitlement (`member_entitlements`):** Active operational right derived from a subscription (`facility_access` or `unlimited_class`), scoped via `member_entitlement_branches` and `member_entitlement_class_types`.

### 2.3 Credit Ledger Context
- **Credit Grant (`credit_grants`):** Represents a specific bucket of credits issued to a member (source subscription/package, `credit_type` in `class_credit | pt_credit`, `initial_amount`, `remaining_amount`, `expires_at`), scoped via `credit_grant_branches` and `credit_grant_class_types`.
- **Credit Ledger Entry (`credit_ledger_entries`):** Immutable audit log of every balance movement:
  - `entry_type`: `grant`, `consume`, `refund`, `expire`, `adjustment`
  - `delta`: signed integer (`+N` or `-N`)
  - `grant_id`: references the exact `credit_grants` bucket consumed/refunded (enables strict FIFO expiration tracking across multi-grant bookings where `credit_cost > 1`)
  - `reference_type` / `reference_id`: links to `class_booking`, `pt_session`, `subscription`, or `manual_adjustment`
  - `idempotency_key`: per-grant composite idempotency key (`<request_key>:<grant_id>`) preventing duplicate credit deduction across multi-grant transactions and retries

*Design Note:* Maintaining both `credit_grants.remaining_amount` (updated exclusively inside locked RPC transactions alongside an immutable `credit_ledger_entries` insert) and an invariant check (`remaining_amount >= 0`) gives both O(1) locked consumption checks and full audit reconstructability.

### 2.4 Facility Access Context
- **Facility Visit (`facility_visits`):** Recorded gym check-in/check-out event (`member_id`, `branch_id`, `entitlement_id`, `checked_in_at`, `checked_out_at`, `checked_in_by`, `method` in `qr | manual_override`).
- **Access Attempt Log (`facility_access_attempts`):** Records both granted and denied scan attempts with reason codes (`OK`, `QR_EXPIRED`, `NO_FACILITY_ENTITLEMENT`, `BRANCH_NOT_COVERED`, `MEMBER_FROZEN`, `DUPLICATE_COOLDOWN`).

### 2.5 Studio Booking Context
- **Class Type (`class_types`):** Category/discipline (e.g., Reformer Pilates, Vinyasa Yoga, HIIT, Indoor Cycling).
- **Class Template (`class_templates`):** Reusable class blueprint (title, default duration, default capacity, credit cost, cancellation cutoff minutes).
- **Class Session (`class_sessions`):** Materialized scheduled instance (`branch_id`, `room_id`, `instructor_id`, `starts_at`, `ends_at`, `capacity`, `confirmed_count`, `waitlist_enabled`, `status` in `scheduled | in_progress | completed | cancelled`).
- **Class Booking (`class_bookings`):** Member reservation on a session (`status` in `confirmed | waitlisted | cancelled_early | cancelled_late | removed`, `attendance_status` in `pending | checked_in | no_show`, `credit_cost`, `waitlist_position`, `booked_at`, `cancelled_at`).

### 2.6 Personal Training Context *(Post-MVP Ready)*
- **Trainer Profile (`trainer_profiles`)** & **Trainer Availability (`trainer_availabilities`)**
- **PT Session (`pt_sessions`):** Private booking linked to `member_id`, `trainer_id`, `branch_id`, and `credit_ledger_entries` (`credit_type = 'pt_credit'`).

---

## 3. Concurrency, Locking & Integrity Analysis

| Race / Failure Scenario | Failure Risk Without Controls | RITMA Backend Control |
|---|---|---|
| **Concurrent last-seat class bookings** | Two members read `confirmed_count = 9/10` simultaneously and both book (overbooking to 11/10) | `book_class_session` RPC acquires `SELECT ... FROM class_sessions WHERE id = $1 FOR UPDATE`, re-checks `confirmed_count < capacity`, and enforces `CHECK (confirmed_count <= capacity)` plus a `BEFORE UPDATE` trigger blocking capacity reductions below `confirmed_count` |
| **Duplicate credit consumption on retry** | Mobile network drop causes client retry; member loses 2 credits for 1 booking | Unique `idempotency_key` on `class_bookings` and per-grant `idempotency_key` (`<key>:<grant_id>`) on `credit_ledger_entries` + unique partial index on `(session_id, member_id) WHERE status IN ('confirmed', 'waitlisted')` |
| **Double gym check-in on double-scan** | Receptionist scanner triggers twice in 1 second, inflating visit metrics | `validate_and_check_in` acquires `pg_advisory_xact_lock` on `(member_id, branch_id)` and rejects scans within configurable cooldown (default 15 minutes) |
| **Waitlist promotion race** | Two cancellations or concurrent booking + cancellation promote the same waitlisted member twice or promote out of order | Canonical lock ordering (`class_sessions` -> `class_bookings` -> `credit_grants ORDER BY id ASC`) serializes all mutations; members lacking credits are skipped with an audit entry, and auto-promotion is blocked after session start |
| **Payment & package grant replay** | Payment webhook or staff double-tap grants package twice | `payment_records.idempotency_key` UNIQUE constraint; RPC returns existing result idempotently |
| **Refund abuse / double refund** | Cancelling an already-cancelled booking triggers a second credit refund | State machine guard (`WHERE status = 'confirmed'`), plus partial unique index on `credit_ledger_entries(organization_id, reference_type, reference_id, grant_id) WHERE entry_type = 'refund'` |
| **Cross-branch privilege escalation** | Staff of Branch A submits `branch_id = Branch B` in RPC payload | Every RLS policy and RPC explicitly verifies `authz.has_permission(org_id, branch_id, 'permission.code')` server-side using `(SELECT auth.uid())` |

---

## 4. State Lifecycles

### Subscription Lifecycle
`pending` -> `active` <-> `frozen` -> `expired` | `cancelled`

### Booking Lifecycle
- Confirmed path: `confirmed` -> (`checked_in` | `no_show` | `cancelled_early` | `cancelled_late`)
- Waitlist path: `waitlisted` -> (`confirmed` [on promotion] | `cancelled_early` | `expired_unpromoted`)
