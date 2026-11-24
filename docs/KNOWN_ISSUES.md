# RITMA — Known Issues & Environment Blockers

**Last Updated:** 2026-11-24

---

## Active External / Environment Items

1. **Dev/Demo Auth Email Confirmation Temporarily Disabled on Cloud (`ysgdtyexzmliidpiiarh`)**
   - **Symptom:** `supabase/config.toml` sets `[auth.email] enable_confirmations = false` (pushed to Cloud `ysgdtyexzmliidpiiarh`) so newly registered dev/demo accounts receive an immediate session without inbox verification.
   - **Action Before Production:** Must be restored to `enable_confirmations = true` (with a verified custom SMTP provider) via `npx supabase config push --remote` prior to staging/production release.

2. **Per-Developer `env/dev.json` Remains Git-Ignored**
   - **Symptom:** Credentials (`SUPABASE_URL` + Publishable Key `sb_publishable_...`) live only in local git-ignored `env/dev.json` (generated via `.\scripts\setup_dev_env.ps1` from `env/dev.example.json`) and are never committed to Git.
   - **Impact:** Fresh clones must populate `env/dev.json` before running `--dart-define-from-file=env/dev.json` against Cloud (`ysgdtyexzmliidpiiarh`) or local Docker (`http://127.0.0.1:54321`).

3. **Automatic Notification Outbox Population Not Yet Wired to RPC Triggers**
   - **Symptom:** `public.user_notifications` table, RLS policies (`user_notifications_select_own`, `user_notifications_update_own`), column guard trigger (`trg_user_notifications_guard`), and Flutter UI (`NotificationsBellButton`, `_NotificationsSheet`, `markNotificationRead`) are implemented and query real PostgREST cleanly, returning an empty list until notification rows are inserted server-side (e.g., via scheduled workers, Edge Functions, or future RPC hooks).
   - **Impact:** Functional RLS/SELECT verified live against Cloud (`HTTP 200`); notification badge shows `0` for new accounts unless rows exist in `user_notifications`.

4. **iOS Release Build Requires macOS / Xcode**
   - **Symptom:** Active development host runs Windows 11.
   - **Impact:** `flutter build web --release` (`build/web/index.html`, `1,544` bytes) and `flutter build apk --release` (`app-release.apk`, `56.3 MB` verified earlier) compiled cleanly on Windows, whereas iOS `.ipa` building/signing must run on macOS. `ios/Runner.xcodeproj/project.pbxproj` is verified with `PRODUCT_BUNDLE_IDENTIFIER = com.ritma.ritma` and `IPHONEOS_DEPLOYMENT_TARGET = 15.0`.

---

## Tooling Notes (Windows Host & Supabase CLI v3.3.0)

- **Supabase CLI v3.3.0 `--remote` Target Behavior:** When a local Supabase Docker stack is running, `npx supabase migration list` and `npx supabase db push --dry-run` target the local stack by default; pass `--remote` explicitly to inspect or push to linked Cloud (`ysgdtyexzmliidpiiarh`).
- **Docker Local Services (`supabase_imgproxy_ritma`, `supabase_pooler_ritma`):** `npx supabase status` notes those two optional containers stopped cleanly under the active config without impacting Auth, REST, Postgres 17 (`54322`), Mailpit (`54324`), or Studio (`54323`).
- **PowerShell `flutter` shim stall:** Invoking bare `flutter --version` without `.bat` and `--suppress-analytics` can stall in non-interactive subshells. Always invoke `& "C:\src\flutter\bin\flutter.bat" <args> --suppress-analytics` and `& "C:\src\flutter\bin\dart.bat" <args>`.
- **`psql` password prompt:** Always pass `-w` (`--no-password`) when scripting `psql` checks so non-interactive sessions never hang waiting for interactive password input.
