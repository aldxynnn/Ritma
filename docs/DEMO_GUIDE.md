# RITMA — Presenter & Tester Demo Guide

**Last Updated:** 2026-11-25  
**Live Hosted Web Demo:** https://aldxynnn.github.io/Ritma/ (GitHub Pages HTTPS)  
**Target Supabase Cloud Project:** `ritma` (`ysgdtyexzmliidpiiarh`, `ap-southeast-1`)

---

## 1. Flagship Live Showcase Environment (`RITMA Atelier & Athletic`)

The live Supabase Cloud project is populated additively (without disturbing any prior test organizations) via [`scripts/seed_cloud_demo.mjs`](../scripts/seed_cloud_demo.mjs):

- **Organization:** `RITMA Atelier & Athletic` (`USD`, `Asia/Jakarta`, hybrid gym + boutique studio)
- **Branches (`2`):**
  - `SCBD Flagship Gym` (`SCBD`)
  - `Senopati Boutique Studio` (`SNPT`)
- **Studios & Floor Zones (`4`):** `Athletic Conditioning Floor`, `Cycle & Sweat Box`, `Reformer Pilates Sanctuary`, `Sunlight Yoga Loft`
- **Commercial Packages (`5`, all 4 entitlement types):** `Flagship Gym Unlimited`, `Boutique 10-Class Pack`, `RITMA Hybrid All-Access VIP`, `5-Session PT Pack`, `Studio Starter 5-Class Pack`
- **Members (`10`, `9` active + `1` frozen `Bima Santoso`):** Named member profiles across SCBD and Senopati, with idempotent subscriptions and `$2,055.00` in recorded payments
- **Schedule, Waitlist & Personal Training:** `8` published classes (including a full `2/2` session `Core & Mobility Restore` with automatic waitlist `#1`), `2` coaches (`Coach Maya Putri` & `Coach Dimas Pratama`) with 7-day availability windows, `1` completed + `1` scheduled PT session
- **Facility Access, Equipment & Notifications:** `4` facility check-ins (`3` on floor, `1` checked out), `6` equipment assets (`CYC-01`, `RAC-01`, `REF-01`, `REF-02`, `SKR-01`, `SKR-02`), `2` maintenance tickets, and DB-trigger notifications (`20261124000700`)

---

## 2. Live Cloud Demo Accounts

All five demo accounts share the dev/showcase password **`RitmaDemo2026!`** (and never appear in production UI because `SignInScreen` hides quick-fill chips whenever `APP_ENV=prod`):

| Role / Surface | Email | Password | Member / Scope | Best Used To Demonstrate |
|---|---|---|---|---|
| **Multi-Role Owner + Member** | `demo.owner@ritma.app` | `RitmaDemo2026!` | Nadia Kusuma (`RTM-1000`, `SCBD` / `All Branches`) | Seamless switching between `Organization Owner` Ops Console and `Fitness Member` Digital Pass |
| **Branch Manager** | `demo.manager@ritma.app` | `RitmaDemo2026!` | Raka Mahendra (`Senopati Boutique Studio`) | Branch-scoped RBAC isolation (`SNPT` data only) |
| **Fitness Member** | `demo.member@ritma.app` | `RitmaDemo2026!` | Alya Rahma (`RTM-1001`, `SCBD Flagship Gym`) | Member-only experience, VIP + PT wallet separation, `#1` Waitlist badge, `/ops/*` route isolation |
| **Personal Trainer 1** | `demo.trainer1@ritma.app` | `RitmaDemo2026!` | Coach Maya Putri (`Senopati Boutique Studio`) | Trainer role workspace & coaching sessions |
| **Personal Trainer 2** | `demo.trainer2@ritma.app` | `RitmaDemo2026!` | Coach Dimas Pratama (`SCBD Flagship Gym`) | Multi-branch trainer roster |

> **One-click login in Dev Web/Mobile:** On `SignInScreen`, tap **`Owner (Multi-Role)`**, **`Branch Manager`**, or **`Fitness Member`** under **Showcase Demo Accounts (Live Cloud)** to pre-fill credentials cleanly before tapping **Sign In**.

---

## 3. Recommended 5-Minute Live Demo Script

1. **Auth & Multi-Role Context (`#/auth/sign-in` → `#/workspaces`)**
   - Point out the Editorial Kinetic split hero in Obsidian Dark Mode, click **`Owner (Multi-Role)`** → **Sign In**.
   - On **Select Workspace**, highlight how a single login (`Nadia Kusuma`) holds both **Operations Workspaces** (`Organization Owner • All Branches`) and **Member Passes** (`Fitness Member • SCBD Flagship Gym`).
   - Select **Organization Owner**.
2. **Operations Console — Live KPIs (`#/ops/dashboard`)**
   - Toggle `7 Days` / `30 Days` (`Active Members: 9`, `Today's Gym Visits: 4`, `Class Occupancy: 8.6%`, `Revenue (30d): $2,055.00`).
   - Show **Recent Check-Ins** with resolved member names and **Upcoming Classes** utilization progress bars.
3. **Front-Desk QR & Lookup (`#/ops/checkin`)**
   - Highlight active floor pill (`3 Active on Floor`), run **Manual Member Lookup** for `Alya`, and demonstrate `Check In` / `Override` (mandatory audit reason) and `Check Out`.
