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
│   ├── app/                        # Composition root, bootstrap, GoRouter setup
│   ├── core/                       # Config, errors (Freezed), logging, result, base repository, theme, shared widgets
│   └── features/
│       └── foundation/             # Verified bootstrap shell (prior to Milestone 2 business slices)
└── test/                           # Unit and widget tests
```

---

## Local Setup & Commands

### Prerequisites
- Flutter 3.47+ (Dart 3.13+)
- Android SDK / Xcode (for mobile targets) or Chrome (for Web)

### Environment Configuration
Copy [env/dev.example.json](env/dev.example.json) to `env/dev.json` (git-ignored) and supply local/dev values when Milestone 2 activates Supabase:

```bash
flutter pub get
dart run build_runner build
flutter run --dart-define-from-file=env/dev.json
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
