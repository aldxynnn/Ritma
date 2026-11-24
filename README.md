# RITMA

**One platform. Every fitness business.**

RITMA is a unified, multi-tenant fitness business management platform built with **Flutter**, **Dart**, and **Supabase (PostgreSQL + RLS)** supporting traditional gyms, boutique fitness studios (Pilates, Yoga, Cycling, Dance), CrossFit/functional facilities, personal training businesses, and multi-branch fitness organizations.

---

## Core Architectural Pillars

1. **Four Separated Operational Engines:**
   - **Membership & Entitlement Engine** — Commercial packages, subscription lifecycles, and explicit access rights.
   - **Facility Access Engine** — Short-lived signed rotating QR passes, branch eligibility checks, double-scan cooldowns, and visit logs.
   - **Booking Engine** — Class templates, materialized sessions, atomic capacity locking (`FOR UPDATE`), FIFO waitlists, and attendance rosters.
   - **Credit Ledger** — Append-only accounting for class credits and PT session credits (`grant`, `consume`, `refund`, `expire`, `adjustment`).
2. **Multi-Organization, Multi-Branch RBAC:** One user can hold distinct roles across multiple organizations and branches, enforced server-side via PostgreSQL Row Level Security (RLS) and hardened transactional RPCs.
3. **Dual UX Surfaces:** A calm, lifestyle-oriented **Member Experience** (`/member/*`) and an information-dense, scan-fast **Operations Experience** (`/ops/*`) sharing one accessible Material 3 design system.

---

## Project Structure

```text
RITMA/
├── docs/                           # Product, Domain, Architecture, DB, Security & UX specs
│   ├── PRD.md
│   ├── PRODUCT_SCOPE.md
│   ├── USER_FLOWS.md
│   ├── DOMAIN_MODEL.md
│   ├── ARCHITECTURE.md
│   ├── DATABASE.md
│   ├── ERD.md
│   ├── SECURITY.md
│   ├── PERMISSIONS.md
│   ├── DESIGN_SYSTEM.md
│   ├── TEST_STRATEGY.md
│   ├── ROADMAP.md
│   ├── DEPLOYMENT.md
│   └── ADR/
│       └── 0001-initial-architecture.md
├── env/
│   └── dev.example.json            # Compile-time environment template (--dart-define-from-file)
├── lib/
│   ├── main.dart
│   ├── app/                        # Composition root, bootstrap, reactive role-aware GoRouter
│   ├── core/                       # Config, network, errors (Freezed), logging, result, base repository, Direction A theme, shared widgets
│   └── features/
│       ├── auth/                   # Sign-in/up/recovery, profile, multi-role workspace switcher, invite/claim redemption
│       ├── shells/                 # Role-isolated MemberShell (/member/*) and OpsShell (/ops/*)
│       └── foundation/             # Initial bootstrap landing reference
├── supabase/
│   ├── config.toml                 # Supabase CLI config (private & authz excluded from API)
│   ├── migrations/                 # Sequential PostgreSQL migrations (000100..000500)
│   ├── seed.sql                    # Non-production local development seed
│   └── tests/                      # RLS isolation, ledger immutability, concurrency & QR tests
└── test/                           # Unit and widget tests
```

---

## Local Setup & Commands

### Prerequisites
- Flutter 3.47+ (Dart 3.13+)
- Android SDK / Xcode (for mobile targets) or Chrome (for Web)

### Environment Configuration
Copy [env/dev.example.json](env/dev.example.json) to `env/dev.json` (git-ignored) and supply local or remote Supabase values:

```bash
flutter pub get
dart run build_runner build
flutter run --dart-define-from-file=env/dev.json
```

To preview the UI locally without live Supabase credentials (non-production builds only, clearly marked with a Demo Sandbox banner):

```bash
flutter run --dart-define=ENABLE_DEMO_MODE=true
```

> **Security Note:** Never place `SUPABASE_SERVICE_ROLE_KEY` or private signing keys in `env/*.json` or commit `.env` files.

### Quality Verification Commands

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

---

## Documentation Index

