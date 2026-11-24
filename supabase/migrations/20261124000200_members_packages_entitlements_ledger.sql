-- RITMA Migration 000200: Members, Class Types, Packages, Entitlements & Credit Ledger
-- Fixes H2 (member column guard + consent claim), H4 (atomic credit_adjustments), M5 (branch scoping), M6 (catalog org-only + soft-delete), M8 (freeze credit grants), M9/M10.

-- ---------------------------------------------------------------------------
-- Members, Claim Invites & Class Types
-- ---------------------------------------------------------------------------

CREATE TABLE public.members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  home_branch_id uuid NOT NULL,
  member_code text NOT NULL,
  full_name text NOT NULL CHECK (char_length(trim(full_name)) BETWEEN 2 AND 120),
  email text,
  phone text,
  emergency_contact_name text,
  emergency_contact_phone text,
  status text NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'frozen', 'suspended', 'archived')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (organization_id, home_branch_id)
    REFERENCES public.branches(organization_id, id) ON DELETE RESTRICT,
  UNIQUE (organization_id, id),
  UNIQUE (organization_id, member_code)
);

CREATE UNIQUE INDEX idx_members_org_user_unique
  ON public.members (organization_id, user_id)
  WHERE user_id IS NOT NULL;

CREATE INDEX idx_members_org_status
  ON public.members (organization_id, home_branch_id, status, full_name);

CREATE TRIGGER trg_members_updated_at
  BEFORE UPDATE ON public.members
  FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();

-- Prevent direct client tampering with members.user_id, organization_id, or status (H2).
CREATE OR REPLACE FUNCTION private.guard_member_sensitive_columns()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, public, pg_temp
AS $$
BEGIN
  IF current_setting('ritma.allow_member_sensitive_mutation', true) IS DISTINCT FROM 'on' THEN
    IF TG_OP = 'INSERT' THEN
      NEW.user_id := NULL;
      NEW.status := 'active';
    ELSIF TG_OP = 'UPDATE' THEN
      IF NEW.user_id IS DISTINCT FROM OLD.user_id THEN
        RAISE EXCEPTION 'FORBIDDEN: members.user_id can only be linked via member claim RPC'
          USING ERRCODE = '42501';
      END IF;
      IF NEW.organization_id IS DISTINCT FROM OLD.organization_id THEN
        RAISE EXCEPTION 'FORBIDDEN: members.organization_id is immutable'
          USING ERRCODE = '42501';
      END IF;
      IF NEW.status IS DISTINCT FROM OLD.status THEN
        RAISE EXCEPTION 'FORBIDDEN: members.status can only be modified via member status RPC'
          USING ERRCODE = '42501';
      END IF;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_members_sensitive_guard
  BEFORE INSERT OR UPDATE ON public.members
  FOR EACH ROW EXECUTE FUNCTION private.guard_member_sensitive_columns();

CREATE TABLE public.member_claim_invitations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL,
  member_id uuid NOT NULL,
  invited_email text NOT NULL,
  token_hash text NOT NULL UNIQUE,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'claimed', 'revoked', 'expired')),
  invited_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  expires_at timestamptz NOT NULL DEFAULT (now() + interval '14 days'),
  claimed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (organization_id, member_id)
    REFERENCES public.members(organization_id, id) ON DELETE CASCADE
);

CREATE TABLE public.class_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  name text NOT NULL CHECK (char_length(trim(name)) BETWEEN 2 AND 80),
  color_token text NOT NULL DEFAULT 'sage',
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (organization_id, id),
  UNIQUE (organization_id, name)
);

CREATE TRIGGER trg_class_types_updated_at
  BEFORE UPDATE ON public.class_types
  FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();

-- ---------------------------------------------------------------------------
-- Packages & Declarative Entitlement Rules (Normalized Join Tables - F4)
-- ---------------------------------------------------------------------------

CREATE TABLE public.packages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  name text NOT NULL CHECK (char_length(trim(name)) BETWEEN 2 AND 120),
  description text NOT NULL DEFAULT '',
  package_type text NOT NULL
    CHECK (package_type IN ('gym_membership', 'class_pack', 'pt_pack', 'hybrid')),
  price_minor bigint NOT NULL DEFAULT 0 CHECK (price_minor >= 0),
  currency_code text NOT NULL DEFAULT 'USD' CHECK (char_length(currency_code) = 3),
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (organization_id, id)
);

CREATE INDEX idx_packages_org_active ON public.packages (organization_id, is_active);

CREATE TRIGGER trg_packages_updated_at
  BEFORE UPDATE ON public.packages
  FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();

CREATE TABLE public.package_entitlement_rules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL,
  package_id uuid NOT NULL,
  entitlement_kind text NOT NULL
    CHECK (entitlement_kind IN ('facility_access', 'class_credit', 'pt_credit', 'unlimited_class')),
  duration_days integer CHECK (duration_days IS NULL OR duration_days > 0),
  credit_quantity integer CHECK (credit_quantity IS NULL OR credit_quantity > 0),
  branch_access_scope text NOT NULL DEFAULT 'single_branch'
    CHECK (branch_access_scope IN ('single_branch', 'selected_branches', 'all_branches')),
  class_scope text NOT NULL DEFAULT 'all_classes'
    CHECK (class_scope IN ('all_classes', 'selected_classes')),
  created_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (organization_id, package_id)
    REFERENCES public.packages(organization_id, id) ON DELETE CASCADE,
  UNIQUE (organization_id, id),
  CHECK (
    (entitlement_kind IN ('class_credit', 'pt_credit') AND credit_quantity IS NOT NULL)
    OR (entitlement_kind IN ('facility_access', 'unlimited_class') AND duration_days IS NOT NULL)
  )
);

CREATE TABLE public.package_rule_branches (
  organization_id uuid NOT NULL,
  rule_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  PRIMARY KEY (rule_id, branch_id),
  FOREIGN KEY (organization_id, rule_id)
    REFERENCES public.package_entitlement_rules(organization_id, id) ON DELETE CASCADE,
  FOREIGN KEY (organization_id, branch_id)
    REFERENCES public.branches(organization_id, id) ON DELETE CASCADE
);

CREATE TABLE public.package_rule_class_types (
  organization_id uuid NOT NULL,
  rule_id uuid NOT NULL,
  class_type_id uuid NOT NULL,
  PRIMARY KEY (rule_id, class_type_id),
  FOREIGN KEY (organization_id, rule_id)
    REFERENCES public.package_entitlement_rules(organization_id, id) ON DELETE CASCADE,
  FOREIGN KEY (organization_id, class_type_id)
    REFERENCES public.class_types(organization_id, id) ON DELETE RESTRICT
);

-- ---------------------------------------------------------------------------
-- Subscriptions, Materialized Entitlements & Payment Records
-- ---------------------------------------------------------------------------

