-- RITMA Migration 000100: Foundation, Multi-Tenant Orgs, Branches, Rooms, Identity, Invitations, RBAC & Audit
-- Source of truth for tenant boundaries, role hierarchy, consent-based invitations, default-deny RLS, and hardened authz helpers.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_catalog.pg_roles
    WHERE rolname = current_user AND (rolsuper OR rolbypassrls)
  ) THEN
    RAISE EXCEPTION 'Migration role % requires SUPERUSER or BYPASSRLS for SECURITY DEFINER + FORCE RLS', current_user;
  END IF;
END $$;

CREATE SCHEMA IF NOT EXISTS extensions;
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

CREATE SCHEMA IF NOT EXISTS authz;
CREATE SCHEMA IF NOT EXISTS private;

REVOKE ALL ON SCHEMA private FROM PUBLIC, anon, authenticated;
REVOKE ALL ON SCHEMA authz FROM PUBLIC, anon;
GRANT USAGE ON SCHEMA authz TO authenticated;

-- ---------------------------------------------------------------------------
-- Shared trigger helpers
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION private.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, public, pg_temp
AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION private.prevent_row_mutation()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, public, pg_temp
AS $$
BEGIN
  RAISE EXCEPTION 'Table %.% is append-only; % operations are prohibited',
    TG_TABLE_SCHEMA, TG_TABLE_NAME, TG_OP
    USING ERRCODE = '42501';
END;
$$;

-- ---------------------------------------------------------------------------
-- Tenant root & location tables
-- ---------------------------------------------------------------------------

CREATE TABLE public.organizations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL CHECK (char_length(trim(name)) BETWEEN 2 AND 120),
  slug text NOT NULL UNIQUE CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  business_type text NOT NULL DEFAULT 'hybrid'
    CHECK (business_type IN (
      'traditional_gym',
      'boutique_studio',
      'crossfit_functional',
      'personal_training',
      'hybrid',
      'multi_branch'
    )),
  timezone text NOT NULL DEFAULT 'UTC',
  currency_code text NOT NULL DEFAULT 'USD' CHECK (char_length(currency_code) = 3),
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'archived')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_organizations_updated_at
  BEFORE UPDATE ON public.organizations
  FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();

-- Per-organization HMAC signing keys isolated in private schema (F7).
CREATE TABLE private.organization_signing_keys (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  key_version integer NOT NULL DEFAULT 1 CHECK (key_version > 0),
  secret_key bytea NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  rotated_at timestamptz,
  UNIQUE (organization_id, key_version)
);

CREATE UNIQUE INDEX idx_org_signing_keys_active
  ON private.organization_signing_keys (organization_id)
  WHERE is_active = true;

REVOKE ALL ON TABLE private.organization_signing_keys FROM PUBLIC, anon, authenticated;

CREATE TABLE public.branches (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  name text NOT NULL CHECK (char_length(trim(name)) BETWEEN 2 AND 120),
  code text NOT NULL CHECK (code ~ '^[A-Za-z0-9_-]{2,24}$'),
  address text,
  timezone text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (organization_id, id),
  UNIQUE (organization_id, code)
);

CREATE INDEX idx_branches_org_active ON public.branches (organization_id, is_active);

CREATE TRIGGER trg_branches_updated_at
  BEFORE UPDATE ON public.branches
  FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();

CREATE TABLE public.rooms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  name text NOT NULL CHECK (char_length(trim(name)) BETWEEN 1 AND 80),
  room_type text NOT NULL DEFAULT 'studio',
  default_capacity integer NOT NULL CHECK (default_capacity > 0),
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (organization_id, branch_id)
    REFERENCES public.branches(organization_id, id) ON DELETE CASCADE,
  UNIQUE (organization_id, branch_id, id),
  UNIQUE (organization_id, branch_id, name)
);

CREATE INDEX idx_rooms_org_branch ON public.rooms (organization_id, branch_id, is_active);

CREATE TRIGGER trg_rooms_updated_at
  BEFORE UPDATE ON public.rooms
  FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();

-- ---------------------------------------------------------------------------
-- Identity, Roles, Permissions, Invitations & Role Assignments
-- ---------------------------------------------------------------------------

