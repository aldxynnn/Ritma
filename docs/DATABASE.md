# RITMA — Database Architecture & Schema Specification

**Database Engine:** PostgreSQL 15+ (via Supabase)  
**Primary Keys:** `uuid` (`gen_random_uuid()`)  
**Timestamps:** `timestamptz` (UTC everywhere; display converted via branch/organization IANA timezone)  
**Money Representation:** Integer minor units (`amount_minor bigint`) + ISO-4217 `currency_code text`

---

## 1. Schema Conventions & Indexing Strategy

1. **Tenant Scoping & Cross-Tenant FK Integrity (F1):** Every tenant-owned table includes `organization_id uuid NOT NULL REFERENCES organizations(id)` (and `branch_id uuid` where branch-scoped). Parent tables expose composite `UNIQUE (organization_id, id)` (and `UNIQUE (organization_id, branch_id, id)` for `rooms` and `class_sessions`), and child tables use composite foreign keys `FOREIGN KEY (organization_id, ...)` so cross-organization or cross-branch relational references are rejected at the PostgreSQL constraint layer.
2. **Normalized Eligibility Join Tables (F4):** Rather than unvalidated `uuid[]` arrays (`allowed_branch_ids`, `allowed_class_type_ids`), branch and class-type scoping uses normalized join tables (`package_rule_branches`, `package_rule_class_types`, `member_entitlement_branches`, `member_entitlement_class_types`, `credit_grant_branches`, `credit_grant_class_types`) carrying composite tenant foreign keys.
3. **Composite Indexes:** Every tenant table defines `(organization_id, ...)` composite indexes matching RLS predicates and operational queries (e.g., `(organization_id, branch_id, starts_at)` on `class_sessions`).
4. **Audit Columns:** `created_at timestamptz NOT NULL DEFAULT now()`, `updated_at timestamptz NOT NULL DEFAULT now()`, and `created_by uuid REFERENCES auth.users(id)` where applicable.
5. **Immutable Ledgers & Audit History:** `credit_ledger_entries` and `audit_logs` enforce immutability triggers blocking `UPDATE` and `DELETE`. Catalog entities use `is_active boolean` or `archived_at timestamptz`.

---

## 2. Core Tables by Domain

### 2.1 Tenant, Identity, Secrets & RBAC

| Table | Key Columns | Constraints & Notes |
|---|---|---|
| `organizations` | `id`, `name`, `slug` (unique), `business_type`, `timezone`, `currency_code`, `status`, `created_at`, `updated_at` | Root tenant entity |
| `private.organization_signing_keys` | `id`, `organization_id`, `key_version`, `secret_key` (`bytea`), `is_active`, `created_at`, `rotated_at` | Per-organization QR HMAC signing keys (F7). Resides in `private` schema with `REVOKE ALL FROM PUBLIC, anon, authenticated` |
| `branches` | `id`, `organization_id`, `name`, `code`, `address`, `timezone`, `is_active` | `UNIQUE (organization_id, code)`, `UNIQUE (organization_id, id)` |
| `rooms` | `id`, `organization_id`, `branch_id`, `name`, `default_capacity`, `is_active` | Composite FK `(organization_id, branch_id)` -> `branches(organization_id, id)`; `UNIQUE (organization_id, branch_id, id)` |
| `user_profiles` | `user_id` (PK -> `auth.users.id`), `full_name`, `phone`, `avatar_path` | 1:1 user identity profile |
| `roles` | `id`, `code` (unique), `rank` (int), `scope_level` (`organization` \| `branch` \| `member`), `display_name` | Hierarchy rank (F8): `org_owner=100`, `org_admin=80`, `branch_manager=60`, `receptionist=40`, `gym_staff=30`, `instructor=30`, `personal_trainer=30`, `member=10` |
| `permissions` | `code` (PK), `domain`, `description` | Granular codes (e.g., `checkin.perform`, `booking.manage`) |
| `role_permissions` | `role_id`, `permission_code` | Composite PK `(role_id, permission_code)` |
| `user_role_assignments` | `id`, `user_id`, `organization_id`, `branch_id` (nullable for org-wide), `role_id`, `status` (`active` \| `revoked`), `assigned_by`, `created_at`, `revoked_at` | Composite FK `(organization_id, branch_id)` -> `branches(organization_id, id)` when non-null; unique active index on `(user_id, organization_id, COALESCE(branch_id, '00000000-0000-0000-0000-000000000000'::uuid), role_id) WHERE status = 'active'` |
| `members` | `id`, `organization_id`, `user_id` (nullable), `home_branch_id`, `member_code`, `full_name`, `email`, `phone`, `emergency_contact_name`, `emergency_contact_phone`, `status` (`active` \| `frozen` \| `suspended` \| `archived`) | Composite FK `(organization_id, home_branch_id)` -> `branches`; `UNIQUE (organization_id, id)`; `UNIQUE (organization_id, member_code)`; `UNIQUE (organization_id, user_id) WHERE user_id IS NOT NULL` |