CREATE TABLE public.member_subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL,
  member_id uuid NOT NULL,
  package_id uuid NOT NULL,
  assigned_branch_id uuid NOT NULL,
  status text NOT NULL DEFAULT 'active'
    CHECK (status IN ('pending', 'active', 'frozen', 'expired', 'cancelled')),
  starts_at timestamptz NOT NULL,
  ends_at timestamptz,
  frozen_at timestamptz,
  total_frozen_seconds integer NOT NULL DEFAULT 0 CHECK (total_frozen_seconds >= 0),
  cancelled_at timestamptz,
  idempotency_key text NOT NULL,
  created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (organization_id, member_id)
    REFERENCES public.members(organization_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (organization_id, package_id)
    REFERENCES public.packages(organization_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (organization_id, assigned_branch_id)
    REFERENCES public.branches(organization_id, id) ON DELETE RESTRICT,
  UNIQUE (organization_id, id),
  UNIQUE (organization_id, idempotency_key)
);

CREATE INDEX idx_member_subs_org_member
  ON public.member_subscriptions (organization_id, member_id, status);

CREATE TRIGGER trg_member_subs_updated_at
  BEFORE UPDATE ON public.member_subscriptions
  FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();

CREATE TABLE public.member_entitlements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL,
  member_id uuid NOT NULL,
  subscription_id uuid NOT NULL,
  entitlement_kind text NOT NULL
    CHECK (entitlement_kind IN ('facility_access', 'unlimited_class')),
  branch_access_scope text NOT NULL
    CHECK (branch_access_scope IN ('single_branch', 'selected_branches', 'all_branches')),
  class_scope text NOT NULL DEFAULT 'all_classes'
    CHECK (class_scope IN ('all_classes', 'selected_classes')),
  valid_from timestamptz NOT NULL,
  valid_until timestamptz NOT NULL,
  status text NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'frozen', 'expired', 'revoked')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (organization_id, member_id)
    REFERENCES public.members(organization_id, id) ON DELETE CASCADE,
  FOREIGN KEY (organization_id, subscription_id)
    REFERENCES public.member_subscriptions(organization_id, id) ON DELETE CASCADE,
  UNIQUE (organization_id, id),
  CHECK (valid_until > valid_from)
);

CREATE INDEX idx_member_entitlements_lookup
  ON public.member_entitlements (organization_id, member_id, entitlement_kind, status, valid_until);

CREATE TRIGGER trg_member_entitlements_updated_at
  BEFORE UPDATE ON public.member_entitlements
  FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();

CREATE TABLE public.member_entitlement_branches (
  organization_id uuid NOT NULL,
  entitlement_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  PRIMARY KEY (entitlement_id, branch_id),
  FOREIGN KEY (organization_id, entitlement_id)
    REFERENCES public.member_entitlements(organization_id, id) ON DELETE CASCADE,
  FOREIGN KEY (organization_id, branch_id)
    REFERENCES public.branches(organization_id, id) ON DELETE CASCADE
);

CREATE TABLE public.member_entitlement_class_types (
  organization_id uuid NOT NULL,
  entitlement_id uuid NOT NULL,
  class_type_id uuid NOT NULL,
  PRIMARY KEY (entitlement_id, class_type_id),
  FOREIGN KEY (organization_id, entitlement_id)
    REFERENCES public.member_entitlements(organization_id, id) ON DELETE CASCADE,
  FOREIGN KEY (organization_id, class_type_id)
    REFERENCES public.class_types(organization_id, id) ON DELETE RESTRICT
);

CREATE TABLE public.payment_records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  member_id uuid NOT NULL,
  subscription_id uuid NOT NULL,
  amount_minor bigint NOT NULL CHECK (amount_minor >= 0),
  currency_code text NOT NULL CHECK (char_length(currency_code) = 3),
  method text NOT NULL
    CHECK (method IN ('cash', 'bank_transfer', 'card_terminal', 'gateway')),
  status text NOT NULL DEFAULT 'paid'
    CHECK (status IN ('pending', 'paid', 'refunded', 'void')),
  external_reference text,
  idempotency_key text NOT NULL,
  recorded_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  paid_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (organization_id, branch_id)
    REFERENCES public.branches(organization_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (organization_id, member_id)
    REFERENCES public.members(organization_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (organization_id, subscription_id)
    REFERENCES public.member_subscriptions(organization_id, id) ON DELETE RESTRICT,
  UNIQUE (organization_id, idempotency_key)
);

CREATE INDEX idx_payment_records_org_branch_paid
  ON public.payment_records (organization_id, branch_id, paid_at DESC);

-- ---------------------------------------------------------------------------
-- Credit Grants, Adjustments & Append-Only Credit Ledger (F5, H4, M8)
-- ---------------------------------------------------------------------------

CREATE TABLE public.credit_grants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL,
  member_id uuid NOT NULL,
  subscription_id uuid,
  credit_type text NOT NULL CHECK (credit_type IN ('class_credit', 'pt_credit')),
  branch_access_scope text NOT NULL DEFAULT 'all_branches'
    CHECK (branch_access_scope IN ('single_branch', 'selected_branches', 'all_branches')),
  class_scope text NOT NULL DEFAULT 'all_classes'
    CHECK (class_scope IN ('all_classes', 'selected_classes')),
  initial_amount integer NOT NULL CHECK (initial_amount > 0),
  remaining_amount integer NOT NULL CHECK (remaining_amount >= 0 AND remaining_amount <= initial_amount),
  expires_at timestamptz,
  status text NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'frozen', 'depleted', 'expired', 'revoked')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (organization_id, member_id)
    REFERENCES public.members(organization_id, id) ON DELETE CASCADE,
  FOREIGN KEY (organization_id, subscription_id)
    REFERENCES public.member_subscriptions(organization_id, id) ON DELETE SET NULL (subscription_id),
  UNIQUE (organization_id, id)
);

CREATE INDEX idx_credit_grants_fifo
  ON public.credit_grants (organization_id, member_id, credit_type, status, expires_at, created_at);

CREATE TRIGGER trg_credit_grants_updated_at
  BEFORE UPDATE ON public.credit_grants
  FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();

CREATE TABLE public.credit_grant_branches (
  organization_id uuid NOT NULL,
  grant_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  PRIMARY KEY (grant_id, branch_id),
  FOREIGN KEY (organization_id, grant_id)
    REFERENCES public.credit_grants(organization_id, id) ON DELETE CASCADE,
  FOREIGN KEY (organization_id, branch_id)
    REFERENCES public.branches(organization_id, id) ON DELETE CASCADE
);

CREATE TABLE public.credit_grant_class_types (
  organization_id uuid NOT NULL,
  grant_id uuid NOT NULL,
  class_type_id uuid NOT NULL,
  PRIMARY KEY (grant_id, class_type_id),
  FOREIGN KEY (organization_id, grant_id)
    REFERENCES public.credit_grants(organization_id, id) ON DELETE CASCADE,
  FOREIGN KEY (organization_id, class_type_id)
    REFERENCES public.class_types(organization_id, id) ON DELETE RESTRICT
);

-- Dedicated idempotency table for manual credit adjustments (H4).
CREATE TABLE public.credit_adjustments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL,
  member_id uuid NOT NULL,
  credit_type text NOT NULL CHECK (credit_type IN ('class_credit', 'pt_credit')),
  delta integer NOT NULL CHECK (delta <> 0),
  reason text NOT NULL,
  idempotency_key text NOT NULL,
  actor_user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (organization_id, member_id)
    REFERENCES public.members(organization_id, id) ON DELETE CASCADE,
  UNIQUE (organization_id, idempotency_key)
);

