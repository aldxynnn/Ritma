# RITMA — Release Notes

## Unreleased (Demo-Ready Release Overhaul)

### Vercel Primary Web Hosting Migration (`963745b`)
- Migrated primary Flutter Web hosting to **Vercel** (`https://ritma-pi.vercel.app`) from `main` using root base path `/` and clean HTML5 path URLs (`flutter_web_plugins`, `lib/app/url_strategy_web.dart`, `lib/app/url_strategy_stub.dart`, `configureAppUrlStrategy()` in `lib/app/bootstrap.dart`).
- Added `vercel.json` (root SPA fallback rewrites, asset cache headers, build wiring), executable `scripts/vercel_build.sh` (installs Flutter `3.47.4`, validates public `SUPABASE_URL`/`SUPABASE_ANON_KEY` and blocks `sb_secret_*`/`service_role`), and `.vercelignore` (excludes `env/`, `android/`, `ios/`, `supabase/`, and build caches); configured public Supabase environment variables directly in Vercel project `ritma` with `ssoProtection.deploymentType = "preview"`.
- Verified live production site `https://ritma-pi.vercel.app` across all 5 demo accounts (`demo.owner@ritma.app`, `demo.manager@ritma.app`, `demo.member@ritma.app`, `demo.trainer1@ritma.app`, `demo.trainer2@ritma.app`), Check-In/Check-Out, Schedule Roster, Member Entitlements, Branch Manager Senopati scoping + `page.reload()`, Member `Rotate QR` + Book/`page.reload()`/Cancel Refund (`+1` credit) + `/ops/dashboard` route isolation guard, Personal Trainers 1 & 2, `<base href="/">`, clean path routing, and Supabase Cloud connectivity (`0` console errors, `0` HTTP `404` responses, with `1` server-enforced HTTP `403` RPC during unauthorized Member `/ops/dashboard` deep-link transition before redirect to `/member/home`).
- Switched GitHub Pages `build_type` to `workflow` (`gh api -X PUT repos/aldxynnn/Ritma/pages -f build_type=workflow`) without deleting any repository, branch, or commit; GitHub REST API returned HTTP `422` (`Deactivating GitHub pages for this repository is not allowed`) on `DELETE /pages`, leaving only the manual **Settings -> Pages -> Unpublish site** click to tear down the legacy snapshot cleanly.
- Verified `build/app/outputs/flutter-apk/app-release.apk` (`56.55 MB`) remains byte-for-byte identical.

### Editorial Kinetic UI Overhaul, Cloud Showcase (`RITMA Atelier & Athletic`), Web & Android Releases
- Added migration `supabase/migrations/20261124000700_trainer_display_name_and_notification_hooks.sql` introducing non-PII `trainer_profiles.display_name` plus `SECURITY DEFINER` triggers `private.notify_on_subscription_created()` and `private.notify_on_booking_change()` for automatic member notifications; verified locally (`npx supabase db reset` + `4/4` Postgres 17 SQL tests) and pushed to Cloud (`ysgdtyexzmliidpiiarh`).
- Resolved raw UUID labels across Cloud views via embedded PostgREST joins (`members(full_name)`, `trainer_profiles(display_name)`) in `supabase_facility_access_repository.dart`, `supabase_payment_repository.dart`, and `supabase_pt_repository.dart`, and real package names in `MemberEntitlementsPanel`.
- Implemented persistent Dark/Light theme switching (`ThemeModeNotifier`, Dark default, header `ThemeModeToggleButton`, Profile appearance card), responsive `RitmaPageContainer` / `RitmaMetricTile` / `RitmaResponsiveScaffold` (compact icon rail below `960dp`), Editorial Digital Pass Card, split Sign-In showcase hero (`!env.isProduction`-guarded), non-overflowing Front-Desk lookup & visit rows, and `StatefulWidget` dialog lifecycle refactoring with inline validation and SnackBar feedback across all CRUD forms.
- Fixed missing `<uses-permission android:name="android.permission.INTERNET"/>` in `android/app/src/main/AndroidManifest.xml` (required for release APK network requests) and branded `web/index.html` & `web/manifest.json`.
- Created idempotent additive Cloud seeder [`scripts/seed_cloud_demo.mjs`](../scripts/seed_cloud_demo.mjs) populating `RITMA Atelier & Athletic` (`SCBD Flagship Gym` & `Senopati Boutique Studio`) and authored [`docs/DEMO_GUIDE.md`](./DEMO_GUIDE.md).
- Verified cleanly across `dart format` (`158` files), `flutter analyze` (`0` issues), `flutter test` (`42` passed, `1` opt-in offline integration skipped), live Cloud E2E + narrow Check-In re-verification (`0` console errors, `0` HTTP `>= 400`), `flutter build web --release --dart-define-from-file=env/dev.json` (`build/web`), and `flutter build apk --release --dart-define-from-file=env/dev.json` (`build/app/outputs/flutter-apk/app-release.apk`, `56.55 MB`).

### Schedule New Session Publish Fix (`8ca04c9`)
- Resolved silent Publish Session no-op by auto-provisioning/resolving required room & class type prerequisites and surfacing inline validation/error feedback (`publish_session_dialog_test.dart`).

### Cloud Web Auth Fix, Least-Privilege Grants & Live Cloud E2E Verification (`1cfd6c8`)
- Added forward-only migration `supabase/migrations/20261124000600_grant_authenticated_table_privileges.sql` granting explicit least-privilege `SELECT` / `INSERT` / `UPDATE` / `DELETE` table rights to `authenticated` (with zero `anon` privileges) across all 38 `public.*` tables so Cloud PostgREST matches local Docker behavior (`HTTP 403` resolved on `user_profiles` and `public.*` tables); verified locally (`npx supabase db reset` + `4/4` SQL tests) and pushed to Cloud (`ysgdtyexzmliidpiiarh`).
- Removed mismatched `runZonedGuarded` wrapper around `runApp(...)` in `lib/app/bootstrap.dart` to eliminate Flutter Web `Zone mismatch` initialization assertions.
- Fixed `AuthController` (`auth_providers.dart`) concurrent session-load deduplication (`_pendingLoad`), error propagation (`_loadAuthenticatedSession` returns `Result<void>`), unauthenticated state ordering on sign-out, `SupabaseAuthRepository.signInWithEmail` non-null session guard, and `ErrorMapper` (`email not confirmed`, `invalid login credentials`, and `permission denied` -> `ForbiddenFailure`).
- Gated `userNotificationsProvider` on `AuthenticatedSession` + active workspace and made `unreadNotificationCountProvider` auto-disposable to eliminate transient `HTTP 401` queries during sign-out/sign-in transitions.
- Updated `SignInScreen`, `SignUpScreen`, `ForgotPasswordScreen`, and `WorkspacePickerScreen` for clean Web URL reflection (`context.go`), Enter-key submit, fallback navigation guards, and calm confirmation-notice styling.
- Temporarily set `[auth.email] enable_confirmations = false` in `supabase/config.toml` and pushed to Cloud dev/demo project (`ysgdtyexzmliidpiiarh`) for unblocked demo registration (explicitly flagged to revert to `true` before production launch).
- Verified live Web E2E against Supabase Cloud (`Sign Up` -> `Select Workspace` -> `Create Organization` -> `Operations Console` -> `Reload` persistence -> `Sign Out` -> `Sign In` -> `Operations Console`) with `0` console errors and `0` HTTP `>= 400` responses, plus `dart format` (`154` files), `flutter analyze` (`0` issues), `flutter test` (`32 passed, 1 skipped` offline integration test), and `flutter build web --release` (`build/web/index.html`, `1,544` bytes).

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
