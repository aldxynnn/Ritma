# RITMA — Product Requirements Document (PRD)

**Product Name:** RITMA  
**Tagline:** One platform. Every fitness business.  
**Document Version:** 1.0 (Discovery Baseline)  
**Target Platforms:** Android (Primary), iOS (Primary), Web (Supporting Operations Surface)

---

## 1. Executive Summary

RITMA is a unified multi-tenant fitness business management platform built to serve both **traditional open-floor gyms** and **boutique class-based studios** (Pilates, Yoga, Cycling, Dance, CrossFit, Functional Fitness, and Personal Training) within a single coherent architecture.

Today, fitness operators are forced to stitch together fragmented software: legacy gym access-control systems that handle class booking poorly, or boutique booking apps that lack multi-branch facility access control, credit accounting, and operational dashboards. RITMA resolves this by separating four foundational operational engines—**Membership & Entitlement Engine**, **Facility Access Engine**, **Booking Engine**, and **Credit Ledger**—under a single multi-organization, multi-branch identity and permission framework.

---

## 2. Target Business Verticals

| Business Type | Primary Operational Model | Key RITMA Engines Used |
|---|---|---|
| **Traditional Gyms** | Recurring time-based memberships, front-desk QR entry, peak-hour load tracking, PT add-ons | Entitlement Engine, Facility Access Engine, Member CRM |
| **Boutique Studios (Pilates, Yoga, Cycling, Dance)** | Scheduled classes, capacity/room limits, class packs/credits, waitlists, no-show rules | Booking Engine, Credit Ledger, Entitlement Engine |
| **CrossFit & Functional Fitness** | Hybrid open-gym access + capped WOD classes + coaching rosters | All four engines (Hybrid packages) |
| **Personal Training Businesses** | 1-on-1 / small-group PT packs, trainer availability, session redemption *(Post-MVP)* | Credit Ledger, PT Scheduling |
| **Multi-Branch Fitness Organizations** | Centralized member identity, branch-specific vs all-access memberships, cross-branch policies, consolidated analytics | Multi-Tenant Org/Branch Scoping, RBAC + Permissions |

---

## 3. User Personas & Multi-Role Context

A single authenticated user (`auth.users`) may hold **different roles across multiple organizations and multiple branches simultaneously** (e.g., a Pilates Instructor at Studio A, a Branch Manager at Studio B, and a Fitness Member at Gym C).

| Persona | Primary Experience Surface | Core Responsibilities |
|---|---|---|
| **Organization Owner** | Operations Experience | Organization setup, branch creation, package catalog, financial/operational KPIs, role governance |
| **Organization Administrator** | Operations Experience | Cross-branch configuration, staff provisioning, policy setup, member & package administration |
| **Branch Manager** | Operations Experience | Branch daily operations, schedules, room/instructor assignment, attendance, branch-level KPIs |
| **Receptionist** | Operations Experience | Fast QR check-in/check-out, member lookup, manual walk-in verification, class check-in |
| **Gym Staff** | Operations Experience | Floor operations, check-in assistance, equipment issue logging *(Post-MVP)* |
| **Fitness Instructor** | Operations Experience (Focused) | Assigned class roster view, live attendance marking, no-show recording |
| **Personal Trainer** | Operations Experience (Focused) | Client list, availability, PT session completion *(Post-MVP)* |
| **Fitness Member** | Member Experience | Digital QR pass, active memberships & credit balances, class discovery, booking/cancellation, visit history |

---

## 4. Domain Requirements

### 4.1 Traditional Gym Management
- **Member Registration & Profiles:** Organization-scoped member directory linked to optional user accounts, emergency contacts, status (`active`, `frozen`, `suspended`, `archived`), and home branch.
- **Membership Packages:** Configurable duration-based plans (monthly, quarterly, annual, day-pass), access scope (single-branch, multi-branch list, all-branch), and optional included class/PT entitlements.
- **Subscription Lifecycle:** `pending` -> `active` -> `frozen` -> `expired` / `cancelled`, with auditable state transitions and freeze/unfreeze date adjustments.
- **QR Member Identification & Check-In:** Time-bound, cryptographically signed short-lived QR tokens validated exclusively on the backend. Supports check-in, optional check-out, and duplicate-scan cooldown protection.
- **Facility Access Eligibility:** Determined strictly by active `facility_access` entitlements matching the scanned branch and current time window—never inferred from raw purchase history or class credits.
- **Visit History & Peak-Hour Utilization:** Immutable visit log per branch enabling hourly occupancy curves and member visit history.
- **Equipment Maintenance *(Post-MVP)*:** Asset inventory, maintenance schedules, and staff fault tickets.

