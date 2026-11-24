# RITMA — Multi-Tenant Roles & Permissions Specification

## 1. Multi-Role, Multi-Scope Authorization Model

RITMA explicitly rejects a flat `users.role` model. Authorization is modeled through **Role Assignments scoped to Organization and Branch**, resolved into **granular permission codes**:

```text
User (auth.users)
  └── UserRoleAssignment (user_id, organization_id, branch_id?, role_id, status)
        └── Role (org_owner | org_admin | branch_manager | receptionist | gym_staff | instructor | personal_trainer | member)
              └── Permission (domain.action)
```

### Scope Semantics
- **Organization-Wide Scope (`branch_id IS NULL`):** Applies across all current and future branches of `organization_id` (e.g., `org_owner`, `org_admin`).
- **Branch-Specific Scope (`branch_id = <uuid>`):** Applies strictly to operations targeting that specific branch (e.g., `branch_manager`, `receptionist`, `gym_staff`, `instructor`).
- **Member Scope:** Derived from an active `members` link (`members.user_id = auth.uid()`) within `organization_id`, granting self-service actions only on the member's own records.
- **Multiple Simultaneous Assignments:** A single user can be `instructor` at Branch A, `branch_manager` at Branch B, and `member` in Organization Y. The UI lets them pick their active workspace context, while the backend evaluates permissions independently per `(organization_id, branch_id)` on every request.

---

## 2. Granular Permission Catalog

| Domain | Permission Code | Description |
|---|---|---|
| **Organization** | `org.manage` | Edit org profile, timezone, currency, policies |
| | `branch.manage` | Create/update branches and rooms |
| | `role.assign` | Invite staff and assign/revoke roles (cannot escalate above own privilege) |
| | `audit.read` | Inspect immutable audit logs |
| **Members** | `member.read` | View member profiles & status within scope |
| | `member.write` | Register/edit members, freeze/unfreeze profiles |
| **Catalog & Entitlements** | `package.manage` | Create/update/archive gym, class, and hybrid packages |
| | `entitlement.read` | View member subscriptions, entitlements, and credit balances |
| | `entitlement.assign` | Assign packages / activate / freeze subscriptions |
| | `credit.adjust` | Post manual `+`/`-` credit adjustments (requires reason + audit log) |
| **Payments** | `payment.read` | View payment records and revenue summaries |
| | `payment.record` | Record manual/front-desk payments |
| | `payment.refund` | Void or refund payment records |
| **Facility Access** | `checkin.perform` | Scan QR passes and check members in/out |
| | `checkin.read` | View branch visit logs and live occupancy |
| | `checkin.force_override` | Override ineligible check-in with mandatory audit reason |
| **Classes & Booking** | `schedule.manage` | Create/edit class templates and materialized sessions |
| | `booking.read` | View class rosters and waitlist queues |
| | `booking.manage` | Book/cancel/move members on classes |
| | `attendance.mark` | Mark `checked_in` or `no_show` on class rosters |
| **Dashboard** | `dashboard.org.read` | View organization-wide operational KPIs |
| | `dashboard.branch.read` | View branch-scoped operational KPIs |
| **Personal Training** *(Post-MVP)* | `pt.manage` | Manage trainer availability & PT session schedules |

---

## 3. Role-to-Permission Matrix

Legend: **Org** = Org-wide scope | **Branch** = Assigned branch(es) only | **Assigned** = Assigned sessions/clients only | **Self** = Own records only | `—` = Denied

