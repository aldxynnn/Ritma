# RITMA — Security Architecture & Supabase RLS Strategy

## 1. Security Posture & Core Principles

1. **Zero Trust in Client State:** Flutter UI hiding a button or restricting a route is strictly a UX affordance—never a security boundary. Every data access and state mutation is authorized inside PostgreSQL (RLS + transactional RPCs).
2. **Deny by Default:** Every public-schema business table MUST have `ALTER TABLE ... ENABLE ROW LEVEL SECURITY;` and `ALTER TABLE ... FORCE ROW LEVEL SECURITY;` enabled before any production data exists. Never deploy `USING (true)` policies on tenant tables.
3. **Strict Tenant & Branch Isolation:** Every query is bound to `auth.uid()` and the caller's active `user_role_assignments` for the target `organization_id` and (where applicable) `branch_id`.
4. **Least Privilege & Immutable Accounting:** Direct `INSERT`/`UPDATE`/`DELETE` on `credit_ledger_entries`, `credit_grants`, `member_entitlements`, `facility_visits`, `payment_records`, and `audit_logs` is denied to authenticated clients; mutations happen strictly through audited RPC functions.

---

## 2. Row Level Security (RLS) Design

### 2.1 Centralized Authorization Helper Functions
To avoid duplicating brittle subqueries across dozens of policies, RITMA defines indexed, `STABLE` PostgreSQL helper functions in an internal `authz` schema (or locked `public` helpers):

- `authz.has_permission(p_org_id uuid, p_branch_id uuid, p_permission text) returns boolean`
  - Checks whether `auth.uid()` holds an `active` row in `user_role_assignments` for `p_org_id` where either:
    - `branch_id IS NULL` (organization-wide role such as `org_owner` or `org_admin`), OR
    - `branch_id = p_branch_id` (branch-scoped role such as `branch_manager`, `receptionist`, `instructor`),
  - AND the assigned `role_id` maps to `p_permission` in `role_permissions`.
- `authz.is_self_member(p_org_id uuid, p_member_id uuid) returns boolean`
  - Checks whether `members.id = p_member_id AND members.organization_id = p_org_id AND members.user_id = auth.uid()`.

### 2.2 Table-Level Policy Blueprint

| Table | `SELECT` Policy | `INSERT / UPDATE / DELETE` Policy |
|---|---|---|
| `organizations` | User has any active role assignment or linked `members` row in `id` | `INSERT` via `create_organization_with_owner` RPC only; `UPDATE` requires `org.manage`; `DELETE` denied |
| `branches`, `rooms` | User belongs to `organization_id` (staff or active member) | Requires `branch.manage` on `organization_id` |
| `members` | Staff with `member.read` on `organization_id` (and branch scope if restricted), OR `user_id = auth.uid()` (self-view) | Staff with `member.write`; self can only update limited contact fields via dedicated RPC (never `status` or `organization_id`) |
| `member_subscriptions`, `member_entitlements`, `credit_grants`, `credit_ledger_entries` | Staff with `entitlement.read` on `organization_id`, OR `authz.is_self_member(organization_id, member_id)` | **Direct client writes DENIED.** All mutations flow through transactional RPCs (`assign_package_to_member`, `book_class_session`, `cancel_class_booking`, `adjust_member_credits`) |
| `facility_visits` | Staff with `checkin.read` on `(organization_id, branch_id)`, OR `authz.is_self_member(organization_id, member_id)` | **Direct client writes DENIED.** Mutations via `validate_and_check_in` / `check_out_visit` RPCs only |
| `class_sessions` | Authenticated users belonging to `organization_id` (members view published `scheduled` sessions; staff view branch sessions) | Requires `schedule.manage` on `(organization_id, branch_id)` |
| `class_bookings` | Staff with `booking.read` / `attendance.mark` on `(organization_id, branch_id)` (instructors restricted to their assigned sessions or branch policy), OR `authz.is_self_member(organization_id, member_id)` | **Direct client writes DENIED.** Mutations via `book_class_session`, `cancel_class_booking`, `mark_class_attendance` RPCs |
| `payment_records` | Staff with `payment.read` on `(organization_id, branch_id)`, OR `authz.is_self_member(organization_id, member_id)` | **Direct client writes DENIED.** Recorded via transactional package assignment / payment RPCs only |
| `audit_logs` | Staff with `audit.read` on `organization_id` (branch-filtered for branch managers) | **Direct client writes DENIED.** Written internally by RPCs/triggers only |