CREATE TABLE public.credit_ledger_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
  member_id uuid NOT NULL,
  grant_id uuid NOT NULL,
  credit_type text NOT NULL CHECK (credit_type IN ('class_credit', 'pt_credit')),
  entry_type text NOT NULL
    CHECK (entry_type IN ('grant', 'consume', 'refund', 'expire', 'adjustment')),
  delta integer NOT NULL CHECK (delta <> 0),
  reference_type text NOT NULL,
  reference_id uuid NOT NULL,
  idempotency_key text NOT NULL,
  reason text,
  -- Plain uuid (no FK to auth.users) preserves immutable ledger history if a staff user is deleted (M9).
  actor_user_id uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (organization_id, member_id)
    REFERENCES public.members(organization_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (organization_id, grant_id)
    REFERENCES public.credit_grants(organization_id, id) ON DELETE RESTRICT,
  UNIQUE (organization_id, idempotency_key)
);

CREATE UNIQUE INDEX idx_credit_ledger_refund_once
  ON public.credit_ledger_entries (organization_id, reference_type, reference_id, grant_id)
  WHERE entry_type = 'refund';

CREATE INDEX idx_credit_ledger_member_created
  ON public.credit_ledger_entries (organization_id, member_id, created_at DESC);

CREATE TRIGGER trg_credit_ledger_immutable
  BEFORE UPDATE OR DELETE ON public.credit_ledger_entries
  FOR EACH ROW EXECUTE FUNCTION private.prevent_row_mutation();

CREATE TRIGGER trg_credit_ledger_no_truncate
  BEFORE TRUNCATE ON public.credit_ledger_entries
  FOR EACH STATEMENT EXECUTE FUNCTION private.prevent_row_mutation();

-- ---------------------------------------------------------------------------
-- Update authz helpers & get_my_workspaces now that public.members exists
-- ---------------------------------------------------------------------------

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
  )
  OR EXISTS (
    SELECT 1
    FROM public.members m
    WHERE m.user_id = (SELECT auth.uid())
      AND m.organization_id = p_org_id
      AND m.status IN ('active', 'frozen')
  );
$$;

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
  )
  OR EXISTS (
    SELECT 1
    FROM public.members m
    WHERE m.user_id = p_target_user_id
      AND m.organization_id = p_org_id
      AND m.status IN ('active', 'frozen')
  );
$$;

CREATE OR REPLACE FUNCTION authz.is_self_member(
  p_org_id uuid,
  p_member_id uuid
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.members m
    WHERE m.id = p_member_id
      AND m.organization_id = p_org_id
      AND m.user_id = (SELECT auth.uid())
  );
$$;

REVOKE ALL ON FUNCTION authz.is_self_member(uuid, uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION authz.is_self_member(uuid, uuid) TO authenticated;

CREATE OR REPLACE FUNCTION public.get_my_workspaces()
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
  WITH staff_contexts AS (
    SELECT
      o.id AS organization_id,
      o.name AS organization_name,
      b.id AS branch_id,
      b.name AS branch_name,
      r.code AS role_code,
      r.display_name AS role_display_name,
      r.rank AS role_rank,
      NULL::uuid AS member_id,
      (
        SELECT COALESCE(jsonb_agg(rp.permission_code ORDER BY rp.permission_code), '[]'::jsonb)
        FROM public.role_permissions rp
        WHERE rp.role_id = r.id
      ) AS permissions
    FROM public.user_role_assignments ura
    JOIN public.organizations o ON o.id = ura.organization_id
    JOIN public.roles r ON r.id = ura.role_id
    LEFT JOIN public.branches b ON b.id = ura.branch_id
    WHERE ura.user_id = (SELECT auth.uid())
      AND ura.status = 'active'
      AND o.status = 'active'
  ),
  member_contexts AS (
    SELECT
      o.id AS organization_id,
      o.name AS organization_name,
      b.id AS branch_id,
      b.name AS branch_name,
      'member'::text AS role_code,
      'Fitness Member'::text AS role_display_name,
      10 AS role_rank,
      m.id AS member_id,
      '["member.self"]'::jsonb AS permissions
    FROM public.members m
    JOIN public.organizations o ON o.id = m.organization_id
    JOIN public.branches b ON b.id = m.home_branch_id
    WHERE m.user_id = (SELECT auth.uid())
      AND m.status IN ('active', 'frozen')
      AND o.status = 'active'
  ),
  combined AS (
    SELECT * FROM staff_contexts
    UNION ALL
    SELECT * FROM member_contexts
  )
  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'organization_id', c.organization_id,
        'organization_name', c.organization_name,
        'branch_id', c.branch_id,
        'branch_name', c.branch_name,
        'role_code', c.role_code,
        'role_display_name', c.role_display_name,
        'role_rank', c.role_rank,
        'member_id', c.member_id,
        'permissions', c.permissions
      )
      ORDER BY c.role_rank DESC, c.organization_name ASC, c.branch_name ASC NULLS FIRST
    ),
    '[]'::jsonb
  )
  FROM combined c;
$$;

-- ---------------------------------------------------------------------------
-- Default-Deny Row Level Security (Branch-Scoped - H2, M5, M6)
-- ---------------------------------------------------------------------------

ALTER TABLE public.members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.members FORCE ROW LEVEL SECURITY;
ALTER TABLE public.member_claim_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.member_claim_invitations FORCE ROW LEVEL SECURITY;
ALTER TABLE public.class_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.class_types FORCE ROW LEVEL SECURITY;
ALTER TABLE public.packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.packages FORCE ROW LEVEL SECURITY;
ALTER TABLE public.package_entitlement_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.package_entitlement_rules FORCE ROW LEVEL SECURITY;
ALTER TABLE public.package_rule_branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.package_rule_branches FORCE ROW LEVEL SECURITY;
ALTER TABLE public.package_rule_class_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.package_rule_class_types FORCE ROW LEVEL SECURITY;
ALTER TABLE public.member_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.member_subscriptions FORCE ROW LEVEL SECURITY;
ALTER TABLE public.member_entitlements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.member_entitlements FORCE ROW LEVEL SECURITY;
ALTER TABLE public.member_entitlement_branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.member_entitlement_branches FORCE ROW LEVEL SECURITY;
ALTER TABLE public.member_entitlement_class_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.member_entitlement_class_types FORCE ROW LEVEL SECURITY;
ALTER TABLE public.payment_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_records FORCE ROW LEVEL SECURITY;
ALTER TABLE public.credit_grants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_grants FORCE ROW LEVEL SECURITY;
ALTER TABLE public.credit_grant_branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_grant_branches FORCE ROW LEVEL SECURITY;
ALTER TABLE public.credit_grant_class_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_grant_class_types FORCE ROW LEVEL SECURITY;
ALTER TABLE public.credit_adjustments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_adjustments FORCE ROW LEVEL SECURITY;
ALTER TABLE public.credit_ledger_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_ledger_entries FORCE ROW LEVEL SECURITY;