### 2.2 Packages, Subscriptions & Entitlements

| Table | Key Columns | Constraints & Notes |
|---|---|---|
| `class_types` | `id`, `organization_id`, `name`, `color_token`, `is_active` | `UNIQUE (organization_id, id)`, `UNIQUE (organization_id, name)` |
| `packages` | `id`, `organization_id`, `name`, `description`, `package_type` (`gym_membership` \| `class_pack` \| `pt_pack` \| `hybrid`), `price_minor`, `currency_code`, `is_active` | `UNIQUE (organization_id, id)` |
| `package_entitlement_rules` | `id`, `organization_id`, `package_id`, `entitlement_kind` (`facility_access` \| `class_credit` \| `pt_credit` \| `unlimited_class`), `duration_days`, `credit_quantity`, `branch_access_scope` (`single_branch` \| `selected_branches` \| `all_branches`), `class_scope` (`all_classes` \| `selected_classes`) | Composite FK `(organization_id, package_id)` -> `packages`; `UNIQUE (organization_id, id)` |
| `package_rule_branches` | `organization_id`, `rule_id`, `branch_id` | Normalized join table (F4); composite FKs to `package_entitlement_rules` & `branches` |
| `package_rule_class_types` | `organization_id`, `rule_id`, `class_type_id` | Normalized join table (F4); composite FKs to `package_entitlement_rules` & `class_types` |
| `member_subscriptions` | `id`, `organization_id`, `member_id`, `package_id`, `assigned_branch_id`, `status` (`pending` \| `active` \| `frozen` \| `expired` \| `cancelled`), `starts_at`, `ends_at`, `frozen_at`, `total_frozen_seconds`, `cancelled_at`, `idempotency_key` | Composite FKs to `members`, `packages`, `branches`; `UNIQUE (organization_id, id)`; `UNIQUE (organization_id, idempotency_key)` |
| `member_entitlements` | `id`, `organization_id`, `member_id`, `subscription_id`, `entitlement_kind` (`facility_access` \| `unlimited_class`), `branch_access_scope`, `class_scope`, `valid_from`, `valid_until`, `status` (`active` \| `frozen` \| `expired` \| `revoked`) | Frozen/unfrozen atomically with subscription (F9); `UNIQUE (organization_id, id)` |
| `member_entitlement_branches` | `organization_id`, `entitlement_id`, `branch_id` | Composite FKs to `member_entitlements` & `branches` |
| `member_entitlement_class_types` | `organization_id`, `entitlement_id`, `class_type_id` | Composite FKs to `member_entitlements` & `class_types` |
| `payment_records` | `id`, `organization_id`, `branch_id`, `member_id`, `subscription_id`, `amount_minor`, `currency_code`, `method` (`cash` \| `bank_transfer` \| `card_terminal` \| `gateway`), `status` (`pending` \| `paid` \| `refunded` \| `void`), `external_reference`, `idempotency_key`, `recorded_by`, `paid_at` | `UNIQUE (organization_id, idempotency_key)` for retry/webhook safety |