| Document | Purpose |
|---|---|
| [PRD.md](docs/PRD.md) | Vision, verticals, personas, domain & non-functional requirements |
| [PRODUCT_SCOPE.md](docs/PRODUCT_SCOPE.md) | MVP boundary, acceptance criteria, and deferred post-MVP scope |
| [USER_FLOWS.md](docs/USER_FLOWS.md) | Core end-to-end member and operational journeys |
| [DOMAIN_MODEL.md](docs/DOMAIN_MODEL.md) | Four engines, invariants, state machines, concurrency controls |
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Stack evaluation, trade-offs, modular monolith & Flutter layering |
| [DATABASE.md](docs/DATABASE.md) | PostgreSQL table specifications, constraints, indexes, and RPCs |
| [ERD.md](docs/ERD.md) | Entity-relationship diagram across all core contexts |
| [SECURITY.md](docs/SECURITY.md) | RLS blueprint, `SECURITY DEFINER` governance, QR protocol, storage security |
| [PERMISSIONS.md](docs/PERMISSIONS.md) | Granular permission catalog, 8-role matrix, cross-branch policies |
| [DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md) | Brand direction, palette audit, 3 visual proposals, dual UX architecture |
| [TEST_STRATEGY.md](docs/TEST_STRATEGY.md) | Unit, widget, PostgreSQL RLS/concurrency, and E2E testing plan |
| [ROADMAP.md](docs/ROADMAP.md) | Phased vertical-slice milestones |
| [DEPLOYMENT.md](docs/DEPLOYMENT.md) | Environments, secrets, CI/CD blueprint, release discipline |
| [ADR-0001](docs/ADR/0001-initial-architecture.md) | Foundational architecture decisions and trade-offs |
| [IMPLEMENTATION_STATUS.md](docs/IMPLEMENTATION_STATUS.md) | Milestone completion & verification ledger |
| [KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) | External blockers & host tooling notes |

---

## Verified Toolchain, Tests & Build Artifacts

- **Formatting & Static Analysis:**
  - `dart format --output=none --set-exit-if-changed lib test` (`154 files`, 0 changed)
  - `flutter analyze --suppress-analytics` (`0 issues`)
- **Local PostgreSQL & SQL Security Tests (Docker Supabase Stack, Postgres 17):**
  - Updated [supabase/config.toml](supabase/config.toml) for Supabase CLI v3.3.0 (`[local_smtp]`, `[auth.email] enabled = true`) and ignored `node_modules/` in [.gitignore](.gitignore).
  - Executed `npx supabase start` and `npx supabase db reset`: all 5 migrations (`20261124000100`–`20261124000500`) + `supabase/seed.sql` applied cleanly.
  - Executed `supabase/tests/01`–`04` directly inside `supabase_db_ritma` (`psql -v ON_ERROR_STOP=1`): all `4/4` passed (`02` updated to escape literal `%%` inside PL/pgSQL `RAISE EXCEPTION`).
- **Supabase Cloud Schema Deployment (`ysgdtyexzmliidpiiarh`, Singapore `ap-southeast-1`):**
  - Verified `npx supabase db push --remote --dry-run` and applied `npx supabase db push --remote --yes`.
  - Confirmed via `npx supabase migration list --remote` that all 5 versions (`20261124000100`–`20261124000500`) are synchronized on Cloud without overwriting existing data or running `seed.sql` on Cloud.
- **Automated Flutter Test Suite (`28 passed, 1 skipped` offline + `1/1` live integration):**
  - Standard offline `flutter test --suppress-analytics`: `28` unit/widget/E2E tests passed (`DemoSandboxEngine` & widget harnesses); [supabase_backend_integration_test.dart](test/integration/supabase_backend_integration_test.dart) skips cleanly when run without `--dart-define`.
  - Live real-backend run against local Supabase (`http://127.0.0.1:54321`): `1/1 passed` verifying `AppMode.supabase`, all `10` concrete `Supabase*Repository` implementations, and all `12` operational workflows against real GoTrue Auth, PostgREST, PostgreSQL RLS, and `SECURITY DEFINER` RPCs.
- **Release Builds Verified on Windows 11 (Flutter 3.47.4 / Dart 3.13.3):**
  - Web release: `flutter build web --release --suppress-analytics` -> `build/web/index.html` (`1,544` bytes; Wasm dry run succeeded).
  - Android release APK: `flutter build apk --release --suppress-analytics` -> `build/app/outputs/flutter-apk/app-release.apk` (`59,036,590` bytes / `56.3 MB`).
  - iOS config verified: `ios/Runner.xcodeproj/project.pbxproj` defines `PRODUCT_BUNDLE_IDENTIFIER = com.ritma.ritma` and `IPHONEOS_DEPLOYMENT_TARGET = 15.0` (`.ipa` compilation requires macOS/Xcode).
- **Safe Client Setup & Remaining Limits:**
  - Populate git-ignored `env/dev.json` locally using `.\scripts\setup_dev_env.ps1` with only your Supabase Project URL and Publishable Key (`sb_publishable_...`) — `AppEnv.hasSupabaseConfig` explicitly rejects `sb_secret_` keys. Live Cloud app execution awaits those user-supplied client credentials in `env/dev.json`. See [KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md).