-- Members strictly branch-scoped on home_branch_id (cross-branch check-in uses minimal lookup RPC)
CREATE POLICY members_select_branch_or_self ON public.members
  FOR SELECT TO authenticated
  USING (
    user_id = (SELECT auth.uid())
    OR authz.has_permission(organization_id, home_branch_id, 'member.read')
  );

CREATE POLICY members_insert_branch_staff ON public.members
  FOR INSERT TO authenticated
  WITH CHECK (authz.has_permission(organization_id, home_branch_id, 'member.write'));

CREATE POLICY members_update_branch_staff ON public.members
  FOR UPDATE TO authenticated
  USING (authz.has_permission(organization_id, home_branch_id, 'member.write'))
  WITH CHECK (authz.has_permission(organization_id, home_branch_id, 'member.write'));

CREATE POLICY member_claims_select ON public.member_claim_invitations
  FOR SELECT TO authenticated
  USING (
    lower(invited_email) = lower(COALESCE((SELECT auth.jwt() ->> 'email'), ''))
    OR authz.has_any_branch_permission(organization_id, 'member.write')
  );

-- Class types & Packages: org-wide catalog permissions only, no DELETE policies (M6)
CREATE POLICY class_types_select_participant ON public.class_types
  FOR SELECT TO authenticated
  USING (authz.is_org_participant(organization_id));

CREATE POLICY class_types_insert ON public.class_types
  FOR INSERT TO authenticated
  WITH CHECK (
    authz.has_permission(organization_id, NULL, 'package.manage')
    OR authz.has_permission(organization_id, NULL, 'schedule.manage')
  );

CREATE POLICY class_types_update ON public.class_types
  FOR UPDATE TO authenticated
  USING (
    authz.has_permission(organization_id, NULL, 'package.manage')
    OR authz.has_permission(organization_id, NULL, 'schedule.manage')
  )
  WITH CHECK (
    authz.has_permission(organization_id, NULL, 'package.manage')
    OR authz.has_permission(organization_id, NULL, 'schedule.manage')
  );

CREATE POLICY packages_select_participant ON public.packages
  FOR SELECT TO authenticated
  USING (authz.is_org_participant(organization_id));

CREATE POLICY packages_insert ON public.packages
  FOR INSERT TO authenticated
  WITH CHECK (authz.has_permission(organization_id, NULL, 'package.manage'));

CREATE POLICY packages_update ON public.packages
  FOR UPDATE TO authenticated
  USING (authz.has_permission(organization_id, NULL, 'package.manage'))
  WITH CHECK (authz.has_permission(organization_id, NULL, 'package.manage'));

CREATE POLICY pkg_rules_select_participant ON public.package_entitlement_rules
  FOR SELECT TO authenticated
  USING (authz.is_org_participant(organization_id));

CREATE POLICY pkg_rules_insert ON public.package_entitlement_rules
  FOR INSERT TO authenticated
  WITH CHECK (authz.has_permission(organization_id, NULL, 'package.manage'));

CREATE POLICY pkg_rules_update ON public.package_entitlement_rules
  FOR UPDATE TO authenticated
  USING (authz.has_permission(organization_id, NULL, 'package.manage'))
  WITH CHECK (authz.has_permission(organization_id, NULL, 'package.manage'));

CREATE POLICY pkg_rule_branches_select ON public.package_rule_branches
  FOR SELECT TO authenticated USING (authz.is_org_participant(organization_id));
CREATE POLICY pkg_rule_branches_insert ON public.package_rule_branches
  FOR INSERT TO authenticated WITH CHECK (authz.has_permission(organization_id, NULL, 'package.manage'));
CREATE POLICY pkg_rule_branches_delete ON public.package_rule_branches
  FOR DELETE TO authenticated USING (authz.has_permission(organization_id, NULL, 'package.manage'));

CREATE POLICY pkg_rule_classes_select ON public.package_rule_class_types
  FOR SELECT TO authenticated USING (authz.is_org_participant(organization_id));
CREATE POLICY pkg_rule_classes_insert ON public.package_rule_class_types
  FOR INSERT TO authenticated WITH CHECK (authz.has_permission(organization_id, NULL, 'package.manage'));
CREATE POLICY pkg_rule_classes_delete ON public.package_rule_class_types
  FOR DELETE TO authenticated USING (authz.has_permission(organization_id, NULL, 'package.manage'));

-- Subscriptions, Entitlements & Credit Ledger: branch-scoped via member home_branch_id or assigned_branch_id (M5)
CREATE POLICY member_subs_select ON public.member_subscriptions
  FOR SELECT TO authenticated
  USING (
    authz.is_self_member(organization_id, member_id)
    OR authz.has_permission(organization_id, assigned_branch_id, 'entitlement.read')
  );

CREATE POLICY member_entitlements_select ON public.member_entitlements
  FOR SELECT TO authenticated
  USING (
    authz.is_self_member(organization_id, member_id)
    OR EXISTS (
      SELECT 1 FROM public.members m
      WHERE m.id = member_entitlements.member_id
        AND m.organization_id = member_entitlements.organization_id
        AND authz.has_permission(m.organization_id, m.home_branch_id, 'entitlement.read')
    )
  );

CREATE POLICY member_entitlement_branches_select ON public.member_entitlement_branches
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.member_entitlements me
      JOIN public.members m ON m.id = me.member_id AND m.organization_id = me.organization_id
      WHERE me.id = entitlement_id
        AND me.organization_id = member_entitlement_branches.organization_id
        AND (
          authz.is_self_member(me.organization_id, me.member_id)
          OR authz.has_permission(m.organization_id, m.home_branch_id, 'entitlement.read')
        )
    )
  );

CREATE POLICY member_entitlement_classes_select ON public.member_entitlement_class_types
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.member_entitlements me
      JOIN public.members m ON m.id = me.member_id AND m.organization_id = me.organization_id
      WHERE me.id = entitlement_id
        AND me.organization_id = member_entitlement_class_types.organization_id
        AND (
          authz.is_self_member(me.organization_id, me.member_id)
          OR authz.has_permission(m.organization_id, m.home_branch_id, 'entitlement.read')
        )
    )
  );

CREATE POLICY credit_grants_select ON public.credit_grants
  FOR SELECT TO authenticated
  USING (
    authz.is_self_member(organization_id, member_id)
    OR EXISTS (
      SELECT 1 FROM public.members m
      WHERE m.id = credit_grants.member_id
        AND m.organization_id = credit_grants.organization_id
        AND authz.has_permission(m.organization_id, m.home_branch_id, 'entitlement.read')
    )
  );

CREATE POLICY credit_grant_branches_select ON public.credit_grant_branches
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.credit_grants cg
      JOIN public.members m ON m.id = cg.member_id AND m.organization_id = cg.organization_id
      WHERE cg.id = grant_id
        AND cg.organization_id = credit_grant_branches.organization_id
        AND (
          authz.is_self_member(cg.organization_id, cg.member_id)
          OR authz.has_permission(m.organization_id, m.home_branch_id, 'entitlement.read')
        )
    )
  );