### 2.3 Credit Ledger

| Table | Key Columns | Constraints & Notes |
|---|---|---|
| `credit_grants` | `id`, `organization_id`, `member_id`, `subscription_id`, `credit_type` (`class_credit` \| `pt_credit`), `branch_access_scope`, `class_scope`, `initial_amount`, `remaining_amount`, `expires_at`, `status` (`active` \| `depleted` \| `expired` \| `revoked`) | `CHECK (initial_amount > 0 AND remaining_amount >= 0 AND remaining_amount <= initial_amount)`; `UNIQUE (organization_id, id)` |
| `credit_grant_branches` | `organization_id`, `grant_id`, `branch_id` | Composite FKs to `credit_grants` & `branches` |
| `credit_grant_class_types` | `organization_id`, `grant_id`, `class_type_id` | Composite FKs to `credit_grants` & `class_types` |
| `credit_ledger_entries` | `id`, `organization_id`, `member_id`, `grant_id`, `credit_type`, `entry_type` (`grant` \| `consume` \| `refund` \| `expire` \| `adjustment`), `delta` (non-zero int), `reference_type`, `reference_id`, `idempotency_key`, `reason`, `actor_user_id`, `created_at` | Append-only (`UPDATE`/`DELETE` blocked by trigger); `UNIQUE (organization_id, idempotency_key)` using per-grant key `key || ':' || grant_id`; partial unique index `(organization_id, reference_type, reference_id, grant_id) WHERE entry_type = 'refund'` (F5) |

### 2.4 Facility Access Engine

| Table | Key Columns | Constraints & Notes |
|---|---|---|
| `facility_visits` | `id`, `organization_id`, `branch_id`, `member_id`, `entitlement_id`, `check_in_method` (`qr` \| `manual`), `checked_in_at`, `checked_out_at`, `checked_in_by`, `idempotency_key` | Composite FKs to `branches`, `members`, `member_entitlements`; `UNIQUE (organization_id, idempotency_key)`; index `(organization_id, branch_id, checked_in_at DESC)` |
| `facility_access_attempts` | `id`, `organization_id`, `branch_id`, `member_id` (nullable if invalid QR), `result` (`allowed` \| `denied`), `reason_code`, `scanned_by`, `attempted_at` | Full security & troubleshooting trail |

### 2.5 Studio Booking Engine

| Table | Key Columns | Constraints & Notes |
|---|---|---|
| `class_templates` | `id`, `organization_id`, `class_type_id`, `title`, `description`, `default_duration_minutes`, `default_capacity`, `default_credit_cost`, `cancellation_cutoff_minutes`, `is_active` | Composite FK `(organization_id, class_type_id)` -> `class_types`; `UNIQUE (organization_id, id)` |
| `class_sessions` | `id`, `organization_id`, `branch_id`, `room_id`, `class_template_id`, `class_type_id`, `instructor_user_id`, `title`, `starts_at`, `ends_at`, `capacity`, `confirmed_count`, `credit_cost`, `cancellation_cutoff_at`, `waitlist_enabled`, `status` (`scheduled` \| `in_progress` \| `completed` \| `cancelled`) | Composite FKs to `rooms(organization_id, branch_id, id)` and `class_types`; `UNIQUE (organization_id, branch_id, id)`; `CHECK (capacity > 0 AND confirmed_count >= 0 AND confirmed_count <= capacity)`; `BEFORE UPDATE` trigger blocks `capacity < confirmed_count` and guards `confirmed_count` (F9) |
| `class_bookings` | `id`, `organization_id`, `branch_id`, `session_id`, `member_id`, `status` (`confirmed` \| `waitlisted` \| `cancelled_early` \| `cancelled_late` \| `expired_unpromoted`), `attendance_status` (`pending` \| `checked_in` \| `no_show`), `waitlist_position`, `credit_cost`, `booked_by`, `idempotency_key`, `booked_at`, `cancelled_at`, `attendance_marked_at`, `attendance_marked_by` | Composite FK `(organization_id, branch_id, session_id)` -> `class_sessions`; partial unique index `UNIQUE (session_id, member_id) WHERE status IN ('confirmed', 'waitlisted')`; `UNIQUE (organization_id, idempotency_key)` |

