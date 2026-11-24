# RITMA — Engineering & Product Decisions Log

This document records verified architectural, security, and product decisions made beyond [ADR-0001](ADR/0001-initial-architecture.md) during active implementation.

---

## Cycle 1 Decisions (2026-11-24)

### D-001: Composite Tenant Foreign Keys (`organization_id`, `branch_id`)
- **Context:** Single-column UUID foreign keys allow accidental cross-tenant links (e.g., a Branch B room assigned to a Branch A session, or an Org A member assigned an Org B package) if an RPC parameter is misaligned.
- **Decision:** Every tenant parent table exposes `UNIQUE (organization_id, id)` (and `UNIQUE (organization_id, branch_id, id)` for `rooms` and `class_sessions`), and child tables enforce composite FKs.

### D-002: `authz` `SECURITY DEFINER` RLS Helpers & `(SELECT auth.uid())` InitPlan Caching
- **Context:** Inline RLS subqueries against `user_role_assignments` risk infinite RLS recursion and repeated per-row evaluation overhead.
- **Decision:** Centralize `authz.has_permission`, `authz.has_any_branch_permission`, `authz.is_org_participant`, `authz.is_self_member`, and `authz.user_max_role_rank` as `SECURITY DEFINER`, `STABLE` functions pinned to `SET search_path = pg_catalog, public`, deriving the caller strictly via `(SELECT auth.uid())`.

### D-003: Normalized Eligibility Join Tables Instead of `uuid[]` Arrays
- **Context:** Storing branch/class filters in `allowed_branch_ids uuid[]` prevents foreign key validation and complicates SQL queries/indexes.
- **Decision:** Replace array columns on `package_entitlement_rules`, `member_entitlements`, and `credit_grants` with normalized join tables (`*_branches`, `*_class_types`) carrying composite tenant FKs.

### D-004: Multi-Grant FIFO Credit Consumption & Per-Grant Refund Uniqueness
- **Context:** A class costing `N > 1` credits may span multiple `credit_grants` buckets, requiring deterministic expiration order and safe refunds.
- **Decision:** Lock eligible `credit_grants` rows in deterministic FIFO order (`expires_at ASC NULLS LAST, created_at ASC, id ASC FOR UPDATE`), record per-grant ledger keys (`<idempotency_key>:<grant_id>`), and enforce `UNIQUE (organization_id, reference_type, reference_id, grant_id) WHERE entry_type = 'refund'`.

### D-005: Per-Organization QR HMAC Keys in Isolated `private` Schema
- **Context:** A shared global QR signing key weakens blast-radius isolation across tenants, while storing keys in `public` exposes them to PostgREST.
- **Decision:** Store per-organization 32-byte random keys in `private.organization_signing_keys` (`private` schema excluded from `supabase/config.toml` API schemas with `REVOKE ALL FROM PUBLIC, anon, authenticated`), accessed strictly inside QR RPCs.

### D-006: Visual Direction Lock-In — Direction A (Editorial Kinetic)
- **Decision:** Confirmed Direction A (Warm Ivory `#F6F4ED`, Porcelain `#FFFFFF`, Graphite `#202421`, Electric Lime `#C7F36B` accent containers, Deep Sage `#4E624A`, Deep/Muted Coral `#B34C3E`/`#D98276`) with semantic `ThemeExtension` tokens and `RitmaDensity.member` vs `RitmaDensity.operations`.

### D-007: Strict Separation of Real Auth vs Demo Sandbox
- **Decision:** Never implement fake production authentication. When `!hasSupabaseConfig && !enableDemoMode`, the app routes honestly to `BackendSetupScreen` with configuration instructions. When `ENABLE_DEMO_MODE=true` in non-production builds (`!isProduction`), `DemoSandboxAuthRepository` provides an explicitly badged multi-role sandbox for local UI verification without backend credentials.