CREATE POLICY credit_grant_classes_select ON public.credit_grant_class_types
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.credit_grants cg
      JOIN public.members m ON m.id = cg.member_id AND m.organization_id = cg.organization_id
      WHERE cg.id = grant_id
        AND cg.organization_id = credit_grant_class_types.organization_id
        AND (
          authz.is_self_member(cg.organization_id, cg.member_id)
          OR authz.has_permission(m.organization_id, m.home_branch_id, 'entitlement.read')
        )
    )
  );

CREATE POLICY credit_adjustments_select ON public.credit_adjustments
  FOR SELECT TO authenticated
  USING (
    authz.is_self_member(organization_id, member_id)
    OR EXISTS (
      SELECT 1 FROM public.members m
      WHERE m.id = credit_adjustments.member_id
        AND m.organization_id = credit_adjustments.organization_id
        AND authz.has_permission(m.organization_id, m.home_branch_id, 'entitlement.read')
    )
  );

CREATE POLICY credit_ledger_select ON public.credit_ledger_entries
  FOR SELECT TO authenticated
  USING (
    authz.is_self_member(organization_id, member_id)
    OR EXISTS (
      SELECT 1 FROM public.members m
      WHERE m.id = credit_ledger_entries.member_id
        AND m.organization_id = credit_ledger_entries.organization_id
        AND authz.has_permission(m.organization_id, m.home_branch_id, 'entitlement.read')
    )
  );

CREATE POLICY payment_records_select ON public.payment_records
  FOR SELECT TO authenticated
  USING (
    authz.is_self_member(organization_id, member_id)
    OR authz.has_permission(organization_id, branch_id, 'payment.read')
  );