### 2.6 Audit Log & Post-MVP Schema Extensions

| Table | Key Columns | Constraints & Notes |
|---|---|---|
| `audit_logs` | `id`, `organization_id`, `branch_id`, `actor_user_id`, `action`, `target_type`, `target_id`, `metadata jsonb`, `created_at` | Append-only immutable compliance log (`UPDATE`/`DELETE` blocked by trigger) |
| `trainer_profiles`, `trainer_availabilities`, `pt_sessions` | Scoped with `(organization_id, branch_id)` composite FKs | Post-MVP Personal Training schema ready in `20261124000500` |
| `equipment_assets`, `equipment_maintenance_tickets`, `user_notifications` | Scoped with `(organization_id, branch_id)` composite FKs | Post-MVP Equipment & Notifications schema ready in `20261124000500` |

---

## 3. Transactional RPC Functions (Backend Business Engines)

All multi-table state mutations execute via hardened `SECURITY DEFINER` PostgreSQL RPC functions (`SET search_path = pg_catalog, public, pg_temp`, explicit permission checks via `(SELECT auth.uid())`):

1. `create_organization_with_owner(p_name, p_slug, p_business_type, p_timezone, p_currency_code, p_first_branch_name, p_first_branch_code)`
2. `invite_user_to_organization(p_org_id, p_invited_email, p_role_code, p_branch_id)`, `accept_organization_invitation(p_token)`, `assign_user_role(p_org_id, p_target_user_id, p_role_code, p_branch_id)`, `revoke_user_role(p_org_id, p_assignment_id)`
3. `invite_member_claim(p_org_id, p_member_id, p_email)`, `claim_member_profile(p_token)`, `set_member_status(p_org_id, p_member_id, p_status, p_reason)`, `lookup_member_for_checkin(p_org_id, p_branch_id, p_query)`
4. `get_my_workspaces()`
5. `assign_package_to_member(p_org_id, p_branch_id, p_member_id, p_package_id, p_starts_at, p_payment_method, p_idempotency_key)`
6. `freeze_member_subscription(p_org_id, p_subscription_id, p_reason)` & `unfreeze_member_subscription(p_org_id, p_subscription_id)` (atomically freezes/extends entitlements and credit grants)
7. `adjust_member_credits(p_org_id, p_member_id, p_credit_type, p_delta, p_reason, p_idempotency_key, p_expires_at)` (backed by `credit_adjustments` idempotency table + role cap)
8. `rotate_org_signing_key(p_org_id)` & `issue_member_qr_token(p_org_id, p_member_id)`
9. `validate_and_check_in(p_org_id, p_branch_id, p_qr_token, p_idempotency_key, p_cooldown_minutes)` (single-use nonce + fingerprint binding), `manual_facility_check_in(...)`, `check_out_facility_visit(p_org_id, p_visit_id)`
10. `get_session_roster(p_org_id, p_session_id)`, `book_class_session(p_org_id, p_session_id, p_member_id, p_idempotency_key)`, `cancel_class_booking(p_org_id, p_booking_id, p_reason)`, `cancel_class_session(p_org_id, p_session_id, p_reason)`, `mark_class_attendance(p_org_id, p_booking_id, p_attendance_status)`
11. `get_operational_dashboard_metrics(p_org_id, p_branch_id, p_window_days)`
12. `book_pt_session(p_org_id, p_branch_id, p_trainer_id, p_member_id, p_starts_at, p_ends_at, p_credit_cost, p_idempotency_key)` & `complete_pt_session(p_org_id, p_pt_session_id, p_notes)`
