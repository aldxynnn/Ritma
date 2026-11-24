# RITMA — Security Architecture & Supabase RLS Strategy

## 1. Security Posture & Core Principles

1. **Zero Trust in Client State:** Flutter UI hiding a button or restricting a route is strictly a UX affordance—never a security boundary. Every data access and state mutation is authorized inside PostgreSQL (RLS + transactional RPCs).
2. **Deny by Default:** Every `public` business table MUST have `ALTER TABLE ... ENABLE ROW LEVEL SECURITY;` and `ALTER TABLE ... FORCE ROW LEVEL SECURITY;` enabled before production use. Never deploy `USING (true)` policies on tenant tables.
3. **Strict Tenant & Branch Isolation:** Every query is bound to `(SELECT auth.uid())` and the caller's active `user_role_assignments` for the target `organization_id` and (where applicable) `branch_id`. Composite tenant foreign keys guarantee relational integrity at the storage layer (F1).
4. **Least Privilege & Immutable Accounting:** Direct `INSERT`/`UPDATE`/`DELETE` on `user_role_assignments`, `credit_ledger_entries`, `credit_grants`, `member_entitlements`, `member_subscriptions`, `facility_visits`, `payment_records`, and `audit_logs` is denied to authenticated clients; mutations happen strictly through audited RPC functions.

---

## 2. Row Level Security (RLS) Design

### 2.1 Centralized Authorization Helper Functions (`authz` schema)
To avoid recursive RLS lookups and optimize PostgreSQL InitPlan caching, RITMA defines `SECURITY DEFINER`, `STABLE` helper functions in `authz` with `SET search_path = pg_catalog, public` that derive the caller exclusively via `(SELECT auth.uid())` (never accepting a caller-supplied `p_user_id`) (F2):

- `authz.has_permission(p_org_id uuid, p_branch_id uuid, p_permission text) returns boolean`
  - When `p_branch_id IS NULL`: matches **only** organization-wide role assignments (`ura.branch_id IS NULL`) carrying `p_permission`.
  - When `p_branch_id IS NOT NULL`: matches either organization-wide role assignments (`ura.branch_id IS NULL`) OR branch-specific assignments (`ura.branch_id = p_branch_id`) carrying `p_permission`.
- `authz.has_any_branch_permission(p_org_id uuid, p_permission text) returns boolean`
  - Matches any active role assignment in `p_org_id` carrying `p_permission` (used strictly for org-wide member lookup at check-in/booking without exposing branch-scoped financials).
- `authz.is_org_participant(p_org_id uuid) returns boolean`
  - True when `(SELECT auth.uid())` has an active role assignment in `p_org_id` OR an active/frozen `members` record (`user_id = (SELECT auth.uid())`) in `p_org_id`.
- `authz.is_self_member(p_org_id uuid, p_member_id uuid) returns boolean`
  - True when `members.id = p_member_id AND members.organization_id = p_org_id AND members.user_id = (SELECT auth.uid())`.

### 2.2 Table-Level Policy Blueprint