### 4.2 Boutique Studio Management
- **Class Catalog & Templates:** Reusable class definitions (discipline, description, default duration, default capacity, required credit cost, cancellation cutoff window).
- **Recurring Schedules & Materialized Sessions:** Schedule templates generating concrete `class_sessions` instances with explicit `branch_id`, `room_id`, `instructor_id`, `starts_at`, `ends_at`, and `capacity`.
- **Capacity Management & Booking:** Atomic seat reservation backed by PostgreSQL row-level locking (`SELECT ... FOR UPDATE`) to eliminate overbooking under concurrent requests.
- **Cancellation & No-Show Policies:** Configurable cutoff window (e.g., 12 hours prior). Timely cancellations refund consumed class credits via compensating ledger entries; late cancellations or no-shows forfeit credits per policy.
- **Waitlists:** FIFO waitlist queue per session with race-free atomic promotion when a confirmed booking cancels before the cutoff window.
- **Attendance & Occupancy Analytics:** Instructor/staff attendance marking (`booked`, `checked_in`, `no_show`, `cancelled`) and real-time fill-rate reporting per class type, instructor, and time slot.

### 4.3 Personal Training *(Post-MVP)*
- Trainer profiles, specialization tags, and branch availability windows.
- Client-to-trainer assignment and PT package purchases issuing `pt_credit` ledger grants.
- Private session booking, rescheduling, completion confirmation, and training logs.

### 4.4 Multi-Branch Operations
- Strict tenant hierarchy: `Organization` -> `Branch` -> `Room / Schedule / Visit / Staff Assignment`.
- Centralized member profile at the organization level; memberships and entitlements specify exact branch eligibility (`single_branch`, `selected_branches`, `all_branches`).
- Cross-branch access rules evaluated server-side at check-in and booking time.
- Branch-scoped permissions so a Branch Manager at Branch A cannot mutate schedules or view private member records exclusively belonging to Branch B unless explicitly granted org-wide scope.

---

## 5. Critical Invariants & Non-Negotiable Rules

1. **Entitlement Separation:** A gym membership grants facility access only if it produces a `facility_access` entitlement. A class package grants class booking credits only via `credit_ledger` entries. Hybrid packages explicitly grant both—never implicitly.
2. **Backend Authority:** Every access check, booking reservation, credit debit/refund, and role check is enforced in PostgreSQL transactions and RLS policies—never trusted to Flutter client state.
3. **Immutable Accounting:** Credits are tracked via an append-only double-entry-style `credit_ledger` (`grant`, `consume`, `refund`, `expire`, `adjustment`), never by mutable floating counters alone.
4. **Concurrency Safety:** Concurrent bookings, waitlist promotions, QR check-ins, and payment webhooks must be idempotent and serialized on the owning resource lock.
5. **Dual Experience Surfaces:** Member Experience (lifestyle, calm, visual) and Operations Experience (high-density, keyboard/scan-fast, operational) must use distinct navigation shells tailored to the active role context.

---

## 6. Non-Functional Requirements

| Category | Target |
|---|---|
| **Check-In Latency** | QR validation round-trip < 800ms on standard mobile LTE |
| **Data Isolation** | Zero cross-organization data leakage; enforced via PostgreSQL RLS on every tenant table |
| **Reliability** | Zero overbooked sessions and zero double-deducted credits under concurrent load |
| **Accessibility** | WCAG 2.1 AA contrast ratios, full dynamic text scaling (up to 200%), semantic labels |
| **Offline Resilience** | Graceful offline error states in MVP; queued check-in validation evaluated post-MVP |
| **Auditability** | Immutable audit trail for access grants, manual overrides, credit adjustments, and role changes |