CREATE TABLE public.user_profiles (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name text NOT NULL DEFAULT '',
  phone text,
  avatar_path text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_user_profiles_updated_at
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();

CREATE OR REPLACE FUNCTION private.handle_new_auth_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
BEGIN
  INSERT INTO public.user_profiles (user_id, full_name)
  VALUES (
    NEW.id,
    COALESCE(NULLIF(trim(NEW.raw_user_meta_data ->> 'full_name'), ''), '')
  )
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION private.handle_new_auth_user();

CREATE TABLE public.roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  rank integer NOT NULL CHECK (rank > 0),
  scope_level text NOT NULL CHECK (scope_level IN ('organization', 'branch', 'member')),
  display_name text NOT NULL,
  description text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.permissions (
  code text PRIMARY KEY,
  domain text NOT NULL,
  description text NOT NULL DEFAULT '',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.role_permissions (
  role_id uuid NOT NULL REFERENCES public.roles(id) ON DELETE CASCADE,
  permission_code text NOT NULL REFERENCES public.permissions(code) ON DELETE CASCADE,
  PRIMARY KEY (role_id, permission_code)
);

CREATE TABLE public.user_role_assignments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  branch_id uuid,
  role_id uuid NOT NULL REFERENCES public.roles(id),
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'revoked')),
  assigned_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  revoked_at timestamptz,
  FOREIGN KEY (organization_id, branch_id)
    REFERENCES public.branches(organization_id, id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX idx_ura_unique_active
  ON public.user_role_assignments (
    user_id,
    organization_id,
    COALESCE(branch_id, '00000000-0000-0000-0000-000000000000'::uuid),
    role_id
  )
  WHERE status = 'active';

CREATE INDEX idx_ura_user_org_active
  ON public.user_role_assignments (user_id, organization_id, branch_id)
  WHERE status = 'active';

CREATE INDEX idx_ura_org_active
  ON public.user_role_assignments (organization_id, status);

CREATE TRIGGER trg_ura_updated_at
  BEFORE UPDATE ON public.user_role_assignments
  FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();

-- Consent-based organization invitations (fixes C1 cross-tenant assignment & PII leak).
CREATE TABLE public.organization_invitations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  branch_id uuid,
  role_id uuid NOT NULL REFERENCES public.roles(id),
  invited_email text NOT NULL,
  token_hash text NOT NULL UNIQUE,
  status text NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'accepted', 'revoked', 'expired')),
  invited_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  accepted_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  expires_at timestamptz NOT NULL DEFAULT (now() + interval '7 days'),
  accepted_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (organization_id, branch_id)
    REFERENCES public.branches(organization_id, id) ON DELETE CASCADE
);

CREATE INDEX idx_org_invites_org_status
  ON public.organization_invitations (organization_id, status, lower(invited_email));

-- ---------------------------------------------------------------------------
-- Immutable Audit Log (row + TRUNCATE triggers, M10)
-- ---------------------------------------------------------------------------

CREATE TABLE public.audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
  branch_id uuid,
  -- Plain uuid (no FK to auth.users) preserves immutable compliance audit history when a user is deleted (M9).
  actor_user_id uuid,
  action text NOT NULL,
  target_type text NOT NULL,
  target_id uuid,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (organization_id, branch_id)
    REFERENCES public.branches(organization_id, id) ON DELETE RESTRICT
);

CREATE INDEX idx_audit_logs_org_created
  ON public.audit_logs (organization_id, created_at DESC);

CREATE INDEX idx_audit_logs_org_branch_created
  ON public.audit_logs (organization_id, branch_id, created_at DESC);

CREATE TRIGGER trg_audit_logs_immutable
  BEFORE UPDATE OR DELETE ON public.audit_logs
  FOR EACH ROW EXECUTE FUNCTION private.prevent_row_mutation();

CREATE TRIGGER trg_audit_logs_no_truncate
  BEFORE TRUNCATE ON public.audit_logs
  FOR EACH STATEMENT EXECUTE FUNCTION private.prevent_row_mutation();

-- ---------------------------------------------------------------------------
-- Seed Canonical System Roles & Granular Permissions
-- ---------------------------------------------------------------------------