---

## 3. `SECURITY DEFINER` Function Governance

Certain workflows **require** `SECURITY DEFINER` (for example: `create_organization_with_owner` bootstrapping the first role assignment; `book_class_session` updating `class_sessions.confirmed_count` and posting to `credit_ledger_entries` while direct table writes are revoked; `validate_and_check_in` verifying a member's entitlements across branch scope).

Every `SECURITY DEFINER` function in RITMA MUST obey five mandatory hardening rules:
1. **Pinned `search_path`:** Declare `SET search_path = pg_catalog, public` (or `pg_temp` excluded) on the function header to prevent search-path hijacking.
2. **Explicit Caller Verification First:** The first executable lines MUST verify `auth.uid() IS NOT NULL` and check `authz.has_permission(...)` or `authz.is_self_member(...)`—never assume RLS ran for the caller.
3. **Restricted Execution Privileges:** Run `REVOKE ALL ON FUNCTION ... FROM PUBLIC;` and `GRANT EXECUTE ON FUNCTION ... TO authenticated;` (never grant to `anon`).
4. **Minimal Owner Scope:** Own security-definer functions with a dedicated non-superuser role where supported, and keep function bodies narrow, deterministic, and parameterized (zero dynamic SQL string concatenation).
5. **Mandatory Audit Trail:** Sensitive mutations (`role_assigned`, `credit_adjusted`, `manual_checkin_override`, `payment_recorded`, `booking_cancelled_by_staff`) write an immutable row to `audit_logs` within the same transaction.

---

## 4. Secure QR Validation Protocol

Static member ID barcodes are trivially screenshot-shared and spoofed. RITMA uses **short-lived signed rotating tokens**:

1. **Token Issuance:** Member app requests a pass token from `issue_member_qr_token(org_id, member_id)` (or Edge Function using server-side secret stored in Vault/env).
2. **Payload Format:** `v1.<base64url(org_id|member_id|issued_at|expires_at|nonce)>.<hmac_sha256_signature>` with a **60-second TTL** (member app auto-refreshes every 45 seconds).
3. **Server-Side Verification (`validate_and_check_in`):**
   - Verifies scanning staff holds `checkin.perform` on the target `(organization_id, branch_id)`.
   - Recomputes HMAC-SHA256 using constant-time comparison (`pgcrypto` / Vault secret).
   - Rejects expired tokens (`now() > expires_at + 10s clock skew`) with `QR_TOKEN_EXPIRED`.
   - Checks member status (`active`), active `facility_access` entitlement covering `branch_id`, and duplicate check-in cooldown window.
   - Logs outcome to `facility_access_attempts` and inserts `facility_visits` on success.
4. **Manual Check-In Fallback:** Receptionist with `checkin.manual_override` can look up a member by name/code and check them in; the system still checks active `facility_access` entitlement (unless `checkin.force_override` is used by a Manager, which requires a mandatory reason and creates an `audit_logs` alert).

---

## 5. Sensitive Financial & Privacy Protections

- **Member Data Privacy (PII):** Emergency contact info, phone numbers, and visit logs are restricted to authorized staff within the member's organization; instructors viewing a class roster receive only roster-necessary fields (member display name, check-in state, optional medical/safety note if consented) and NEVER billing/payment histories.
- **Financial Operations:** Refunds, voided payments, and manual credit adjustments require explicit elevated permissions (`payment.refund`, `credit.adjust`), mandatory free-text reason, idempotency key, and immutable audit entries.
- **Storage Bucket Policies (Supabase Storage):**
  - `org-public-assets`: Public read for org logos & class cover photos; write restricted to `org.manage` on path prefix `<organization_id>/...`.
  - `member-private-media`: Private bucket (no public URLs); signed short-lived URLs issued only to `authz.is_self_member` or staff with `member.read` on `<organization_id>/...`.
- **Secret Management:**
  - Client apps receive ONLY `SUPABASE_URL` and `SUPABASE_ANON_KEY` via `--dart-define`.
  - `SUPABASE_SERVICE_ROLE_KEY`, QR HMAC secrets, and future payment gateway keys live exclusively in Supabase Vault / Edge Function secrets and are blocked from Git via `.gitignore`.
