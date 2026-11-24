# RITMA — Release Notes

## Unreleased (Cycle 1 — In Progress)

### Foundation & GitHub Delivery
- Published initial checkpoint commit `6912f93` to `origin/main` (`https://github.com/aldxynnn/Ritma.git`).
- Added `.gitattributes` for consistent cross-platform line endings.

### Auth, Multi-Role Context Switching & Dual Shells (Phase 4)
- Integrated `supabase_flutter` (`SupabaseAuthRepository`, `AuthException` / `PostgrestException` / domain RPC error mapping in `ErrorMapper`, and `BackendSetupScreen` when unconfigured).
- Added explicitly isolated, non-production `DemoSandboxAuthRepository` (`ENABLE_DEMO_MODE=true`) with persistent `DEMO SANDBOX MODE` UI banner.
- Built Direction A (`Editorial Kinetic`) `RitmaStatusColors`, `RitmaDensityScope`, adaptive `RitmaResponsiveScaffold`, `WorkspacePickerScreen` (multi-org/multi-branch/multi-role switcher + invite/claim redemption), and role-isolated `MemberShell` (`/member/*`) vs `OpsShell` (`/ops/*`) navigation.
- Verified with `dart format`, `flutter analyze` (0 issues), and `19/19` unit/widget tests including light/dark themes and `1.5x` text scaling.

### Supabase Backend Foundation (Phase 3)
- Authored PostgreSQL schema migrations (`000100`–`000500`), `supabase/config.toml`, dev `seed.sql`, and SQL security/concurrency suites (`supabase/tests/01`–`04`).
- Hardened against independent Claude Opus 5.5 + Gemini 4 Hydrogen security audit: consent-based org & member claim invitations (`C1`, `H2`), NULL override guard (`H1`), server-derived PT booking pricing/branch/availability (`H3`), atomic `credit_adjustments` idempotency (`H4`), key rotation with 2m grace & single-use QR nonce tracking (`H5`, `M1`), fingerprint-bound check-in idempotency (`M2`), strict branch-scoped RLS & PII-filtered `get_session_roster` (`M4`, `M5`), catalog soft-delete (`M6`), `class_sessions` insert/cancel guards (`M7`), grant freeze extension (`M8`), and `TRUNCATE` immutability (`M10`).
