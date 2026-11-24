# RITMA — Database Architecture & Schema Specification

**Database Engine:** PostgreSQL 15+ (via Supabase)  
**Primary Keys:** `uuid` (`gen_random_uuid()`)  
**Timestamps:** `timestamptz` (UTC everywhere; display converted via branch/organization IANA timezone)  
**Money Representation:** Integer minor units (`amount_minor bigint`) + ISO-4217 `currency_code text`

---

## 1. Schema Conventions & Indexing Strategy

1. **Tenant Scoping on Every Business Table:** Every tenant-owned table includes `organization_id uuid NOT NULL REFERENCES organizations(id)` (and `branch_id uuid REFERENCES branches(id)` where branch-scoped) to keep RLS predicates fast and index-backed.
2. **Composite Indexes:** Every tenant table defines `(organization_id, ...)` composite indexes matching RLS predicates and operational queries (e.g., `(organization_id, branch_id, starts_at)` on `class_sessions`).
3. **Audit Columns:** `created_at timestamptz NOT NULL DEFAULT now()`, `updated_at timestamptz NOT NULL DEFAULT now()`, and `created_by uuid REFERENCES auth.users(id)` where applicable.
4. **Immutable Ledgers & Audit History:** Financial, visit, booking, and credit ledger tables are never hard-deleted. Catalog entities use `is_active boolean` or `archived_at timestamptz`.

---

## 2. Core Tables by Domain

### 2.1 Tenant, Identity & RBAC

| Table | Key Columns | Constraints & Notes |
|---|---|---|
| `organizations` | `id`, `name`, `slug` (unique), `business_type`, `timezone`, `currency_code`, `status`, `created_at` | Root tenant entity |
| `branches` | `id`, `organization_id`, `name`, `code`, `address`, `timezone`, `is_active` | `UNIQUE (organization_id, code)` |
| `rooms` | `id`, `organization_id`, `branch_id`, `name`, `default_capacity`, `is_active` | Scoped to a single branch |
| `user_profiles` | `user_id` (PK -> `auth.users.id`), `full_name`, `phone`, `avatar_path` | 1:1 user identity profile |
| `roles` | `id`, `code` (unique), `scope_level` (`organization` \| `branch` \| `member`), `display_name` | System roles: `org_owner`, `org_admin`, `branch_manager`, `receptionist`, `gym_staff`, `instructor`, `personal_trainer`, `member` |
| `permissions` | `code` (PK), `domain`, `description` | Granular codes (e.g., `checkin.perform`, `booking.manage`) |
| `role_permissions` | `role_id`, `permission_code` | Composite PK `(role_id, permission_code)` |
| `user_role_assignments` | `id`, `user_id`, `organization_id`, `branch_id` (nullable for org-wide), `role_id`, `status` (`active` \| `revoked`), `assigned_by`, `created_at` | Supports multi-org & multi-branch roles; unique active index on `(user_id, organization_id, COALESCE(branch_id, '00000000-0000-0000-0000-000000000000'::uuid), role_id) WHERE status = 'active'` |
| `members` | `id`, `organization_id`, `user_id` (nullable), `home_branch_id`, `member_code`, `full_name`, `email`, `phone`, `emergency_contact_name`, `emergency_contact_phone`, `status` (`active` \| `frozen` \| `suspended` \| `archived`) | `UNIQUE (organization_id, member_code)`; `UNIQUE (organization_id, user_id) WHERE user_id IS NOT NULL` |

### 2.2 Packages, Subscriptions & Entitlements

| Table | Key Columns | Constraints & Notes |
|---|---|---|
| `packages` | `id`, `organization_id`, `name`, `description`, `package_type` (`gym_membership` \| `class_pack` \| `pt_pack` \| `hybrid`), `price_minor`, `currency_code`, `is_active` | Commercial catalog |
| `package_entitlement_rules` | `id`, `organization_id`, `package_id`, `entitlement_kind` (`facility_access` \| `class_credit` \| `pt_credit` \| `unlimited_class`), `duration_days`, `credit_quantity`, `branch_access_scope` (`single_branch` \| `selected_branches` \| `all_branches`), `allowed_branch_ids uuid[]`, `allowed_class_type_ids uuid[]` | Explicit separation of rights granted on purchase |
| `member_subscriptions` | `id`, `organization_id`, `member_id`, `package_id`, `assigned_branch_id`, `status` (`pending` \| `active` \| `frozen` \| `expired` \| `cancelled`), `starts_at`, `ends_at`, `frozen_at`, `cancelled_at`, `idempotency_key` | `UNIQUE (organization_id, idempotency_key)` |
| `member_entitlements` | `id`, `organization_id`, `member_id`, `subscription_id`, `entitlement_kind` (`facility_access` \| `unlimited_class`), `branch_access_scope`, `allowed_branch_ids uuid[]`, `allowed_class_type_ids uuid[]`, `valid_from`, `valid_until`, `status` (`active` \| `frozen` \| `expired` \| `revoked`) | Evaluated by Facility Access Engine and Unlimited Class checks |
| `payment_records` | `id`, `organization_id`, `branch_id`, `member_id`, `subscription_id`, `amount_minor`, `currency_code`, `method` (`cash` \| `bank_transfer` \| `card_terminal` \| `gateway`), `status` (`pending` \| `paid` \| `refunded` \| `void`), `external_reference`, `idempotency_key`, `recorded_by`, `paid_at` | `UNIQUE (organization_id, idempotency_key)` for retry/webhook safety |

