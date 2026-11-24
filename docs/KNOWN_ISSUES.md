# RITMA — Known Issues & Environment Blockers

**Last Updated:** 2026-11-24

---

## Active External / Environment Blockers

1. **Docker Desktop Manually Paused & Supabase CLI Not Installed Globally**
   - **Symptom:** Running `docker info` returns `Docker Desktop is manually paused. Unpause it through the Whale menu or Dashboard.`, and `supabase` CLI is not on `PATH`.
   - **Impact:** Cannot spin up local Supabase PostgreSQL/Auth containers (`supabase start` / `supabase db reset`) or execute SQL tests in `supabase/tests/*.sql` against a live Supabase stack yet.
   - **Mitigation:** All SQL migrations, RLS policies, RPC engines, and SQL assertion suites are written cleanly under `supabase/` and audited by an independent security reviewer (`claude-opus-5-5-high`). Flutter auth/shell layers support real Supabase via `--dart-define-from-file=env/dev.json` plus an explicitly badged `ENABLE_DEMO_MODE=true` non-production sandbox.

2. **No Live Supabase Project Credentials (`env/dev.json`) Configured**
   - **Symptom:** Workspace contains tracked template `env/dev.example.json` only; git-ignored `env/dev.json` has not been populated with a Supabase URL and anon key.
   - **Impact:** Live Supabase email/password sign-in and RPC calls cannot be exercised end-to-end against a remote project until dev credentials or unpaused local Docker Supabase are provided.

3. **iOS Release Build Requires macOS / Xcode**
   - **Symptom:** Active development host runs Windows 11.
   - **Impact:** `flutter build web --release` (`build/web/index.html`) and `flutter build apk --release` (`app-release.apk`, `56.3 MB`) compiled cleanly on Windows, whereas iOS `.ipa` building/signing must run on macOS. `ios/Runner.xcodeproj/project.pbxproj` is verified with `PRODUCT_BUNDLE_IDENTIFIER = com.ritma.ritma` and `IPHONEOS_DEPLOYMENT_TARGET = 15.0`.

---

## Tooling Notes (Windows Host)

- **PowerShell `flutter` shim stall:** Invoking bare `flutter --version` without `.bat` and `--suppress-analytics` can stall in non-interactive subshells. Always invoke `& "C:\src\flutter\bin\flutter.bat" <args> --suppress-analytics` and `& "C:\src\flutter\bin\dart.bat" <args>`.
- **`psql` password prompt:** Always pass `-w` (`--no-password`) when scripting `psql` checks so non-interactive sessions never hang waiting for interactive password input.
