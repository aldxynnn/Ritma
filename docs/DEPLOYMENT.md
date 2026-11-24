# RITMA — Environment, CI/CD & Deployment Strategy

## 1. Environment Topology

RITMA maintains three strictly isolated environments so development or testing never touches live member records or payment ledgers:

| Environment | `APP_ENV` | Supabase Project | Purpose |
|---|---|---|---|
| **Development** | `dev` | Local Supabase CLI (`supabase start`) or `ritma-dev` | Active feature development, migration authoring, automated tests |
| **Staging** | `staging` | `ritma-staging` | Pre-release QA, real-device Android/iOS testing, UAT with pilot studios |
| **Production** | `prod` | `ritma-prod` | Live customer organizations and members |

---

## 2. Configuration & Secret Handling

- **Client Configuration:** Injected at build time via `--dart-define-from-file=env/<env>.json` (using `env/dev.example.json` as the tracked template).
- **Never Committed:** `env/*.json` (except `*.example.json`), `.env*` (except `.env.example`), Android keystores (`*.jks`, `key.properties`), Firebase config files, and Supabase service keys are excluded by `.gitignore`.
- **Production Safety Guards in Code:** `AppEnv.fromDartDefines()` forcibly disables `enableDebugLogging` and `enableDemoMode` whenever `APP_ENV=prod`.

---

## 3. Continuous Integration (GitHub Actions Blueprint)

Once Milestone 2 activates remote CI on `main` and pull requests, `.github/workflows/ci.yml` will enforce:

1. **Flutter Verification Job:**
   - `flutter pub get`
   - `dart format --output=none --set-exit-if-changed .`
   - `flutter analyze --fatal-infos` (or `--fatal-warnings`)
   - `flutter test --coverage`
2. **Codegen Drift Check:**
   - Verify generated `*.freezed.dart` / `*.g.dart` files match source definitions.
3. **Database & RLS Job (Milestone 2+):**
   - Spin up local Supabase PostgreSQL via Supabase CLI.
   - Apply all SQL migrations cleanly from scratch (`supabase db reset`).
   - Run RLS isolation and concurrency SQL tests.

---

## 4. Release & Migration Discipline

### Database Migrations & Auth Configuration
- All schema changes, table grants, RLS policies, indexes, and RPC functions are versioned as sequential SQL files under `supabase/migrations/`.
- Managed Supabase Cloud requires explicit `GRANT SELECT/INSERT/UPDATE/DELETE ... TO authenticated` statements alongside RLS policies (enforced via `20261124000600_grant_authenticated_table_privileges.sql`).
- **Production Auth Pre-Launch Requirement:** `supabase/config.toml` sets `[auth.email] enable_confirmations = false` strictly for temporary dev/demo onboarding testing (`ysgdtyexzmliidpiiarh`). Before production launch or staging sign-off, set `enable_confirmations = true`, push config via `npx supabase config push --remote`, and configure a production SMTP provider.
- **Never** edit production schema manually through the Supabase Dashboard SQL editor without an accompanying versioned migration.
- Prefer backward-compatible (expand-and-contract) migrations so existing mobile app versions do not crash during rollouts.

### Mobile & Web Releases
- **Android:** Signed App Bundle (`flutter build appbundle --release --dart-define-from-file=env/prod.json`) distributed via Google Play Internal -> Closed -> Production tracks.
- **iOS:** Signed IPA (`flutter build ipa --release --dart-define-from-file=env/prod.json`) distributed via TestFlight -> App Store.
- **Web (Operations Supporting Surface):** Static build (`flutter build web --release --dart-define-from-file=env/prod.json`) deployed behind HTTPS with strict CSP headers.