4. **Boutique Studio Schedule & Personal Training (`#/ops/schedule`)**
   - Show `Core & Mobility Restore` (`2/2` + `Waitlist ON`), `Sunrise Vinyasa Flow`, or publish a new class with **New Session** (inline validation + confirmation SnackBar).
   - Switch segmented control to **Personal Training** to show `Coach Maya Putri` & `Coach Dimas Pratama` and PT-credit-backed 1-on-1 sessions.
5. **Commercial Operations & Entitlement Ledger (`#/ops/members`)**
   - Browse the 10-member directory (`Alya Rahma`, `Bima Santoso` `Frozen`), open a member detail sheet to show separated **Facility Access**, **Class Credits**, and **PT Credits** + **Credit Ledger (Append-Only)**.
   - Switch to **Packages** (5 packages spanning all 4 entitlement types) and **Payments** (`$2,055.00` volume with resolved member names).
6. **Notifications, Equipment & Theme Toggle (`#/ops/settings`)**
   - Tap the AppBar **Bell** icon to view DB-triggered notifications (`Membership Activated`, `Class Booking Confirmed`).
   - Tap the AppBar **Sun/Moon** toggle to preview Light Mode (`Warm Ivory` / `Porcelain`) and switch back to Dark Mode.
   - Open **Branches, Rooms & Staff** and **Equipment & Maintenance** (`6` tracked assets, `2` maintenance tickets).
7. **Isolated Member Experience (`Switch` → `Fitness Member`)**
   - Click **`Switch`** in the AppBar → select **Fitness Member**.
   - Show the **Digital Access Pass** (`QR` token rotation, `Facility Access Active`, Class vs PT credits, Recent Visits) and Member Schedule / Bookings.
   - Optionally navigate manually to `#/ops/dashboard` while in Member mode to prove the GoRouter role guard redirects straight back to `#/member/home`.

---

## 4. Live Hosting, Build Artifacts & Run Commands

### Instant Hosted Web App (No Local Setup Needed)
- **Live URL:** **https://aldxynnn.github.io/Ritma/** (deployed free on GitHub Pages via orphan `gh-pages` branch built with `--base-href "/Ritma/"`, HTTPS enforced).
- **Verified Multi-Role Interactive QA on Hosted Bundle:** All 5 demo accounts (`demo.owner@ritma.app`, `demo.manager@ritma.app`, `demo.member@ritma.app`, `demo.trainer1@ritma.app`, `demo.trainer2@ritma.app`) and live actions (Check-In/Check-Out, Class Roster, Member Entitlements, Branch Manager Senopati scoping, Member `Rotate QR`, `/ops/dashboard` route isolation guard, Class Booking + Cancel Credit Refund, and Personal Trainer scoping) passed with **0 HTTP >= 400 / 404** and **0 console errors**.

### Development Server (Live Cloud)
```powershell
& "C:\src\flutter\bin\flutter.bat" run -d web-server --web-hostname 127.0.0.1 --web-port 8091 --dart-define-from-file=env/dev.json --suppress-analytics
```

### Verified Release Artifacts (Compiled Against `env/dev.json`)
- **Flutter Web Release Bundle:**
  - Command (root `/`): `& "C:\src\flutter\bin\flutter.bat" build web --release --dart-define-from-file=env/dev.json --suppress-analytics`
  - Command (GitHub Pages `/Ritma/`): `& "C:\src\flutter\bin\flutter.bat" build web --release --base-href "/Ritma/" --dart-define-from-file=env/dev.json --suppress-analytics`
  - Local `build/web/` currently holds the `--base-href "/Ritma/"` bundle for GitHub Pages (`gh-pages`).
- **Android Release APK:**
  - Command: `& "C:\src\flutter\bin\flutter.bat" build apk --release --dart-define-from-file=env/dev.json --suppress-analytics`
  - Output file: `build/app/outputs/flutter-apk/app-release.apk` (`56.55 MB` / `59,299,750 bytes`, `com.ritma.ritma`, `minSdk 24`, `targetSdk 36`, `android.permission.INTERNET` granted)
  - Verified live on `Pixel_9` Android emulator (`adb install -r` -> `Success`, cold launch `PID=3101`, `0` crashes, and live Cloud login into `Select Workspace` as `Nadia Kusuma`).

### Re-Seeding Demo Data (Idempotent)
```powershell
node scripts/seed_cloud_demo.mjs
```

---

## 5. Mandatory Pre-Production Hardening Checklist

Before pointing builds at a real customer production environment:
1. Build production clients with `--dart-define=APP_ENV=prod` (`AppEnv.isProduction == true` automatically hides all quick-login demo chips and banners).
2. Restore `[auth.email] enable_confirmations = true` in `supabase/config.toml` and push via `npx supabase config push --remote` alongside a verified production SMTP provider.
3. Rotate or remove showcase users (`demo.owner@ritma.app`, `demo.manager@ritma.app`, `demo.member@ritma.app`, `demo.trainer1@ritma.app`, `demo.trainer2@ritma.app`) and keep `env/*.json` git-ignored.