### 2.3 Credit Ledger

| Table | Key Columns | Constraints & Notes |
|---|---|---|
| `credit_grants` | `id`, `organization_id`, `member_id`, `subscription_id`, `credit_type` (`class_credit` \| `pt_credit`), `initial_amount`, `remaining_amount`, `allowed_branch_ids uuid[]`, `allowed_class_type_ids uuid[]`, `expires_at`, `status` (`active` \| `depleted` \| `expired` \| `revoked`) | `CHECK (initial_amount > 0 AND remaining_amount >= 0 AND remaining_amount <= initial_amount)` |
| `credit_ledger_entries` | `id`, `organization_id`, `member_id`, `grant_id`, `credit_type`, `entry_type` (`grant` \| `consume` \| `refund` \| `expire` \| `adjustment`), `delta` (non-zero int), `reference_type`, `reference_id`, `idempotency_key`, `reason`, `actor_user_id`, `created_at` | Append-only (UPDATE/DELETE blocked by trigger & RLS); `UNIQUE (organization_id, idempotency_key)`; partial unique index preventing double refunds per booking |

### 2.4 Facility Access Engine

| Table | Key Columns | Constraints & Notes |
|---|---|---|
| `facility_visits` | `id`, `organization_id`, `branch_id`, `member_id`, `entitlement_id`, `check_in_method` (`qr` \| `manual`), `checked_in_at`, `checked_out_at`, `checked_in_by`, `idempotency_key` | Index on `(organization_id, branch_id, checked_in_at DESC)` for live occupancy & peak-hour charts |
| `facility_access_attempts` | `id`, `organization_id`, `branch_id`, `member_id` (nullable if invalid QR), `result` (`allowed` \| `denied`), `reason_code`, `scanned_by`, `attempted_at` | Full security & troubleshooting trail |

### 2.5 Studio Booking Engine

| Table | Key Columns | Constraints & Notes |
|---|---|---|
| `class_types` | `id`, `organization_id`, `name`, `color_token`, `is_active` | e.g., Reformer Pilates, Yoga, Cycling |
| `class_templates` | `id`, `organization_id`, `class_type_id`, `title`, `description`, `default_duration_minutes`, `default_capacity`, `default_credit_cost`, `cancellation_cutoff_minutes`, `is_active` | Reusable class blueprint |
| `class_sessions` | `id`, `organization_id`, `branch_id`, `room_id`, `class_template_id`, `class_type_id`, `instructor_user_id`, `title`, `starts_at`, `ends_at`, `capacity`, `confirmed_count`, `credit_cost`, `cancellation_cutoff_at`, `waitlist_enabled`, `status` (`scheduled` \| `in_progress` \| `completed` \| `cancelled`) | `CHECK (capacity > 0 AND confirmed_count >= 0 AND confirmed_count <= capacity)`; `CHECK (ends_at > starts_at)` |
| `class_bookings` | `id`, `organization_id`, `branch_id`, `session_id`, `member_id`, `status` (`confirmed` \| `waitlisted` \| `cancelled_early` \| `cancelled_late` \| `expired_unpromoted`), `attendance_status` (`pending` \| `checked_in` \| `no_show`), `waitlist_position`, `credit_cost`, `booked_by`, `idempotency_key`, `booked_at`, `cancelled_at`, `attendance_marked_at`, `attendance_marked_by` | Partial unique index `UNIQUE (session_id, member_id) WHERE status IN ('confirmed', 'waitlisted')`; `UNIQUE (organization_id, idempotency_key)` |

### 2.6 Audit Log

| Table | Key Columns | Constraints & Notes |
|---|---|---|
| `audit_logs` | `id`, `organization_id`, `branch_id`, `actor_user_id`, `action`, `target_type`, `target_id`, `metadata jsonb`, `created_at` | Append-only immutable compliance log |

---

## 3. Transactional RPC Functions (Backend Business Engines)

All multi-table state mutations execute via PostgreSQL RPC functions rather than multi-step client writes:

1. `create_organization_with_owner(p_name, p_slug, p_timezone, p_currency, p_first_branch_name)`
2. `assign_package_to_member(p_org_id, p_branch_id, p_member_id, p_package_id, p_starts_at, p_payment_method, p_idempotency_key)`
3. `issue_member_qr_token(p_org_id, p_member_id)` -> returns short-lived HMAC-signed token payload (TTL 60s)
4. `validate_and_check_in(p_org_id, p_branch_id, p_qr_token, p_idempotency_key)`
5. `book_class_session(p_org_id, p_session_id, p_member_id, p_idempotency_key)`
6. `cancel_class_booking(p_org_id, p_booking_id, p_reason)` (includes serialized waitlist promotion)
7. `mark_class_attendance(p_org_id, p_booking_id, p_attendance_status)`
8. `adjust_member_credits(p_org_id, p_member_id, p_credit_type, p_delta, p_reason, p_idempotency_key)`