-- ---------------------------------------------------------------------------
-- Transactional RPCs: Member Claim, Status, Package Assignment, Freeze, Adjustments
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.invite_member_claim(
  p_org_id uuid,
  p_member_id uuid,
  p_email text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_member public.members%ROWTYPE;
  v_raw_token text := encode(extensions.gen_random_bytes(24), 'hex');
  v_claim_id uuid;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_member FROM public.members WHERE id = p_member_id AND organization_id = p_org_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: Member not found' USING ERRCODE = 'P0002';
  END IF;

  IF NOT authz.has_permission(p_org_id, v_member.home_branch_id, 'member.write') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing member.write permission on home branch' USING ERRCODE = '42501';
  END IF;

  IF NULLIF(trim(p_email), '') IS NULL OR position('@' IN p_email) = 0 THEN
    RAISE EXCEPTION 'VALIDATION_ERROR: Valid email is required' USING ERRCODE = '22023';
  END IF;

  INSERT INTO public.member_claim_invitations (
    organization_id, member_id, invited_email, token_hash, invited_by
  ) VALUES (
    p_org_id, p_member_id, lower(trim(p_email)),
    encode(extensions.digest(convert_to(v_raw_token, 'UTF8'), 'sha256'), 'hex'),
    v_actor_id
  )
  RETURNING id INTO v_claim_id;

  RETURN jsonb_build_object('claim_invitation_id', v_claim_id, 'token', v_raw_token);
END;
$$;

CREATE OR REPLACE FUNCTION public.claim_member_profile(p_token text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, pg_temp
AS $$
DECLARE
  v_user_id uuid := (SELECT auth.uid());
  v_user_email text;
  v_hash text;
  v_claim public.member_claim_invitations%ROWTYPE;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  SELECT email INTO v_user_email FROM auth.users WHERE id = v_user_id;
  v_hash := encode(extensions.digest(convert_to(trim(COALESCE(p_token, '')), 'UTF8'), 'sha256'), 'hex');

  SELECT * INTO v_claim FROM public.member_claim_invitations WHERE token_hash = v_hash FOR UPDATE;
  IF NOT FOUND OR v_claim.status <> 'pending' OR v_claim.expires_at <= now() THEN
    RAISE EXCEPTION 'INVALID_CLAIM: Member claim invitation is invalid or expired' USING ERRCODE = '22023';
  END IF;

  IF lower(COALESCE(v_user_email, '')) <> lower(v_claim.invited_email) THEN
    RAISE EXCEPTION 'FORBIDDEN: Signed-in email does not match invitation' USING ERRCODE = '42501';
  END IF;

  UPDATE public.member_claim_invitations
  SET status = 'claimed', claimed_at = now()
  WHERE id = v_claim.id;

  PERFORM set_config('ritma.allow_member_sensitive_mutation', 'on', true);
  UPDATE public.members
  SET user_id = v_user_id
  WHERE id = v_claim.member_id AND organization_id = v_claim.organization_id AND user_id IS NULL;

  IF NOT FOUND THEN
    PERFORM set_config('ritma.allow_member_sensitive_mutation', 'off', true);
    RAISE EXCEPTION 'ALREADY_CLAIMED: Member profile is already linked to a user account' USING ERRCODE = '23505';
  END IF;
  PERFORM set_config('ritma.allow_member_sensitive_mutation', 'off', true);

  RETURN jsonb_build_object('organization_id', v_claim.organization_id, 'member_id', v_claim.member_id);
END;
$$;

CREATE OR REPLACE FUNCTION public.set_member_status(
  p_org_id uuid,
  p_member_id uuid,
  p_status text,
  p_reason text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_member public.members%ROWTYPE;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_member FROM public.members
  WHERE id = p_member_id AND organization_id = p_org_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: Member not found' USING ERRCODE = 'P0002';
  END IF;

  IF NOT authz.has_permission(p_org_id, v_member.home_branch_id, 'member.write') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing member.write permission' USING ERRCODE = '42501';
  END IF;

  PERFORM set_config('ritma.allow_member_sensitive_mutation', 'on', true);
  UPDATE public.members SET status = p_status WHERE id = p_member_id;
  PERFORM set_config('ritma.allow_member_sensitive_mutation', 'off', true);

  INSERT INTO public.audit_logs (
    organization_id, branch_id, actor_user_id, action, target_type, target_id, metadata
  ) VALUES (
    p_org_id, v_member.home_branch_id, v_actor_id, 'member.status_changed', 'member', p_member_id,
    jsonb_build_object('from', v_member.status, 'to', p_status, 'reason', p_reason)
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.update_my_member_contact(
  p_org_id uuid,
  p_phone text DEFAULT NULL,
  p_emergency_contact_name text DEFAULT NULL,
  p_emergency_contact_phone text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_user_id uuid := (SELECT auth.uid());
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  UPDATE public.members
  SET
    phone = COALESCE(p_phone, phone),
    emergency_contact_name = COALESCE(p_emergency_contact_name, emergency_contact_name),
    emergency_contact_phone = COALESCE(p_emergency_contact_phone, emergency_contact_phone)
  WHERE organization_id = p_org_id
    AND user_id = v_user_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: Member profile not found for user' USING ERRCODE = 'P0002';
  END IF;
END;
$$;

-- Minimal cross-branch front-desk member lookup for check-in without leaking full org PII (M5).
CREATE OR REPLACE FUNCTION public.lookup_member_for_checkin(
  p_org_id uuid,
  p_branch_id uuid,
  p_query text
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_q text := '%' || replace(replace(replace(trim(COALESCE(p_query, '')), '\', '\\'), '%', '\%'), '_', '\_') || '%';
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  IF NOT authz.has_permission(p_org_id, p_branch_id, 'checkin.perform') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing checkin.perform permission' USING ERRCODE = '42501';
  END IF;

  IF length(trim(COALESCE(p_query, ''))) < 2 THEN
    RETURN '[]'::jsonb;
  END IF;

  RETURN (
    SELECT COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'id', m.id,
          'member_code', m.member_code,
          'full_name', m.full_name,
          'home_branch_id', m.home_branch_id,
          'status', m.status
        )
        ORDER BY m.full_name ASC
      ),
      '[]'::jsonb
    )
    FROM (
      SELECT m.id, m.member_code, m.full_name, m.home_branch_id, m.status
      FROM public.members m
      WHERE m.organization_id = p_org_id
        AND m.status <> 'archived'
        AND (m.full_name ILIKE v_q ESCAPE '\' OR m.member_code ILIKE v_q ESCAPE '\')
      ORDER BY m.full_name ASC
      LIMIT 20
    ) m
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.assign_package_to_member(
  p_org_id uuid,
  p_branch_id uuid,
  p_member_id uuid,
  p_package_id uuid,
  p_starts_at timestamptz DEFAULT now(),
  p_payment_method text DEFAULT 'cash',
  p_idempotency_key text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_key text := 'assign:' || COALESCE(NULLIF(trim(p_idempotency_key), ''), gen_random_uuid()::text);
  v_existing_sub public.member_subscriptions%ROWTYPE;
  v_pkg public.packages%ROWTYPE;
  v_member public.members%ROWTYPE;
  v_starts_at timestamptz := COALESCE(p_starts_at, now());
  v_max_duration integer;
  v_ends_at timestamptz;
  v_sub_id uuid;
  v_rule RECORD;
  v_entitlement_id uuid;
  v_grant_id uuid;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  IF NOT authz.has_permission(p_org_id, p_branch_id, 'entitlement.assign')
     OR NOT authz.has_permission(p_org_id, p_branch_id, 'payment.record') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing entitlement.assign or payment.record permission'
      USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_existing_sub
  FROM public.member_subscriptions
  WHERE organization_id = p_org_id AND idempotency_key = v_key;

  IF FOUND THEN
    IF v_existing_sub.member_id <> p_member_id OR v_existing_sub.package_id <> p_package_id THEN
      RAISE EXCEPTION 'IDEMPOTENCY_KEY_REUSED: Key already used for different member or package'
        USING ERRCODE = '23505';
    END IF;
    RETURN jsonb_build_object(
      'subscription_id', v_existing_sub.id,
      'status', v_existing_sub.status,
      'idempotent_replay', true
    );
  END IF;

  SELECT * INTO v_member
  FROM public.members
  WHERE id = p_member_id AND organization_id = p_org_id;
  IF NOT FOUND OR v_member.status = 'archived' THEN
    RAISE EXCEPTION 'NOT_FOUND: Active member not found in organization' USING ERRCODE = 'P0002';
  END IF;

  SELECT * INTO v_pkg
  FROM public.packages
  WHERE id = p_package_id AND organization_id = p_org_id AND is_active = true;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: Active package not found in organization' USING ERRCODE = 'P0002';
  END IF;

  SELECT MAX(duration_days) INTO v_max_duration
  FROM public.package_entitlement_rules
  WHERE organization_id = p_org_id AND package_id = p_package_id;

  IF v_max_duration IS NOT NULL THEN
    v_ends_at := v_starts_at + make_interval(days => v_max_duration);
  END IF;

  INSERT INTO public.member_subscriptions (
    organization_id, member_id, package_id, assigned_branch_id,
    status, starts_at, ends_at, idempotency_key, created_by
  ) VALUES (
    p_org_id, p_member_id, p_package_id, p_branch_id,
    'active', v_starts_at, v_ends_at, v_key, v_actor_id
  )
  RETURNING id INTO v_sub_id;

  INSERT INTO public.payment_records (
    organization_id, branch_id, member_id, subscription_id,
    amount_minor, currency_code, method, status, idempotency_key, recorded_by
  ) VALUES (
    p_org_id, p_branch_id, p_member_id, v_sub_id,
    v_pkg.price_minor, v_pkg.currency_code, p_payment_method, 'paid', v_key, v_actor_id
  );

  FOR v_rule IN
    SELECT * FROM public.package_entitlement_rules
    WHERE organization_id = p_org_id AND package_id = p_package_id
  LOOP
    IF v_rule.entitlement_kind IN ('facility_access', 'unlimited_class') THEN
      INSERT INTO public.member_entitlements (
        organization_id, member_id, subscription_id, entitlement_kind,
        branch_access_scope, class_scope, valid_from, valid_until, status
      ) VALUES (
        p_org_id, p_member_id, v_sub_id, v_rule.entitlement_kind,
        v_rule.branch_access_scope, v_rule.class_scope,
        v_starts_at, v_starts_at + make_interval(days => v_rule.duration_days), 'active'
      )
      RETURNING id INTO v_entitlement_id;

      IF v_rule.branch_access_scope = 'single_branch' THEN
        INSERT INTO public.member_entitlement_branches (organization_id, entitlement_id, branch_id)
        VALUES (p_org_id, v_entitlement_id, p_branch_id) ON CONFLICT DO NOTHING;
      ELSIF v_rule.branch_access_scope = 'selected_branches' THEN
        INSERT INTO public.member_entitlement_branches (organization_id, entitlement_id, branch_id)
        SELECT p_org_id, v_entitlement_id, prb.branch_id
        FROM public.package_rule_branches prb
        WHERE prb.organization_id = p_org_id AND prb.rule_id = v_rule.id ON CONFLICT DO NOTHING;
      END IF;

      IF v_rule.class_scope = 'selected_classes' THEN
        INSERT INTO public.member_entitlement_class_types (organization_id, entitlement_id, class_type_id)
        SELECT p_org_id, v_entitlement_id, prc.class_type_id
        FROM public.package_rule_class_types prc
        WHERE prc.organization_id = p_org_id AND prc.rule_id = v_rule.id ON CONFLICT DO NOTHING;
      END IF;
    ELSE
      INSERT INTO public.credit_grants (
        organization_id, member_id, subscription_id, credit_type,
        branch_access_scope, class_scope, initial_amount, remaining_amount,
        expires_at, status
      ) VALUES (
        p_org_id, p_member_id, v_sub_id, v_rule.entitlement_kind,
        v_rule.branch_access_scope, v_rule.class_scope,
        v_rule.credit_quantity, v_rule.credit_quantity,
        CASE WHEN v_rule.duration_days IS NOT NULL
             THEN v_starts_at + make_interval(days => v_rule.duration_days)
             ELSE NULL END,
        'active'
      )
      RETURNING id INTO v_grant_id;

      IF v_rule.branch_access_scope = 'single_branch' THEN
        INSERT INTO public.credit_grant_branches (organization_id, grant_id, branch_id)
        VALUES (p_org_id, v_grant_id, p_branch_id) ON CONFLICT DO NOTHING;
      ELSIF v_rule.branch_access_scope = 'selected_branches' THEN
        INSERT INTO public.credit_grant_branches (organization_id, grant_id, branch_id)
        SELECT p_org_id, v_grant_id, prb.branch_id
        FROM public.package_rule_branches prb
        WHERE prb.organization_id = p_org_id AND prb.rule_id = v_rule.id ON CONFLICT DO NOTHING;
      END IF;

      IF v_rule.class_scope = 'selected_classes' THEN
        INSERT INTO public.credit_grant_class_types (organization_id, grant_id, class_type_id)
        SELECT p_org_id, v_grant_id, prc.class_type_id
        FROM public.package_rule_class_types prc
        WHERE prc.organization_id = p_org_id AND prc.rule_id = v_rule.id ON CONFLICT DO NOTHING;
      END IF;

      INSERT INTO public.credit_ledger_entries (
        organization_id, member_id, grant_id, credit_type, entry_type,
        delta, reference_type, reference_id, idempotency_key, reason, actor_user_id
      ) VALUES (
        p_org_id, p_member_id, v_grant_id, v_rule.entitlement_kind, 'grant',
        v_rule.credit_quantity, 'subscription', v_sub_id,
        v_key || ':' || v_grant_id::text, 'Package assigned: ' || v_pkg.name, v_actor_id
      );
    END IF;
  END LOOP;

  INSERT INTO public.audit_logs (
    organization_id, branch_id, actor_user_id, action, target_type, target_id, metadata
  ) VALUES (
    p_org_id, p_branch_id, v_actor_id, 'package.assigned', 'member_subscription', v_sub_id,
    jsonb_build_object('member_id', p_member_id, 'package_id', p_package_id, 'payment_method', p_payment_method)
  );

  RETURN jsonb_build_object(
    'subscription_id', v_sub_id,
    'status', 'active',
    'idempotent_replay', false
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.freeze_member_subscription(
  p_org_id uuid,
  p_subscription_id uuid,
  p_reason text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_sub public.member_subscriptions%ROWTYPE;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_sub
  FROM public.member_subscriptions
  WHERE id = p_subscription_id AND organization_id = p_org_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: Subscription not found' USING ERRCODE = 'P0002';
  END IF;

  IF NOT authz.has_permission(p_org_id, v_sub.assigned_branch_id, 'entitlement.assign') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing entitlement.assign permission' USING ERRCODE = '42501';
  END IF;

  IF v_sub.status <> 'active' THEN
    RAISE EXCEPTION 'INVALID_STATE: Only active subscriptions can be frozen' USING ERRCODE = '22023';
  END IF;

  UPDATE public.member_subscriptions
  SET status = 'frozen', frozen_at = now()
  WHERE id = p_subscription_id;

  UPDATE public.member_entitlements
  SET status = 'frozen'
  WHERE organization_id = p_org_id
    AND subscription_id = p_subscription_id
    AND status = 'active';

  -- Freeze associated credit grants atomically (M8)
  UPDATE public.credit_grants
  SET status = 'frozen'
  WHERE organization_id = p_org_id
    AND subscription_id = p_subscription_id
    AND status = 'active';

  INSERT INTO public.audit_logs (
    organization_id, branch_id, actor_user_id, action, target_type, target_id, metadata
  ) VALUES (
    p_org_id, v_sub.assigned_branch_id, v_actor_id, 'subscription.frozen', 'member_subscription', p_subscription_id,
    jsonb_build_object('reason', p_reason)
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.unfreeze_member_subscription(
  p_org_id uuid,
  p_subscription_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_sub public.member_subscriptions%ROWTYPE;
  v_frozen_delta interval;
  v_frozen_seconds integer;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_sub
  FROM public.member_subscriptions
  WHERE id = p_subscription_id AND organization_id = p_org_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: Subscription not found' USING ERRCODE = 'P0002';
  END IF;

  IF NOT authz.has_permission(p_org_id, v_sub.assigned_branch_id, 'entitlement.assign') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing entitlement.assign permission' USING ERRCODE = '42501';
  END IF;

  IF v_sub.status <> 'frozen' OR v_sub.frozen_at IS NULL THEN
    RAISE EXCEPTION 'INVALID_STATE: Subscription is not currently frozen' USING ERRCODE = '22023';
  END IF;

  v_frozen_delta := GREATEST(now() - v_sub.frozen_at, interval '0 seconds');
  v_frozen_seconds := floor(EXTRACT(EPOCH FROM v_frozen_delta))::integer;

  UPDATE public.member_subscriptions
  SET
    status = 'active',
    frozen_at = NULL,
    total_frozen_seconds = total_frozen_seconds + v_frozen_seconds,
    ends_at = CASE WHEN ends_at IS NOT NULL THEN ends_at + v_frozen_delta ELSE NULL END
  WHERE id = p_subscription_id;

  UPDATE public.member_entitlements
  SET
    status = 'active',
    valid_until = valid_until + v_frozen_delta
  WHERE organization_id = p_org_id
    AND subscription_id = p_subscription_id
    AND status = 'frozen';

  -- Unfreeze and extend associated credit grants (M8)
  UPDATE public.credit_grants
  SET
    status = CASE WHEN remaining_amount > 0 THEN 'active' ELSE 'depleted' END,
    expires_at = CASE WHEN expires_at IS NOT NULL THEN expires_at + v_frozen_delta ELSE NULL END
  WHERE organization_id = p_org_id
    AND subscription_id = p_subscription_id
    AND status = 'frozen';

  INSERT INTO public.audit_logs (
    organization_id, branch_id, actor_user_id, action, target_type, target_id, metadata
  ) VALUES (
    p_org_id, v_sub.assigned_branch_id, v_actor_id, 'subscription.unfrozen', 'member_subscription', p_subscription_id,
    jsonb_build_object('extended_seconds', v_frozen_seconds)
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.adjust_member_credits(
  p_org_id uuid,
  p_member_id uuid,
  p_credit_type text,
  p_delta integer,
  p_reason text,
  p_idempotency_key text,
  p_expires_at timestamptz DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_member public.members%ROWTYPE;
  v_caller_rank integer;
  v_key text := 'adj:' || NULLIF(trim(p_idempotency_key), '');
  v_adj_id uuid;
  v_existing_adj public.credit_adjustments%ROWTYPE;
  v_grant_id uuid;
  v_grant RECORD;
  v_grant_ids uuid[] := '{}';
  v_grant_amounts integer[] := '{}';
  v_total_available integer := 0;
  v_remaining_to_debit integer;
  v_take integer;
  i integer;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  IF p_credit_type NOT IN ('class_credit', 'pt_credit') THEN
    RAISE EXCEPTION 'VALIDATION_ERROR: Invalid credit type' USING ERRCODE = '22023';
  END IF;

  IF p_delta = 0 OR NULLIF(trim(p_reason), '') IS NULL OR v_key IS NULL THEN
    RAISE EXCEPTION 'VALIDATION_ERROR: Non-zero delta, reason, and idempotency_key are required'
      USING ERRCODE = '22023';
  END IF;

  SELECT * INTO v_member FROM public.members
  WHERE id = p_member_id AND organization_id = p_org_id;
  IF NOT FOUND OR v_member.status = 'archived' THEN
    RAISE EXCEPTION 'NOT_FOUND: Member not found in organization' USING ERRCODE = 'P0002';
  END IF;

  -- Branch-scoped permission + per-role cap (M5)
  IF NOT authz.has_permission(p_org_id, v_member.home_branch_id, 'credit.adjust') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing credit.adjust permission for member home branch'
      USING ERRCODE = '42501';
  END IF;

  v_caller_rank := authz.user_max_role_rank(p_org_id, v_member.home_branch_id);
  IF v_caller_rank < 80 AND abs(p_delta) > 20 THEN
    RAISE EXCEPTION 'FORBIDDEN: Branch Manager manual credit adjustments are capped at 20 credits'
      USING ERRCODE = '42501';
  END IF;

  -- Atomic idempotency insert first (H4)
  INSERT INTO public.credit_adjustments (
    organization_id, member_id, credit_type, delta, reason, idempotency_key, actor_user_id
  ) VALUES (
    p_org_id, p_member_id, p_credit_type, p_delta, trim(p_reason), v_key, v_actor_id
  )
  ON CONFLICT (organization_id, idempotency_key) DO NOTHING
  RETURNING id INTO v_adj_id;

  IF v_adj_id IS NULL THEN
    SELECT * INTO v_existing_adj FROM public.credit_adjustments
    WHERE organization_id = p_org_id AND idempotency_key = v_key;
    IF v_existing_adj.member_id <> p_member_id
       OR v_existing_adj.credit_type <> p_credit_type
       OR v_existing_adj.delta <> p_delta THEN
      RAISE EXCEPTION 'IDEMPOTENCY_KEY_REUSED: Key already used for different adjustment'
        USING ERRCODE = '23505';
    END IF;
    RETURN jsonb_build_object('status', 'ok', 'adjustment_id', v_existing_adj.id, 'idempotent_replay', true);
  END IF;

  IF p_delta > 0 THEN
    INSERT INTO public.credit_grants (
      organization_id, member_id, credit_type, branch_access_scope, class_scope,
      initial_amount, remaining_amount, expires_at, status
    ) VALUES (
      p_org_id, p_member_id, p_credit_type, 'all_branches', 'all_classes',
      p_delta, p_delta, p_expires_at, 'active'
    )
    RETURNING id INTO v_grant_id;

    INSERT INTO public.credit_ledger_entries (
      organization_id, member_id, grant_id, credit_type, entry_type, delta,
      reference_type, reference_id, idempotency_key, reason, actor_user_id
    ) VALUES (
      p_org_id, p_member_id, v_grant_id, p_credit_type, 'adjustment', p_delta,
      'manual_adjustment', v_adj_id, v_key || ':' || v_grant_id::text,
      trim(p_reason), v_actor_id
    );
  ELSE
    v_remaining_to_debit := abs(p_delta);

    -- Lock grants FIRST before computing total available (H4)
    FOR v_grant IN
      SELECT cg.id, cg.remaining_amount
      FROM public.credit_grants cg
      WHERE cg.organization_id = p_org_id
        AND cg.member_id = p_member_id
        AND cg.credit_type = p_credit_type
        AND cg.status = 'active'
        AND cg.remaining_amount > 0
        AND (cg.expires_at IS NULL OR cg.expires_at > now())
      ORDER BY cg.expires_at ASC NULLS LAST, cg.created_at ASC, cg.id ASC
      FOR UPDATE
    LOOP
      v_total_available := v_total_available + v_grant.remaining_amount;
      v_grant_ids := array_append(v_grant_ids, v_grant.id);
      v_grant_amounts := array_append(v_grant_amounts, v_grant.remaining_amount);
    END LOOP;

    IF v_total_available < v_remaining_to_debit THEN
      RAISE EXCEPTION 'INSUFFICIENT_CREDITS: Available balance (%) is less than adjustment (%)',
        v_total_available, v_remaining_to_debit USING ERRCODE = '22023';
    END IF;

    FOR i IN 1..COALESCE(array_length(v_grant_ids, 1), 0) LOOP
      EXIT WHEN v_remaining_to_debit <= 0;
      v_take := LEAST(v_grant_amounts[i], v_remaining_to_debit);

      UPDATE public.credit_grants
      SET
        remaining_amount = remaining_amount - v_take,
        status = CASE WHEN remaining_amount - v_take = 0 THEN 'depleted' ELSE 'active' END
      WHERE id = v_grant_ids[i];

      INSERT INTO public.credit_ledger_entries (
        organization_id, member_id, grant_id, credit_type, entry_type, delta,
        reference_type, reference_id, idempotency_key, reason, actor_user_id
      ) VALUES (
        p_org_id, p_member_id, v_grant_ids[i], p_credit_type, 'adjustment', -v_take,
        'manual_adjustment', v_adj_id, v_key || ':' || v_grant_ids[i]::text,
        trim(p_reason), v_actor_id
      );

      v_remaining_to_debit := v_remaining_to_debit - v_take;
    END LOOP;

    IF v_remaining_to_debit > 0 THEN
      RAISE EXCEPTION 'INSUFFICIENT_CREDITS: Unable to complete full debit' USING ERRCODE = '22023';
    END IF;
  END IF;

  INSERT INTO public.audit_logs (
    organization_id, branch_id, actor_user_id, action, target_type, target_id, metadata
  ) VALUES (
    p_org_id, v_member.home_branch_id, v_actor_id, 'credit.adjusted', 'member', p_member_id,
    jsonb_build_object('adjustment_id', v_adj_id, 'credit_type', p_credit_type, 'delta', p_delta, 'reason', trim(p_reason))
  );

  RETURN jsonb_build_object('status', 'ok', 'adjustment_id', v_adj_id, 'idempotent_replay', false);
END;
$$;

REVOKE ALL ON FUNCTION public.invite_member_claim(uuid, uuid, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.claim_member_profile(text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.set_member_status(uuid, uuid, text, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.update_my_member_contact(uuid, text, text, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.lookup_member_for_checkin(uuid, uuid, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.assign_package_to_member(uuid, uuid, uuid, uuid, timestamptz, text, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.freeze_member_subscription(uuid, uuid, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.unfreeze_member_subscription(uuid, uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.adjust_member_credits(uuid, uuid, text, integer, text, text, timestamptz) FROM PUBLIC, anon;

GRANT EXECUTE ON FUNCTION public.invite_member_claim(uuid, uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.claim_member_profile(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.set_member_status(uuid, uuid, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_my_member_contact(uuid, text, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.lookup_member_for_checkin(uuid, uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.assign_package_to_member(uuid, uuid, uuid, uuid, timestamptz, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.freeze_member_subscription(uuid, uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.unfreeze_member_subscription(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.adjust_member_credits(uuid, uuid, text, integer, text, text, timestamptz) TO authenticated;

REVOKE TRUNCATE, TRIGGER, REFERENCES ON ALL TABLES IN SCHEMA public FROM anon, authenticated;
