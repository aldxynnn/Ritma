-- =============================================================================
-- Migration 000600: Explicit Least-Privilege Table Grants for Supabase Cloud
--
-- Local Supabase Docker stacks configure default privileges for `authenticated`
-- in `public`, whereas managed Supabase Cloud projects require explicit table
-- privileges alongside Row Level Security policies. Without explicit SELECT /
-- INSERT / UPDATE / DELETE grants to `authenticated`, PostgREST requests fail
-- with HTTP 403 (`42501: permission denied for table ...`) even when valid
-- RLS policies exist.
--
-- This forward-only migration revokes broad public/anon/authenticated table
-- rights on `public.*` and grants the exact minimum verbs permitted by each
-- table's RLS policies and RPC-only mutation boundaries.
-- =============================================================================

GRANT USAGE ON SCHEMA public TO authenticated;

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC, anon, authenticated;

-- -----------------------------------------------------------------------------
-- 1. SELECT ONLY (reference catalogs, immutable logs, RPC-mutated tables)
-- -----------------------------------------------------------------------------
GRANT SELECT ON TABLE
  public.roles,
  public.permissions,
  public.role_permissions,
  public.user_role_assignments,
  public.organization_invitations,
  public.audit_logs,
  public.member_claim_invitations,
  public.member_subscriptions,
  public.member_entitlements,
  public.member_entitlement_branches,
  public.member_entitlement_class_types,
  public.payment_records,
  public.credit_grants,
  public.credit_grant_branches,
  public.credit_grant_class_types,
  public.credit_adjustments,
  public.credit_ledger_entries,
  public.facility_visits,
  public.facility_access_attempts,
  public.class_bookings,
  public.pt_sessions
TO authenticated;

-- -----------------------------------------------------------------------------
-- 2. SELECT, UPDATE ONLY (guard triggers / RLS restrict updatable columns)
-- -----------------------------------------------------------------------------
GRANT SELECT, UPDATE ON TABLE
  public.organizations,
  public.user_notifications
TO authenticated;

-- -----------------------------------------------------------------------------
-- 3. SELECT, INSERT, UPDATE (standard RLS-governed operational entities)
-- -----------------------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE ON TABLE
  public.branches,
  public.rooms,
  public.user_profiles,
  public.members,
  public.class_types,
  public.packages,
  public.package_entitlement_rules,
  public.class_templates,
  public.class_sessions,
  public.trainer_profiles
TO authenticated;

-- -----------------------------------------------------------------------------
-- 4. SELECT, INSERT, DELETE (join tables with add/remove RLS policies)
-- -----------------------------------------------------------------------------
GRANT SELECT, INSERT, DELETE ON TABLE
  public.package_rule_branches,
  public.package_rule_class_types
TO authenticated;

-- -----------------------------------------------------------------------------
-- 5. SELECT, INSERT, UPDATE, DELETE (entities with FOR ALL RLS policies)
-- -----------------------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE
  public.trainer_availabilities,
  public.equipment_assets,
  public.equipment_maintenance_tickets
TO authenticated;

-- Re-assert defensive restrictions on structural table operations
REVOKE TRUNCATE, TRIGGER, REFERENCES ON ALL TABLES IN SCHEMA public FROM PUBLIC, anon, authenticated;