| Table | `SELECT` Policy | `INSERT / UPDATE / DELETE` Policy |
|---|---|---|
| `organizations` | `authz.is_org_participant(id)` | `INSERT` via `create_organization_with_owner` RPC only; `UPDATE` requires `authz.has_permission(id, NULL, 'org.manage')`; `DELETE` denied |
| `branches`, `rooms` | `authz.is_org_participant(organization_id)` | Requires `authz.has_permission(organization_id, NULL, 'branch.manage')` |
| `user_role_assignments` | Own rows (`user_id = (SELECT auth.uid())`) OR `authz.has_permission(organization_id, branch_id, 'role.assign')` | **Direct client writes DENIED.** Mutated strictly via `assign_user_role` and `revoke_user_role` RPCs (hierarchy + last-owner guard) (F8) |
| `members` | `authz.has_permission(organization_id, home_branch_id, 'member.read')`, OR `user_id = (SELECT auth.uid())` (cross-branch check-in uses `lookup_member_for_checkin` RPC; instructors use `get_session_roster` RPC without PII) | `authz.has_permission(organization_id, home_branch_id, 'member.write')`; trigger blocks direct edits to `user_id`, `organization_id`, and `status` outside dedicated RPCs (`claim_member_profile`, `set_member_status`) |
| `member_subscriptions`, `member_entitlements`, `credit_grants`, `credit_ledger_entries` | `authz.has_permission(organization_id, home_branch_id / assigned_branch_id, 'entitlement.read')` OR `authz.is_self_member(organization_id, member_id)` | **Direct client writes DENIED.** Mutated strictly through transactional RPCs (`assign_package_to_member`, `freeze_member_subscription`, `book_class_session`, `cancel_class_booking`, `adjust_member_credits`) |
| `facility_visits`, `facility_access_attempts` | `authz.has_permission(organization_id, branch_id, 'checkin.read')` OR `authz.is_self_member(organization_id, member_id)` | **Direct client writes DENIED.** Mutated via `validate_and_check_in`, `manual_facility_check_in`, `check_out_facility_visit` RPCs |
| `class_sessions` | `authz.is_org_participant(organization_id)` | Requires `authz.has_permission(organization_id, branch_id, 'schedule.manage')`; `BEFORE INSERT OR UPDATE` trigger enforces `confirmed_count`, capacity, valid instructor assignment, and blocks direct cancellation outside `cancel_class_session` RPC (F9, M7) |
| `class_bookings` | `authz.has_permission(organization_id, branch_id, 'booking.read')` OR active assigned instructor within 2 days (`attendance.mark`) OR `authz.is_self_member(organization_id, member_id)` | **Direct client writes DENIED.** Mutated via `book_class_session`, `cancel_class_booking`, `mark_class_attendance` RPCs |
| `payment_records` | `authz.has_permission(organization_id, branch_id, 'payment.read')` OR `authz.is_self_member(organization_id, member_id)` | **Direct client writes DENIED.** Recorded via transactional package assignment / payment RPCs only |
| `audit_logs` | `authz.has_permission(organization_id, branch_id, 'audit.read')` (when `branch_id IS NOT NULL`, branch managers see their branch only; org-wide staff see all) | **Direct client writes DENIED.** Written internally by RPCs/triggers only (`UPDATE`/`DELETE` blocked by trigger) |
| `private.organization_signing_keys` | **No API access** (`private` schema excluded from PostgREST; `REVOKE ALL FROM PUBLIC, anon, authenticated`) | Managed exclusively by `create_organization_with_owner` and key-rotation RPCs (F7) |

---

## 3. `SECURITY DEFINER` Function Governance

Every `SECURITY DEFINER` function in RITMA MUST obey five mandatory hardening rules:
1. **Pinned `search_path`:** Declare `SET search_path = pg_catalog, public, pg_temp` (or `pg_catalog, public, extensions, pg_temp` when invoking `pgcrypto`) so system catalogs and `public` resolve before `pg_temp`, preventing search-path hijacking.
2. **Explicit Caller Verification First:** First executable lines verify `(SELECT auth.uid()) IS NOT NULL` and check `authz.has_permission(...)` or `authz.is_self_member(...)` before taking locks or returning idempotent replays—never trust caller-supplied user IDs.
3. **Restricted Execution Privileges:** `REVOKE ALL ON FUNCTION ... FROM PUBLIC, anon;` and `GRANT EXECUTE ON FUNCTION ... TO authenticated;`.
4. **Minimal Scope & Parameterized SQL:** No dynamic SQL string concatenation; guard sensitive column/count mutations via transaction-local GUCs (`ritma.allow_count_mutation`, `ritma.allow_session_cancel`, `ritma.allow_member_sensitive_mutation`).
5. **Mandatory Audit Trail:** Sensitive mutations (`organization.created`, `role.invited`, `role.assigned`, `role.revoked`, `signing_key.rotated`, `package.assigned`, `subscription.frozen`, `credit.adjusted`, `checkin.force_override`, `session.cancelled`, `waitlist.skipped_insufficient_credits`) write an immutable row to `audit_logs` within the same transaction.