| Permission | Org Owner | Org Admin | Branch Manager | Receptionist | Gym Staff | Instructor | Personal Trainer | Member |
|---|---|---|---|---|---|---|---|---|
| `org.manage` | Org | — | — | — | — | — | — | — |
| `branch.manage` | Org | Org | — | — | — | — | — | — |
| `role.assign` | Org | Org (non-owner) | Branch (staff/instr) | — | — | — | — | — |
| `audit.read` | Org | Org | Branch | — | — | — | — | — |
| `member.read` | Org | Org | Branch | Branch | Branch (basic) | Assigned roster | Assigned clients | Self |
| `member.write` | Org | Org | Branch | Branch (create/edit) | — | — | — | Self (contact only) |
| `package.manage` | Org | Org | — | — | — | — | — | — |
| `entitlement.read` | Org | Org | Branch | Branch | — | — | Assigned clients | Self |
| `entitlement.assign` | Org | Org | Branch | Branch | — | — | — | — |
| `credit.adjust` | Org | Org | Branch (capped) | — | — | — | — | — |
| `payment.read` | Org | Org | Branch | Branch | — | — | — | Self |
| `payment.record` | Org | Org | Branch | Branch | — | — | — | — |
| `payment.refund` | Org | Org | — | — | — | — | — | — |
| `checkin.perform` | Org | Org | Branch | Branch | Branch | — | — | — |
| `checkin.read` | Org | Org | Branch | Branch | Branch | — | — | Self |
| `checkin.force_override` | Org | Org | Branch | — | — | — | — | — |
| `schedule.manage` | Org | Org | Branch | — | — | — | — | — |
| `booking.read` | Org | Org | Branch | Branch | — | Assigned (via `get_session_roster` RPC) | — | Self |
| `booking.manage` | Org | Org | Branch | Branch | — | — | — | Self (book/cancel) |
| `attendance.mark` | Org | Org | Branch | Branch | — | Assigned | — | — |
| `dashboard.org.read` | Org | Org | — | — | — | — | — | — |
| `dashboard.branch.read` | Org | Org | Branch | — | — | — | — | — |

---

## 4. Cross-Branch Policy Evaluation

1. **Member Cross-Branch Access:**
   - Member identity (`members`) is organization-wide so a member never needs duplicate accounts across branches.
   - Operational access is governed per entitlement/grant via normalized join tables (`member_entitlement_branches`, `credit_grant_branches`):
     - `single_branch`: valid only when `target_branch_id` matches the assigned row in `*_branches`.
     - `selected_branches`: valid when `EXISTS (SELECT 1 FROM *_branches b WHERE b.branch_id = target_branch_id)`.
     - `all_branches`: valid for any active branch belonging to `organization_id`.
2. **Staff Cross-Branch Visibility & Consent-Based Onboarding (C1, H2, M4, M5):**
   - Raw `members`, `member_subscriptions`, `member_entitlements`, `credit_grants`, and `credit_ledger_entries` queries are branch-scoped to the member's `home_branch_id` (or `assigned_branch_id`).
   - Receptionists/staff performing cross-branch check-in at Branch A for a member whose home branch is Branch B use `lookup_member_for_checkin` / `validate_and_check_in` RPCs, returning minimal check-in identity without exposing full org-wide PII or Branch B financials.
   - Instructors access class rosters exclusively via `get_session_roster` RPC (exposing display name, member code, and attendance state only—no emails, phones, or billing info).
   - Linking external user accounts as staff or claiming member profiles requires consent-based token acceptance (`invite_user_to_organization` -> `accept_organization_invitation`, `invite_member_claim` -> `claim_member_profile`); staff cannot directly overwrite `members.user_id` or `members.status`.
3. **Privilege Escalation Prevention & Role Rank (F8):**
   - `roles.rank` defines strict hierarchy: `org_owner (100) > org_admin (80) > branch_manager (60) > receptionist (40) > gym_staff / instructor / personal_trainer (30) > member (10)`.
   - `invite_user_to_organization`, `assign_user_role`, and `revoke_user_role` (`SECURITY DEFINER`) verify:
     - Caller has `role.assign` in scope (`NULL` branch for org-wide, matching `branch_id` for branch-scoped).
     - `branch_manager` cannot assign org-wide roles (`branch_id IS NULL`) or roles on other branches, and manual `credit.adjust` is capped at 20 credits for ranks `< 80`.
     - Caller cannot assign/invite/revoke any role with `rank >= caller_max_rank` unless caller is `org_owner` (rank 100), cannot pull external users into an org without invitation acceptance, and cannot revoke the last active `org_owner` (`LAST_ORG_OWNER`).