INSERT INTO public.roles (code, rank, scope_level, display_name, description) VALUES
  ('org_owner', 100, 'organization', 'Organization Owner', 'Full organization ownership and governance'),
  ('org_admin', 80, 'organization', 'Organization Admin', 'Cross-branch administration and catalog management'),
  ('branch_manager', 60, 'branch', 'Branch Manager', 'Branch-scoped operations, schedules, staff, and metrics'),
  ('receptionist', 40, 'branch', 'Receptionist', 'Front-desk check-in, member onboarding, and class booking'),
  ('gym_staff', 30, 'branch', 'Gym Staff', 'Floor operations and facility check-in verification'),
  ('instructor', 30, 'branch', 'Fitness Instructor', 'Assigned class roster and live attendance marking'),
  ('personal_trainer', 30, 'branch', 'Personal Trainer', 'Assigned PT clients and private training sessions'),
  ('member', 10, 'member', 'Fitness Member', 'Self-service digital QR pass, memberships, and bookings')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.permissions (code, domain, description) VALUES
  ('org.manage', 'organization', 'Edit organization profile, timezone, currency, and policies'),
  ('branch.manage', 'organization', 'Create and update branches and rooms'),
  ('role.assign', 'organization', 'Invite staff and manage roles within scope and hierarchy'),
  ('audit.read', 'organization', 'Inspect immutable audit logs'),
  ('member.read', 'members', 'View member profiles within branch scope'),
  ('member.write', 'members', 'Register and edit members within branch scope'),
  ('package.manage', 'catalog', 'Create, update, and archive commercial packages'),
  ('entitlement.read', 'entitlements', 'View member subscriptions, entitlements, and credit balances'),
  ('entitlement.assign', 'entitlements', 'Assign packages, activate, freeze, and unfreeze subscriptions'),
  ('credit.adjust', 'credits', 'Post manual credit adjustments with mandatory reason'),
  ('payment.read', 'payments', 'View branch payment records'),
  ('payment.record', 'payments', 'Record front-desk payments'),
  ('payment.refund', 'payments', 'Void or refund recorded payments'),
  ('checkin.perform', 'facility_access', 'Validate QR passes and perform gym check-in/out'),
  ('checkin.read', 'facility_access', 'View branch visit logs and occupancy'),
  ('checkin.force_override', 'facility_access', 'Force check-in override with mandatory audit reason'),
  ('schedule.manage', 'booking', 'Create and manage class templates and branch sessions'),
  ('booking.read', 'booking', 'View class rosters and waitlists'),
  ('booking.manage', 'booking', 'Book and cancel classes on behalf of members'),
  ('attendance.mark', 'booking', 'Mark checked_in or no_show on class rosters'),
  ('dashboard.org.read', 'dashboard', 'View organization-wide operational KPIs'),
  ('dashboard.branch.read', 'dashboard', 'View branch-scoped operational KPIs'),
  ('pt.manage', 'personal_training', 'Manage trainer availability and PT sessions'),
  ('equipment.manage', 'equipment', 'Manage gym equipment assets and maintenance tickets')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_code)
SELECT r.id, p.code
FROM public.roles r
CROSS JOIN public.permissions p
WHERE
  (r.code = 'org_owner')
  OR (r.code = 'org_admin' AND p.code IN (
    'branch.manage', 'role.assign', 'audit.read',
    'member.read', 'member.write',
    'package.manage', 'entitlement.read', 'entitlement.assign', 'credit.adjust',
    'payment.read', 'payment.record', 'payment.refund',
    'checkin.perform', 'checkin.read', 'checkin.force_override',
    'schedule.manage', 'booking.read', 'booking.manage', 'attendance.mark',
    'dashboard.org.read', 'dashboard.branch.read', 'pt.manage', 'equipment.manage'
  ))
  OR (r.code = 'branch_manager' AND p.code IN (
    'role.assign', 'audit.read',
    'member.read', 'member.write',
    'entitlement.read', 'entitlement.assign', 'credit.adjust',
    'payment.read', 'payment.record',
    'checkin.perform', 'checkin.read', 'checkin.force_override',
    'schedule.manage', 'booking.read', 'booking.manage', 'attendance.mark',
    'dashboard.branch.read', 'pt.manage', 'equipment.manage'
  ))
  OR (r.code = 'receptionist' AND p.code IN (
    'member.read', 'member.write',
    'entitlement.read', 'entitlement.assign',
    'payment.read', 'payment.record',
    'checkin.perform', 'checkin.read',
    'booking.read', 'booking.manage', 'attendance.mark'
  ))
  OR (r.code = 'gym_staff' AND p.code IN (
    'member.read',
    'checkin.perform', 'checkin.read',
    'equipment.manage'
  ))
  OR (r.code = 'instructor' AND p.code IN (
    'attendance.mark'
  ))
  OR (r.code = 'personal_trainer' AND p.code IN (
    'pt.manage'
  ))
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------------
-- Hardened SECURITY DEFINER Authorization Helpers (F2, L7)
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION authz.has_permission(
  p_org_id uuid,
  p_branch_id uuid,
  p_permission text
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_role_assignments ura
    JOIN public.role_permissions rp ON rp.role_id = ura.role_id
    WHERE ura.user_id = (SELECT auth.uid())
      AND ura.organization_id = p_org_id
      AND ura.status = 'active'
      AND rp.permission_code = p_permission
      AND (
        ura.branch_id IS NULL
        OR (p_branch_id IS NOT NULL AND ura.branch_id = p_branch_id)
      )
  );
