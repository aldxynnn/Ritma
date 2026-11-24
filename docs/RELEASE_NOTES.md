# RITMA — Release Notes

## Unreleased (Cycle 1 — In Progress)

### Foundation & GitHub Delivery
- Published initial checkpoint commit `6912f93` to `origin/main` (`https://github.com/aldxynnn/Ritma.git`).
- Added `.gitattributes` for consistent cross-platform line endings.

### Supabase Integration, Local Postgres Verification & Cloud Push
- Updated `supabase/config.toml` (`[local_smtp]` & `[auth.email] enabled = true`) for Supabase CLI v3.3.0 and ignored `node_modules/` in `.gitignore`.
- Started local Docker Supabase (`postgres:17`), executed `npx supabase db reset` (`20261124000100`–`20261124000500` + `seed.sql`), fixed PL/pgSQL `%` literal escaping (`%%`) in `supabase/tests/02_entitlement_and_ledger_integrity.sql`, and verified all 4 SQL test suites (`01`–`04`) passed.
- Verified and pushed all 5 migrations cleanly to Supabase Cloud (`ysgdtyexzmliidpiiarh`, Singapore `ap-southeast-1`) via `npx supabase db push --remote --yes`.
- Hardened `AppEnv` (`SUPABASE_PUBLISHABLE_KEY` fallback + `sb_secret_*` client-build guard), added `scripts/setup_dev_env.ps1`, and added `test/integration/supabase_backend_integration_test.dart` passing live (`1/1`) against local Supabase GoTrue, PostgREST, RLS, and RPCs.
- Re-verified `dart format` (`154 files`), `flutter analyze` (`0 issues`), standard `flutter test` (`28 passed, 1 skipped` offline integration test), Web release (`build/web/index.html`, `1,544` bytes), and Android APK release (`56.3 MB`).

### Personal Training, Payments, Equipment & Notifications — Wave 3 (Phase 5) & Release Builds
- Implemented `personal_training` slice (`PtSessionsView`, `book_pt_session`, `complete_pt_session`) with trainer availability checks, overlap prevention, `pt_credit`-only accounting, and `5-Session PT Pack` catalog support; wired as a toggle inside `OpsScheduleView` and `MemberBookingsView`.
- Implemented `payments` slice (`PaymentsLedgerView`) reading `payment_records` cleanly across branches (for `payment.read` roles inside `OpsMembersView`) and member self-history (via `ProfileScreen` sheet).
- Implemented `operations_extras` slice (`EquipmentOperationsScreen` at `/ops/settings/equipment` for `equipment.manage` roles, plus global `NotificationsBellButton` and `read_at`-guarded `_NotificationsSheet` in both `MemberShell` and `OpsShell`).
- Fixed front-desk override permission check to `checkin.force_override` matching `000100`/`000300` SQL policies.
- Verified with `dart format` (`153 files`), `flutter analyze` (`0 issues`), `28/28` automated tests (`test/features/wave3_modules_test.dart`), plus release builds: `flutter build web --release` (`build/web/index.html`) and `flutter build apk --release` (`56.3 MB`).

### Core Engines & Live Operations — Wave 2 (Phase 5)
- Implemented `facility_access` slice: live rotating QR pass rendering (`qr_flutter` + HMAC-SHA256, `MemberPassView`) with separate Facility vs Class/PT wallet indicators, `FrontDeskCheckInView` supporting QR validation, replay/cooldown/branch denials, manual lookup, mandatory-reason override, and visit checkout.
- Implemented `booking` slice: chronological `MemberScheduleBrowseView`, `MemberBookingsListView` with cutoff-aware refunds, and `OpsScheduleRosterView` supporting session creation/cancellation, FIFO waitlist auto-promotion, and instructor attendance marking (`_SessionRosterSheet`).
- Implemented `dashboard` slice: live `LiveOpsDashboardView` (`7d`/`30d` window) reading strictly computed metrics (`active_members`, `today_visits`, `class_occupancy_pct`, `window_revenue_minor`, `expiring_entitlements_7d`) and recent branch check-ins.
- Verified end-to-end across core domain journeys and responsive dark-theme `1.5x` widget suites (`dart format` `127 files`, `flutter analyze` `0 issues`, `26/26` tests).

### Core Operations Vertical Slices — Wave 1 (Phase 5)
- Added shared non-production `DemoSandboxEngine` mirroring the four separated PostgreSQL domain engines (`Entitlements`, `Facility Access`, `Booking`, `Credit Ledger`).
- Implemented `organizations` slice: `CreateOrganizationSheet`, `OrgBranchManagementScreen` (Branches, Rooms, consent-based Staff Invitations via `invite_user_to_organization`), `SupabaseOrganizationRepository`, and `DemoSandboxOrganizationRepository`.
- Implemented `members` slice: searchable/status-filterable `MembersDirectoryView`, member registration, `set_member_status`, claim-pass invitation, and member detail modal.
- Implemented `packages` slice: `PackagesCatalogView`, `AssignPackageSheet` (idempotent assignment + payment method recording), and `MemberEntitlementsPanel` (strict separation of Facility Access vs Class/PT Credits, subscription freeze/unfreeze extension, and append-only Credit Ledger history).
- Verified with `dart format` (98 files), `flutter analyze` (0 issues), and `23/23` automated tests.

### Auth, Multi-Role Context Switching & Dual Shells (Phase 4)
- Integrated `supabase_flutter` (`SupabaseAuthRepository`, `AuthException` / `PostgrestException` / domain RPC error mapping in `ErrorMapper`, and `BackendSetupScreen` when unconfigured).
- Added explicitly isolated, non-production `DemoSandboxAuthRepository` (`ENABLE_DEMO_MODE=true`) with persistent `DEMO SANDBOX MODE` UI banner.
- Built Direction A (`Editorial Kinetic`) `RitmaStatusColors`, `RitmaDensityScope`, adaptive `RitmaResponsiveScaffold`, `WorkspacePickerScreen` (multi-org/multi-branch/multi-role switcher + invite/claim redemption), and role-isolated `MemberShell` (`/member/*`) vs `OpsShell` (`/ops/*`) navigation.
- Verified with `dart format`, `flutter analyze` (0 issues), and `19/19` unit/widget tests including light/dark themes and `1.5x` text scaling.

### Supabase Backend Foundation (Phase 3)
- Authored PostgreSQL schema migrations (`000100`–`000500`), `supabase/config.toml`, dev `seed.sql`, and SQL security/concurrency suites (`supabase/tests/01`–`04`).
- Hardened against independent Claude Opus 5.5 + Gemini 4 Hydrogen security audit: consent-based org & member claim invitations (`C1`, `H2`), NULL override guard (`H1`), server-derived PT booking pricing/branch/availability (`H3`), atomic `credit_adjustments` idempotency (`H4`), key rotation with 2m grace & single-use QR nonce tracking (`H5`, `M1`), fingerprint-bound check-in idempotency (`M2`), strict branch-scoped RLS & PII-filtered `get_session_roster` (`M4`, `M5`), catalog soft-delete (`M6`), `class_sessions` insert/cancel guards (`M7`), grant freeze extension (`M8`), and `TRUNCATE` immutability (`M10`).
