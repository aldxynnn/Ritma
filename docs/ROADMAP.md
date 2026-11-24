# RITMA — Implementation Roadmap

Every milestone follows a strict vertical-slice cycle: **Spec Review -> Schema & RLS Migration -> Domain/Infrastructure -> UI (Member &/or Ops) -> Automated Tests -> Verification & Git Checkpoint**.

---

## Phase 1: Unified MVP (Traditional Gym + Boutique Studio Core)

### Milestone 1 — Foundation & Product Architecture *(Current — Completed)*
- **Scope:** Workspace bootstrap, feature-first Flutter architecture, Riverpod/GoRouter/Freezed/Logging/Theme foundation, local Git setup, full product/domain/architecture/security/UX documentation.
- **Exit Criteria:** `flutter pub get`, `build_runner`, `dart format`, `flutter analyze`, and `flutter test` all pass cleanly.

### Milestone 2 — Supabase Backend Foundation, Auth & Multi-Role Context
- **Scope:** Initialize `supabase/` migrations for `organizations`, `branches`, `rooms`, `user_profiles`, `roles`, `permissions`, `role_permissions`, `user_role_assignments`, `audit_logs`, and `authz.has_permission()`. Add `supabase_flutter`, Auth screens, and Org/Branch Context Switcher routing into distinct `/member/*` and `/ops/*` shells.
- **Exit Criteria:** Multi-role user switches cleanly between Member and Operations surfaces; RLS isolation tests pass.

### Milestone 3 — Organization, Branch, Staff & Member Management
- **Scope:** `create_organization_with_owner` RPC, Branch & Room CRUD, Staff role invitations/assignments with privilege-escalation guards, Organization-scoped Member Directory & profiles.
- **Exit Criteria:** Owner provisions 2+ branches and rooms, assigns branch-scoped staff, and registers members; branch isolation tests pass.

### Milestone 4 — Package Catalog, Entitlements & Credit Ledger Engine
- **Scope:** Packages (`gym_membership`, `class_pack`, `hybrid`), `package_entitlement_rules`, `assign_package_to_member` RPC with manual payment recording, `member_subscriptions`, `member_entitlements`, `credit_grants`, and append-only `credit_ledger_entries`.
- **Exit Criteria:** Assigning gym vs class vs hybrid packages creates strictly separated entitlements/credits; idempotency and negative-balance protection verified by tests.

### Milestone 5 — Gym QR Facility Access Engine
- **Scope:** Rotating signed QR pass (`issue_member_qr_token`), front-desk scanner (`mobile_scanner` + `qr_flutter`), `validate_and_check_in` RPC, cooldown double-scan prevention, visit history, and denied-attempt audit logs.
- **Exit Criteria:** End-to-end QR check-in < 800ms; gym-only vs class-only vs cross-branch rules enforced server-side.

### Milestone 6 — Studio Class Schedules, Booking, Capacity, Waitlist & Attendance
- **Scope:** Class types/templates, materialized `class_sessions`, atomic `book_class_session` & `cancel_class_booking` RPCs with `FOR UPDATE` locking, FIFO waitlist promotion, cancellation cutoff credit refund rules, and Instructor/Staff live attendance roster.
- **Exit Criteria:** Zero overbookings under concurrent seat contention; timely cancellation refunds credit; attendance updates roster live.

### Milestone 7 — Owner & Branch Manager Operational Dashboard + MVP Hardening
- **Scope:** Live database-backed KPI dashboard (active members, today's gym visits, peak-hour distribution, class occupancy rates, expiring entitlements), responsive web/tablet ops polish, end-to-end integration tests, and security audit.
- **Exit Criteria:** Zero fabricated metrics; all 12 MVP acceptance criteria verified.

---

## Phase 2: Commercial Growth & Personal Training
- Personal Training module (trainer profiles, availability, 1-on-1 booking, `pt_credit` consumption).
- Payment gateway integration (Stripe / Midtrans / Xendit) via idempotent Supabase Edge Function webhooks.
- Firebase Cloud Messaging (FCM) push notifications (waitlist promotion alerts, class reminders, membership expiry reminders).
- Recurring class schedule generator & member self-service package checkout.

## Phase 3: Enterprise Operations & Offline Resilience
- Equipment inventory & preventive maintenance ticketing.
- Advanced finance: tax invoices, instructor payroll/class-count payout reports, multi-branch consolidated P&L exports.
- Selective offline resilience (Drift/SQLite) for front-desk check-in continuity if validated by operator demand.

## Phase 4: Intelligence & Retention
- Data-driven churn-risk indicators, class demand forecasting, and dynamic waitlist insights grounded exclusively in verified historical visit/booking telemetry.