$$;

CREATE OR REPLACE FUNCTION authz.has_any_branch_permission(
  p_org_id uuid,
  p_permission text
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_role_assignments ura
    JOIN public.role_permissions rp ON rp.role_id = ura.role_id
    WHERE ura.user_id = (SELECT auth.uid())
      AND ura.organization_id = p_org_id
      AND ura.status = 'active'
      AND rp.permission_code = p_permission
  );
$$;

-- Overwritten in migration 000200 once public.members exists.
CREATE OR REPLACE FUNCTION authz.is_org_participant(p_org_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_role_assignments ura
    WHERE ura.user_id = (SELECT auth.uid())
      AND ura.organization_id = p_org_id
      AND ura.status = 'active'
  );
$$;

-- Overwritten in migration 000200 to also check linked members.
CREATE OR REPLACE FUNCTION authz.is_user_org_participant(
  p_org_id uuid,
  p_target_user_id uuid
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_role_assignments ura
    WHERE ura.user_id = p_target_user_id
      AND ura.organization_id = p_org_id
      AND ura.status = 'active'
  );
$$;

-- Strict PII boundary (C1): only callers with role.assign or schedule.manage in org can read staff profiles of active staff in that org.
CREATE OR REPLACE FUNCTION authz.can_view_org_staff_profile(p_target_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_role_assignments target_ura
    JOIN public.roles r ON r.id = target_ura.role_id
    WHERE target_ura.user_id = p_target_user_id
      AND target_ura.status = 'active'
      AND r.code <> 'member'
      AND (
        authz.has_permission(target_ura.organization_id, target_ura.branch_id, 'role.assign')
        OR authz.has_permission(target_ura.organization_id, target_ura.branch_id, 'schedule.manage')
      )
  );
$$;

CREATE OR REPLACE FUNCTION authz.user_max_role_rank(
  p_org_id uuid,
  p_branch_id uuid DEFAULT NULL
)
RETURNS integer
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
  SELECT COALESCE(MAX(r.rank), 0)
  FROM public.user_role_assignments ura
  JOIN public.roles r ON r.id = ura.role_id
  WHERE ura.user_id = (SELECT auth.uid())
    AND ura.organization_id = p_org_id
    AND ura.status = 'active'
    AND (
      ura.branch_id IS NULL
      OR (p_branch_id IS NOT NULL AND ura.branch_id = p_branch_id)
    );
$$;