---

## 4. Secure QR Validation Protocol (Per-Org Keys & Nonce Replay Protection)

Static member ID barcodes are trivially screenshot-shared and spoofed. RITMA uses **single-use, short-lived, per-organization HMAC-SHA256 signed rotating tokens**:

1. **Per-Org Secret Storage & Rotation:** `create_organization_with_owner` provisions a 32-byte random key in `private.organization_signing_keys` (`organization_id`, `key_version`, `secret_key`, `is_active`). `rotate_org_signing_key` rotates compromised keys with a 2-minute grace window for in-flight tokens.
2. **Token Issuance (`issue_member_qr_token`):** Verifies caller is `authz.is_self_member(p_org_id, p_member_id)` or staff with `checkin.perform`. Generates:
   `v1.<base64url(org_id|member_id|issued_epoch|expires_epoch|key_version|nonce)>.<base64url(hmac_sha256(payload_b64, org_secret))>` with a **60-second TTL** (client refreshes every 45s).
3. **Server-Side Verification (`validate_and_check_in`):**
   - Verifies scanning staff holds `checkin.perform` on `(p_org_id, p_branch_id)` and binds `idempotency_key` to a SHA-256 request fingerprint.
   - Parses payload, validates `token_org_id == p_org_id`, verifies active (or within 2m grace) signing key, verifies HMAC-SHA256 using constant-time byte comparison, and enforces `expires_epoch - issued_epoch <= 65`.
   - Inserts `nonce` into `private.qr_token_uses` (`QR_REPLAYED` if already consumed, closing cross-branch screenshot replay).
   - Rejects expired tokens (`now_epoch > expires_epoch + 10`) with `QR_TOKEN_EXPIRED`.
   - Acquires `pg_advisory_xact_lock`, enforces server-clamped duplicate check-in cooldown (`GREATEST(COALESCE(p_cooldown_minutes, 15), 1)`), checks `members.status = 'active'` and active `facility_access` entitlement covering `p_branch_id`.
   - Logs outcome to `facility_access_attempts` and inserts `facility_visits` on allow.
4. **Manual Check-In Fallback (`manual_facility_check_in`):** Coalesces `p_force_override` to `false` (blocking NULL bypasses), checks `member.status` identically to QR check-in, and checks active `facility_access` entitlement; bypassing missing entitlement or frozen status requires `checkin.force_override`, mandatory non-empty `p_reason`, and an `audit_logs` alert.

---

## 5. Sensitive Financial & Privacy Protections

- **Member Data Privacy (PII):** Emergency contact info, phone numbers, and visit logs are restricted to authorized staff within the member's organization; instructors viewing a class roster see bookings only for sessions assigned to them (`instructor_user_id = (SELECT auth.uid())`) and NEVER see unrelated members or `payment_records`.
- **Financial Operations:** Manual credit adjustments and refunds require explicit elevated permissions (`credit.adjust`, `payment.refund`), mandatory non-empty reason, idempotency key, and immutable audit entries.
- **Storage Bucket Policies (Supabase Storage):**
  - `org-public-assets`: Public read for org logos & class cover photos; write restricted to `org.manage` on path prefix `<organization_id>/...`.
  - `member-private-media`: Private bucket; signed URLs issued only to `authz.is_self_member` or staff with `member.read` on `<organization_id>/...`.
- **Secret Management:** Client apps receive ONLY `SUPABASE_URL` and `SUPABASE_ANON_KEY` via `--dart-define`. `SUPABASE_SERVICE_ROLE_KEY`, database passwords, and future payment gateway keys never enter Git or client bundles.
