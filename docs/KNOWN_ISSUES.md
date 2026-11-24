# RITMA — Known Issues & Environment Blockers

**Last Updated:** 2026-11-24

---

## Active External / Environment Items

1. **Cloud Client Credentials (`env/dev.json`) Pending Local Input**
   - **Symptom:** Workspace contains tracked template `env/dev.example.json` and safe setup script `scripts/setup_dev_env.ps1`; git-ignored `env/dev.json` is not populated in the repo.
   - **Impact:** Local Supabase (`http://127.0.0.1:54321`) end-to-end Flutter integration is verified (`1/1 passed`), and all 5 migrations are deployed on Cloud (`ysgdtyexzmliidpiiarh`). Executing the Flutter app or `test/integration/supabase_backend_integration_test.dart` directly against Cloud requires the user to run `.\scripts\setup_dev_env.ps1` with their Project URL and Publishable Key (`sb_publishable_...`).

2. **Automatic Notification Outbox Population Not Yet Wired to RPC Triggers**
   - **Symptom:** `public.user_notifications` table, RLS policies (`user_notifications_select_own`, `user_notifications_update_own`), column guard trigger (`trg_user_notifications_guard`), and Flutter UI (`NotificationsBellButton`, `_NotificationsSheet`, `markNotificationRead`) are implemented and query real PostgREST cleanly, returning an empty list until notification rows are inserted server-side (e.g., via scheduled workers, Edge Functions, or future RPC hooks).
   - **Impact:** Functional RLS/SELECT verified live; notification badge shows `0` for new accounts unless rows exist in `user_notifications`.

3. **iOS Release Build Requires macOS / Xcode**
   - **Symptom:** Active development host runs Windows 11.
   - **Impact:** `flutter build web --release` (`build/web/index.html`) and `flutter build apk --release` (`app-release.apk`, `56.3 MB`) compiled cleanly on Windows, whereas iOS `.ipa` building/signing must run on macOS. `ios/Runner.xcodeproj/project.pbxproj` is verified with `PRODUCT_BUNDLE_IDENTIFIER = com.ritma.ritma` and `IPHONEOS_DEPLOYMENT_TARGET = 15.0`.

---

## Tooling Notes (Windows Host & Supabase CLI v3.3.0)

- **Supabase CLI v3.3.0 `--remote` Target Behavior:** When a local Supabase Docker stack is running, `npx supabase migration list` and `npx supabase db push --dry-run` target the local stack by default; pass `--remote` explicitly to inspect or push to linked Cloud (`ysgdtyexzmliidpiiarh`).
- **Docker Local Services (`supabase_imgproxy_ritma`, `supabase_pooler_ritma`):** `npx supabase status` notes those two optional containers stopped cleanly under the active config without impacting Auth, REST, Postgres 17 (`54322`), Mailpit (`54324`), or Studio (`54323`).
- **PowerShell `flutter` shim stall:** Invoking bare `flutter --version` without `.bat` and `--suppress-analytics` can stall in non-interactive subshells. Always invoke `& "C:\src\flutter\bin\flutter.bat" <args> --suppress-analytics` and `& "C:\src\flutter\bin\dart.bat" <args>`.
- **`psql` password prompt:** Always pass `-w` (`--no-password`) when scripting `psql` checks so non-interactive sessions never hang waiting for interactive password input.