REVOKE ALL ON FUNCTION authz.has_permission(uuid, uuid, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION authz.has_any_branch_permission(uuid, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION authz.is_org_participant(uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION authz.is_user_org_participant(uuid, uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION authz.can_view_org_staff_profile(uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION authz.user_max_role_rank(uuid, uuid) FROM PUBLIC, anon;

GRANT EXECUTE ON FUNCTION authz.has_permission(uuid, uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION authz.has_any_branch_permission(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION authz.is_org_participant(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION authz.is_user_org_participant(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION authz.can_view_org_staff_profile(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION authz.user_max_role_rank(uuid, uuid) TO authenticated;

-- ---------------------------------------------------------------------------
-- Default-Deny Row Level Security (ENABLE + FORCE)
-- ---------------------------------------------------------------------------

ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organizations FORCE ROW LEVEL SECURITY;
ALTER TABLE public.branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.branches FORCE ROW LEVEL SECURITY;
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rooms FORCE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles FORCE ROW LEVEL SECURITY;
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles FORCE ROW LEVEL SECURITY;
ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.permissions FORCE ROW LEVEL SECURITY;
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_permissions FORCE ROW LEVEL SECURITY;
ALTER TABLE public.user_role_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_role_assignments FORCE ROW LEVEL SECURITY;
ALTER TABLE public.organization_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_invitations FORCE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs FORCE ROW LEVEL SECURITY;

-- Organizations
CREATE POLICY orgs_select_participant ON public.organizations
  FOR SELECT TO authenticated
  USING (authz.is_org_participant(id));

CREATE POLICY orgs_update_owner ON public.organizations
  FOR UPDATE TO authenticated
  USING (authz.has_permission(id, NULL, 'org.manage'))
  WITH CHECK (authz.has_permission(id, NULL, 'org.manage'));

-- Branches & Rooms
CREATE POLICY branches_select_participant ON public.branches
  FOR SELECT TO authenticated
  USING (authz.is_org_participant(organization_id));

CREATE POLICY branches_insert_manage ON public.branches
  FOR INSERT TO authenticated
  WITH CHECK (authz.has_permission(organization_id, NULL, 'branch.manage'));

CREATE POLICY branches_update_manage ON public.branches
  FOR UPDATE TO authenticated
  USING (authz.has_permission(organization_id, NULL, 'branch.manage'))
  WITH CHECK (authz.has_permission(organization_id, NULL, 'branch.manage'));

CREATE POLICY rooms_select_participant ON public.rooms
  FOR SELECT TO authenticated
  USING (authz.is_org_participant(organization_id));

CREATE POLICY rooms_insert_manage ON public.rooms
  FOR INSERT TO authenticated
  WITH CHECK (authz.has_permission(organization_id, NULL, 'branch.manage'));

CREATE POLICY rooms_update_manage ON public.rooms
  FOR UPDATE TO authenticated
  USING (authz.has_permission(organization_id, NULL, 'branch.manage'))
  WITH CHECK (authz.has_permission(organization_id, NULL, 'branch.manage'));

-- User Profiles (C1 hardened: self OR org staff managers only)
CREATE POLICY profiles_select_self_or_staff_mgr ON public.user_profiles
  FOR SELECT TO authenticated
  USING (
    user_id = (SELECT auth.uid())
    OR authz.can_view_org_staff_profile(user_id)
  );

CREATE POLICY profiles_insert_self ON public.user_profiles
  FOR INSERT TO authenticated
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY profiles_update_self ON public.user_profiles
  FOR UPDATE TO authenticated
  USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

-- System catalogs (read-only for authenticated)
CREATE POLICY roles_select_auth ON public.roles FOR SELECT TO authenticated USING (true);
CREATE POLICY permissions_select_auth ON public.permissions FOR SELECT TO authenticated USING (true);
CREATE POLICY role_permissions_select_auth ON public.role_permissions FOR SELECT TO authenticated USING (true);

-- User Role Assignments (direct writes denied)
CREATE POLICY ura_select_own_or_admin ON public.user_role_assignments
  FOR SELECT TO authenticated
  USING (
    user_id = (SELECT auth.uid())
    OR authz.has_permission(organization_id, branch_id, 'role.assign')
  );

-- Organization Invitations (direct writes denied)
CREATE POLICY org_invites_select ON public.organization_invitations
  FOR SELECT TO authenticated
  USING (
    lower(invited_email) = lower(COALESCE((SELECT auth.jwt() ->> 'email'), ''))
    OR authz.has_permission(organization_id, branch_id, 'role.assign')
  );

-- Audit Logs (direct writes denied)
CREATE POLICY audit_logs_select_scoped ON public.audit_logs
  FOR SELECT TO authenticated
  USING (authz.has_permission(organization_id, branch_id, 'audit.read'));

-- ---------------------------------------------------------------------------
-- Transactional RPCs: Org Bootstrapping, Consent Invitations, Role Governance
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.create_organization_with_owner(
  p_name text,
  p_slug text,
  p_business_type text DEFAULT 'hybrid',
  p_timezone text DEFAULT 'UTC',
  p_currency_code text DEFAULT 'USD',
  p_first_branch_name text DEFAULT 'Main Branch',
  p_first_branch_code text DEFAULT 'MAIN'
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, pg_temp
AS $$
DECLARE
  v_user_id uuid := (SELECT auth.uid());
  v_org_id uuid;
  v_branch_id uuid;
  v_owner_role_id uuid;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_catalog.pg_timezone_names WHERE name = p_timezone) THEN
    RAISE EXCEPTION 'VALIDATION_ERROR: Invalid timezone %', p_timezone USING ERRCODE = '22023';
  END IF;

  INSERT INTO public.user_profiles (user_id, full_name)
  VALUES (v_user_id, '')
  ON CONFLICT (user_id) DO NOTHING;

  INSERT INTO public.organizations (name, slug, business_type, timezone, currency_code)
  VALUES (trim(p_name), lower(trim(p_slug)), p_business_type, p_timezone, upper(trim(p_currency_code)))
  RETURNING id INTO v_org_id;

  INSERT INTO private.organization_signing_keys (organization_id, key_version, secret_key, is_active)
  VALUES (v_org_id, 1, extensions.gen_random_bytes(32), true);

  INSERT INTO public.branches (organization_id, name, code, timezone)
  VALUES (v_org_id, trim(p_first_branch_name), upper(trim(p_first_branch_code)), p_timezone)
  RETURNING id INTO v_branch_id;

  SELECT id INTO v_owner_role_id FROM public.roles WHERE code = 'org_owner';

  INSERT INTO public.user_role_assignments (
    user_id, organization_id, branch_id, role_id, status, assigned_by
  ) VALUES (
    v_user_id, v_org_id, NULL, v_owner_role_id, 'active', v_user_id
  );

  INSERT INTO public.audit_logs (
    organization_id, branch_id, actor_user_id, action, target_type, target_id, metadata
  ) VALUES (
    v_org_id, v_branch_id, v_user_id, 'organization.created', 'organization', v_org_id,
    jsonb_build_object('slug', lower(trim(p_slug)), 'first_branch_id', v_branch_id)
  );

  RETURN jsonb_build_object(
    'organization_id', v_org_id,
    'branch_id', v_branch_id,
    'role_code', 'org_owner'
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.invite_user_to_organization(
  p_org_id uuid,
  p_invited_email text,
  p_role_code text,
  p_branch_id uuid DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_role public.roles%ROWTYPE;
  v_caller_rank integer;
  v_raw_token text := encode(extensions.gen_random_bytes(24), 'hex');
  v_invite_id uuid;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  IF NOT authz.has_permission(p_org_id, p_branch_id, 'role.assign') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing role.assign permission in target scope' USING ERRCODE = '42501';
  END IF;

  IF NULLIF(trim(p_invited_email), '') IS NULL OR position('@' IN p_invited_email) = 0 THEN
    RAISE EXCEPTION 'VALIDATION_ERROR: Valid email is required' USING ERRCODE = '22023';
  END IF;

  SELECT * INTO v_role FROM public.roles WHERE code = p_role_code;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'VALIDATION_ERROR: Unknown role code %', p_role_code USING ERRCODE = '22023';
  END IF;

  IF v_role.scope_level = 'organization' AND p_branch_id IS NOT NULL THEN
    RAISE EXCEPTION 'VALIDATION_ERROR: Organization role % cannot be bound to a branch', p_role_code
      USING ERRCODE = '22023';
  END IF;

  IF v_role.scope_level = 'branch' AND p_branch_id IS NULL THEN
    RAISE EXCEPTION 'VALIDATION_ERROR: Branch role % requires a valid branch_id', p_role_code
      USING ERRCODE = '22023';
  END IF;

  v_caller_rank := authz.user_max_role_rank(p_org_id, p_branch_id);
  IF v_caller_rank < 100 AND v_role.rank >= v_caller_rank THEN
    RAISE EXCEPTION 'FORBIDDEN: Cannot invite to a role equal to or higher than your own rank'
      USING ERRCODE = '42501';
  END IF;

  INSERT INTO public.organization_invitations (
    organization_id, branch_id, role_id, invited_email, token_hash, invited_by
  ) VALUES (
    p_org_id,
    p_branch_id,
    v_role.id,
    lower(trim(p_invited_email)),
    encode(extensions.digest(convert_to(v_raw_token, 'UTF8'), 'sha256'), 'hex'),
    v_actor_id
  )
  RETURNING id INTO v_invite_id;

  INSERT INTO public.audit_logs (
    organization_id, branch_id, actor_user_id, action, target_type, target_id, metadata
  ) VALUES (
    p_org_id, p_branch_id, v_actor_id, 'role.invited', 'organization_invitation', v_invite_id,
    jsonb_build_object('role_code', p_role_code, 'invited_email', lower(trim(p_invited_email)))
  );

  RETURN jsonb_build_object('invitation_id', v_invite_id, 'token', v_raw_token);
END;
$$;

CREATE OR REPLACE FUNCTION public.accept_organization_invitation(
  p_token text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, pg_temp
AS $$
DECLARE
  v_user_id uuid := (SELECT auth.uid());
  v_user_email text;
  v_hash text;
  v_invite public.organization_invitations%ROWTYPE;
  v_assignment_id uuid;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  SELECT email INTO v_user_email FROM auth.users WHERE id = v_user_id;
  v_hash := encode(extensions.digest(convert_to(trim(COALESCE(p_token, '')), 'UTF8'), 'sha256'), 'hex');

  SELECT * INTO v_invite
  FROM public.organization_invitations
  WHERE token_hash = v_hash
  FOR UPDATE;

  IF NOT FOUND OR v_invite.status <> 'pending' OR v_invite.expires_at <= now() THEN
    RAISE EXCEPTION 'INVALID_INVITATION: Invitation is invalid or expired' USING ERRCODE = '22023';
  END IF;

  IF lower(COALESCE(v_user_email, '')) <> lower(v_invite.invited_email) THEN
    RAISE EXCEPTION 'FORBIDDEN: Signed-in email does not match invitation' USING ERRCODE = '42501';
  END IF;

  UPDATE public.organization_invitations
  SET status = 'accepted', accepted_by = v_user_id, accepted_at = now()
  WHERE id = v_invite.id;

  INSERT INTO public.user_role_assignments (
    user_id, organization_id, branch_id, role_id, status, assigned_by
  ) VALUES (
    v_user_id, v_invite.organization_id, v_invite.branch_id, v_invite.role_id, 'active', v_invite.invited_by
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_assignment_id;

  INSERT INTO public.audit_logs (
    organization_id, branch_id, actor_user_id, action, target_type, target_id, metadata
  ) VALUES (
    v_invite.organization_id, v_invite.branch_id, v_user_id, 'role.invitation_accepted',
    'organization_invitation', v_invite.id,
    jsonb_build_object('assignment_id', v_assignment_id)
  );

  RETURN jsonb_build_object(
    'organization_id', v_invite.organization_id,
    'branch_id', v_invite.branch_id,
    'assignment_id', v_assignment_id
  );
END;
$$;

-- Existing-participant role assignment only (C1 hardened: cannot pull external users into org without consent).
CREATE OR REPLACE FUNCTION public.assign_user_role(
  p_org_id uuid,
  p_target_user_id uuid,
  p_role_code text,
  p_branch_id uuid DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_role public.roles%ROWTYPE;
  v_caller_rank integer;
  v_assignment_id uuid;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  PERFORM pg_advisory_xact_lock(hashtextextended('role:' || p_org_id::text, 0));

  IF NOT authz.has_permission(p_org_id, p_branch_id, 'role.assign') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing role.assign permission in target scope'
      USING ERRCODE = '42501';
  END IF;

  IF NOT authz.is_user_org_participant(p_org_id, p_target_user_id) THEN
    RAISE EXCEPTION 'CONSENT_REQUIRED: Target user is not a member or accepted participant of this organization; send an invitation first'
      USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_role FROM public.roles WHERE code = p_role_code;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'VALIDATION_ERROR: Unknown role code %', p_role_code
      USING ERRCODE = '22023';
  END IF;

  IF v_role.scope_level = 'organization' AND p_branch_id IS NOT NULL THEN
    RAISE EXCEPTION 'VALIDATION_ERROR: Organization role % cannot be bound to a branch', p_role_code
      USING ERRCODE = '22023';
  END IF;

  IF v_role.scope_level = 'branch' AND p_branch_id IS NULL THEN
    RAISE EXCEPTION 'VALIDATION_ERROR: Branch role % requires a valid branch_id', p_role_code
      USING ERRCODE = '22023';
  END IF;

  v_caller_rank := authz.user_max_role_rank(p_org_id, p_branch_id);

  IF v_caller_rank < 100 AND v_role.rank >= v_caller_rank THEN
    RAISE EXCEPTION 'FORBIDDEN: Cannot assign a role equal to or higher than your own rank'
      USING ERRCODE = '42501';
  END IF;

  IF p_target_user_id = v_actor_id AND v_caller_rank < 100 AND v_role.rank > v_caller_rank THEN
    RAISE EXCEPTION 'FORBIDDEN: Self-escalation is not permitted'
      USING ERRCODE = '42501';
  END IF;

  INSERT INTO public.user_role_assignments (
    user_id, organization_id, branch_id, role_id, status, assigned_by
  ) VALUES (
    p_target_user_id, p_org_id, p_branch_id, v_role.id, 'active', v_actor_id
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_assignment_id;

  IF v_assignment_id IS NULL THEN
    SELECT id INTO v_assignment_id
    FROM public.user_role_assignments
    WHERE user_id = p_target_user_id
      AND organization_id = p_org_id
      AND COALESCE(branch_id, '00000000-0000-0000-0000-000000000000'::uuid)
        = COALESCE(p_branch_id, '00000000-0000-0000-0000-000000000000'::uuid)
      AND role_id = v_role.id
      AND status = 'active'
    LIMIT 1;
  ELSE
    INSERT INTO public.audit_logs (
      organization_id, branch_id, actor_user_id, action, target_type, target_id, metadata
    ) VALUES (
      p_org_id, p_branch_id, v_actor_id, 'role.assigned', 'user_role_assignment', v_assignment_id,
      jsonb_build_object('target_user_id', p_target_user_id, 'role_code', p_role_code)
    );
  END IF;

  RETURN v_assignment_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.revoke_user_role(
  p_org_id uuid,
  p_assignment_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_assignment public.user_role_assignments%ROWTYPE;
  v_target_role public.roles%ROWTYPE;
  v_caller_rank integer;
  v_active_owner_count integer;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  -- Canonical lock per organization eliminates concurrent owner-revoke deadlocks (L5)
  PERFORM pg_advisory_xact_lock(hashtextextended('role:' || p_org_id::text, 0));

  SELECT * INTO v_assignment
  FROM public.user_role_assignments
  WHERE id = p_assignment_id AND organization_id = p_org_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: Role assignment not found' USING ERRCODE = 'P0002';
  END IF;

  IF v_assignment.status = 'revoked' THEN
    RETURN;
  END IF;

  IF NOT authz.has_permission(p_org_id, v_assignment.branch_id, 'role.assign') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing role.assign permission in target scope'
      USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_target_role FROM public.roles WHERE id = v_assignment.role_id;
  v_caller_rank := authz.user_max_role_rank(p_org_id, v_assignment.branch_id);

  IF v_caller_rank < 100 AND v_target_role.rank >= v_caller_rank THEN
    RAISE EXCEPTION 'FORBIDDEN: Cannot revoke a role equal to or higher than your own rank'
      USING ERRCODE = '42501';
  END IF;

  IF v_target_role.code = 'org_owner' THEN
    SELECT COUNT(*) INTO v_active_owner_count
    FROM public.user_role_assignments
    WHERE organization_id = p_org_id
      AND role_id = v_target_role.id
      AND status = 'active';

    IF v_active_owner_count <= 1 THEN
      RAISE EXCEPTION 'LAST_ORG_OWNER: Cannot revoke the last active organization owner'
        USING ERRCODE = '22023';
    END IF;
  END IF;

  UPDATE public.user_role_assignments
  SET status = 'revoked', revoked_at = now()
  WHERE id = p_assignment_id;

  INSERT INTO public.audit_logs (
    organization_id, branch_id, actor_user_id, action, target_type, target_id, metadata
  ) VALUES (
    p_org_id, v_assignment.branch_id, v_actor_id, 'role.revoked', 'user_role_assignment', p_assignment_id,
    jsonb_build_object('target_user_id', v_assignment.user_id, 'role_code', v_target_role.code)
  );
END;
$$;

-- Overwritten in migration 000200 to also return linked member contexts.
CREATE OR REPLACE FUNCTION public.get_my_workspaces()
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'organization_id', o.id,
        'organization_name', o.name,
        'branch_id', b.id,
        'branch_name', b.name,
        'role_code', r.code,
        'role_display_name', r.display_name,
        'role_rank', r.rank,
        'member_id', NULL,
        'permissions', (
          SELECT COALESCE(jsonb_agg(rp.permission_code ORDER BY rp.permission_code), '[]'::jsonb)
          FROM public.role_permissions rp
          WHERE rp.role_id = r.id
        )
      )
      ORDER BY r.rank DESC, o.name ASC, b.name ASC NULLS FIRST
    ),
    '[]'::jsonb
  )
  FROM public.user_role_assignments ura
  JOIN public.organizations o ON o.id = ura.organization_id
  JOIN public.roles r ON r.id = ura.role_id
  LEFT JOIN public.branches b ON b.id = ura.branch_id
  WHERE ura.user_id = (SELECT auth.uid())
    AND ura.status = 'active'
    AND o.status = 'active';
$$;

REVOKE ALL ON FUNCTION public.create_organization_with_owner(text, text, text, text, text, text, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.invite_user_to_organization(uuid, text, text, uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.accept_organization_invitation(text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.assign_user_role(uuid, uuid, text, uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.revoke_user_role(uuid, uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.get_my_workspaces() FROM PUBLIC, anon;

GRANT EXECUTE ON FUNCTION public.create_organization_with_owner(text, text, text, text, text, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.invite_user_to_organization(uuid, text, text, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.accept_organization_invitation(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.assign_user_role(uuid, uuid, text, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.revoke_user_role(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_my_workspaces() TO authenticated;

REVOKE TRUNCATE, TRIGGER, REFERENCES ON ALL TABLES IN SCHEMA public FROM anon, authenticated;
