-- RITMA Migration 000500: Post-MVP Schema Readiness (Personal Training, Equipment Operations & Notifications)
-- Fixes H3 (server-derived PT price/branch, active trainer, availability, future slot, member status & overlap checks) and L9 (notification column immutability, trainer profile management).

-- ---------------------------------------------------------------------------
-- Personal Training
-- ---------------------------------------------------------------------------

CREATE TABLE public.trainer_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  home_branch_id uuid NOT NULL,
  bio text NOT NULL DEFAULT '',
  specialties text[] NOT NULL DEFAULT '{}',
  default_credit_cost integer NOT NULL DEFAULT 1 CHECK (default_credit_cost > 0),
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (organization_id, home_branch_id)
    REFERENCES public.branches(organization_id, id) ON DELETE RESTRICT,
  UNIQUE (organization_id, id),
  UNIQUE (organization_id, home_branch_id, id),
  UNIQUE (organization_id, user_id)
);

CREATE TRIGGER trg_trainer_profiles_updated_at
  BEFORE UPDATE ON public.trainer_profiles
  FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();

CREATE TABLE public.trainer_availabilities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  trainer_id uuid NOT NULL,
  weekday smallint NOT NULL CHECK (weekday BETWEEN 0 AND 6),
  start_time time NOT NULL,
  end_time time NOT NULL,
  CHECK (end_time > start_time),
  FOREIGN KEY (organization_id, branch_id)
    REFERENCES public.branches(organization_id, id) ON DELETE CASCADE,
  FOREIGN KEY (organization_id, branch_id, trainer_id)
    REFERENCES public.trainer_profiles(organization_id, home_branch_id, id) ON DELETE CASCADE
);

CREATE TABLE public.pt_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  trainer_id uuid NOT NULL,
  member_id uuid NOT NULL,
  starts_at timestamptz NOT NULL,
  ends_at timestamptz NOT NULL,
  credit_cost integer NOT NULL DEFAULT 1 CHECK (credit_cost > 0),
  status text NOT NULL DEFAULT 'scheduled'
    CHECK (status IN ('scheduled', 'completed', 'cancelled_early', 'cancelled_late', 'no_show')),
  notes text,
  idempotency_key text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (organization_id, branch_id)
    REFERENCES public.branches(organization_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (organization_id, branch_id, trainer_id)
    REFERENCES public.trainer_profiles(organization_id, home_branch_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (organization_id, member_id)
    REFERENCES public.members(organization_id, id) ON DELETE RESTRICT,
  UNIQUE (organization_id, idempotency_key),
  CHECK (ends_at > starts_at)
);

CREATE TRIGGER trg_pt_sessions_updated_at
  BEFORE UPDATE ON public.pt_sessions
  FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();

-- ---------------------------------------------------------------------------
-- Equipment Operations & Maintenance Tickets
-- ---------------------------------------------------------------------------

CREATE TABLE public.equipment_assets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  asset_code text NOT NULL,
  name text NOT NULL,
  category text NOT NULL,
  status text NOT NULL DEFAULT 'operational'
    CHECK (status IN ('operational', 'needs_service', 'out_of_order', 'retired')),
  last_serviced_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (organization_id, branch_id)
    REFERENCES public.branches(organization_id, id) ON DELETE RESTRICT,
  UNIQUE (organization_id, id),
  UNIQUE (organization_id, asset_code)
);

CREATE TRIGGER trg_equipment_assets_updated_at
  BEFORE UPDATE ON public.equipment_assets
  FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();

CREATE TABLE public.equipment_maintenance_tickets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  asset_id uuid NOT NULL,
  reported_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  summary text NOT NULL,
  priority text NOT NULL DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'critical')),
  status text NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
  resolved_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (organization_id, branch_id)
    REFERENCES public.branches(organization_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (organization_id, asset_id)
    REFERENCES public.equipment_assets(organization_id, id) ON DELETE CASCADE
);

CREATE TRIGGER trg_equipment_tickets_updated_at
  BEFORE UPDATE ON public.equipment_maintenance_tickets
  FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();

-- ---------------------------------------------------------------------------
-- In-App & Push Notification Outbox
-- ---------------------------------------------------------------------------

CREATE TABLE public.user_notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title text NOT NULL,
  body text NOT NULL,
  category text NOT NULL,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  read_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_user_notifications_user_unread
  ON public.user_notifications (user_id, created_at DESC)
  WHERE read_at IS NULL;

-- Ensure recipients can only update read_at on notifications (L9).
CREATE OR REPLACE FUNCTION private.guard_notification_update()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, public, pg_temp
AS $$
BEGIN
  IF NEW.organization_id IS DISTINCT FROM OLD.organization_id
     OR NEW.user_id IS DISTINCT FROM OLD.user_id
     OR NEW.title IS DISTINCT FROM OLD.title
     OR NEW.body IS DISTINCT FROM OLD.body
     OR NEW.category IS DISTINCT FROM OLD.category
     OR NEW.metadata IS DISTINCT FROM OLD.metadata THEN
    RAISE EXCEPTION 'FORBIDDEN: Only read_at may be updated by notification recipient'
      USING ERRCODE = '42501';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_user_notifications_guard
  BEFORE UPDATE ON public.user_notifications
  FOR EACH ROW EXECUTE FUNCTION private.guard_notification_update();

-- ---------------------------------------------------------------------------
-- Default-Deny RLS
-- ---------------------------------------------------------------------------

ALTER TABLE public.trainer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trainer_profiles FORCE ROW LEVEL SECURITY;
ALTER TABLE public.trainer_availabilities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trainer_availabilities FORCE ROW LEVEL SECURITY;
ALTER TABLE public.pt_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pt_sessions FORCE ROW LEVEL SECURITY;
ALTER TABLE public.equipment_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.equipment_assets FORCE ROW LEVEL SECURITY;
ALTER TABLE public.equipment_maintenance_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.equipment_maintenance_tickets FORCE ROW LEVEL SECURITY;
ALTER TABLE public.user_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_notifications FORCE ROW LEVEL SECURITY;

CREATE POLICY trainer_profiles_select ON public.trainer_profiles
  FOR SELECT TO authenticated USING (authz.is_org_participant(organization_id));

CREATE POLICY trainer_profiles_insert_mgr ON public.trainer_profiles
  FOR INSERT TO authenticated
  WITH CHECK (
    authz.has_permission(organization_id, home_branch_id, 'schedule.manage')
    AND authz.is_user_org_participant(organization_id, user_id)
  );

CREATE POLICY trainer_profiles_update_self_or_mgr ON public.trainer_profiles
  FOR UPDATE TO authenticated
  USING (
    (user_id = (SELECT auth.uid()) AND authz.has_permission(organization_id, home_branch_id, 'pt.manage'))
    OR authz.has_permission(organization_id, home_branch_id, 'schedule.manage')
  )
  WITH CHECK (
    (user_id = (SELECT auth.uid()) AND authz.has_permission(organization_id, home_branch_id, 'pt.manage'))
    OR authz.has_permission(organization_id, home_branch_id, 'schedule.manage')
  );

CREATE POLICY trainer_avail_select ON public.trainer_availabilities
  FOR SELECT TO authenticated USING (authz.is_org_participant(organization_id));

CREATE POLICY trainer_avail_manage ON public.trainer_availabilities
  FOR ALL TO authenticated
  USING (
    authz.has_permission(organization_id, branch_id, 'schedule.manage')
    OR EXISTS (
      SELECT 1 FROM public.trainer_profiles tp
      WHERE tp.id = trainer_id
        AND tp.organization_id = trainer_availabilities.organization_id
        AND tp.user_id = (SELECT auth.uid())
        AND authz.has_permission(organization_id, branch_id, 'pt.manage')
    )
  )
  WITH CHECK (
    authz.has_permission(organization_id, branch_id, 'schedule.manage')
    OR EXISTS (
      SELECT 1 FROM public.trainer_profiles tp
      WHERE tp.id = trainer_id
        AND tp.organization_id = trainer_availabilities.organization_id
        AND tp.user_id = (SELECT auth.uid())
        AND authz.has_permission(organization_id, branch_id, 'pt.manage')
    )
  );

CREATE POLICY pt_sessions_select ON public.pt_sessions
  FOR SELECT TO authenticated
  USING (
    authz.is_self_member(organization_id, member_id)
    OR authz.has_permission(organization_id, branch_id, 'pt.manage')
  );

CREATE POLICY equipment_assets_select ON public.equipment_assets
  FOR SELECT TO authenticated
  USING (authz.has_permission(organization_id, branch_id, 'equipment.manage'));

CREATE POLICY equipment_assets_manage ON public.equipment_assets
  FOR ALL TO authenticated
  USING (authz.has_permission(organization_id, branch_id, 'equipment.manage'))
  WITH CHECK (authz.has_permission(organization_id, branch_id, 'equipment.manage'));

CREATE POLICY equipment_tickets_select ON public.equipment_maintenance_tickets
  FOR SELECT TO authenticated
  USING (authz.has_permission(organization_id, branch_id, 'equipment.manage'));

CREATE POLICY equipment_tickets_manage ON public.equipment_maintenance_tickets
  FOR ALL TO authenticated
  USING (authz.has_permission(organization_id, branch_id, 'equipment.manage'))
  WITH CHECK (authz.has_permission(organization_id, branch_id, 'equipment.manage'));

CREATE POLICY user_notifications_select_own ON public.user_notifications
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));

CREATE POLICY user_notifications_update_own ON public.user_notifications
  FOR UPDATE TO authenticated
  USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

-- ---------------------------------------------------------------------------
-- Transactional Personal Training RPCs (H3 Hardened)
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.book_pt_session(
  p_org_id uuid,
  p_branch_id uuid,
  p_trainer_id uuid,
  p_member_id uuid,
  p_starts_at timestamptz,
  p_ends_at timestamptz,
  p_credit_cost integer DEFAULT NULL,
  p_idempotency_key text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_key text := 'pt:' || COALESCE(NULLIF(trim(p_idempotency_key), ''), gen_random_uuid()::text);
  v_trainer public.trainer_profiles%ROWTYPE;
  v_member public.members%ROWTYPE;
  v_existing public.pt_sessions%ROWTYPE;
  v_branch_id uuid;
  v_cost integer;
  v_tz text;
  v_local_start timestamp;
  v_local_end timestamp;
  v_pt_id uuid := gen_random_uuid();
  v_grant RECORD;
  v_total_available integer := 0;
  v_remaining_to_debit integer;
  v_take integer;
  v_grant_ids uuid[] := '{}';
  v_grant_amounts integer[] := '{}';
  i integer;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_trainer FROM public.trainer_profiles
  WHERE id = p_trainer_id AND organization_id = p_org_id;
  IF NOT FOUND OR NOT v_trainer.is_active THEN
    RAISE EXCEPTION 'NOT_FOUND: Active trainer profile not found' USING ERRCODE = 'P0002';
  END IF;

  -- Derive branch strictly from trainer profile (H3)
  v_branch_id := v_trainer.home_branch_id;
  IF p_branch_id IS NOT NULL AND p_branch_id IS DISTINCT FROM v_branch_id THEN
    RAISE EXCEPTION 'VALIDATION_ERROR: Trainer does not operate at requested branch'
      USING ERRCODE = '22023';
  END IF;

  IF NOT authz.is_self_member(p_org_id, p_member_id)
     AND NOT authz.has_permission(p_org_id, v_branch_id, 'pt.manage')
     AND NOT authz.has_permission(p_org_id, v_branch_id, 'booking.manage') THEN
    RAISE EXCEPTION 'FORBIDDEN: Not authorized to book PT session' USING ERRCODE = '42501';
  END IF;

  -- Server-derived cost unless caller has pt.manage (H3)
  IF p_credit_cost IS NOT NULL AND authz.has_permission(p_org_id, v_branch_id, 'pt.manage') THEN
    IF p_credit_cost <= 0 THEN
      RAISE EXCEPTION 'VALIDATION_ERROR: Credit cost must be positive' USING ERRCODE = '22023';
    END IF;
    v_cost := p_credit_cost;
  ELSE
    v_cost := v_trainer.default_credit_cost;
  END IF;
  v_remaining_to_debit := v_cost;

  SELECT * INTO v_existing
  FROM public.pt_sessions
  WHERE organization_id = p_org_id AND idempotency_key = v_key;
  IF FOUND THEN
    IF v_existing.member_id <> p_member_id OR v_existing.trainer_id <> p_trainer_id THEN
      RAISE EXCEPTION 'IDEMPOTENCY_KEY_REUSED: Key already used for different PT booking'
        USING ERRCODE = '23505';
    END IF;
    RETURN jsonb_build_object('pt_session_id', v_existing.id, 'status', v_existing.status, 'idempotent_replay', true);
  END IF;

  SELECT * INTO v_member FROM public.members
  WHERE id = p_member_id AND organization_id = p_org_id;
  IF NOT FOUND OR v_member.status <> 'active' THEN
    RAISE EXCEPTION 'MEMBER_INACTIVE: Active member status required for PT booking'
      USING ERRCODE = '22023';
  END IF;

  IF p_starts_at <= now() OR p_ends_at <= p_starts_at THEN
    RAISE EXCEPTION 'VALIDATION_ERROR: PT slot must be in the future with end after start'
      USING ERRCODE = '22023';
  END IF;

  -- Verify slot fits inside trainer availability in branch timezone (H3)
  SELECT COALESCE(b.timezone, o.timezone, 'UTC') INTO v_tz
  FROM public.branches b
  JOIN public.organizations o ON o.id = b.organization_id
  WHERE b.id = v_branch_id;

  v_local_start := p_starts_at AT TIME ZONE v_tz;
  v_local_end := p_ends_at AT TIME ZONE v_tz;

  IF v_local_start::date <> v_local_end::date OR NOT EXISTS (
    SELECT 1 FROM public.trainer_availabilities ta
    WHERE ta.organization_id = p_org_id
      AND ta.branch_id = v_branch_id
      AND ta.trainer_id = p_trainer_id
      AND ta.weekday = EXTRACT(DOW FROM v_local_start)::smallint
      AND v_local_start::time >= ta.start_time
      AND v_local_end::time <= ta.end_time
  ) THEN
    RAISE EXCEPTION 'OUTSIDE_AVAILABILITY: Requested time is outside trainer availability'
      USING ERRCODE = '22023';
  END IF;

  PERFORM pg_advisory_xact_lock(hashtextextended('pt:' || p_trainer_id::text, 0));
  PERFORM pg_advisory_xact_lock(hashtextextended('pt_member:' || p_member_id::text, 0));

  IF EXISTS (
    SELECT 1 FROM public.pt_sessions
    WHERE organization_id = p_org_id
      AND trainer_id = p_trainer_id
      AND status = 'scheduled'
      AND starts_at < p_ends_at
      AND ends_at > p_starts_at
  ) THEN
    RAISE EXCEPTION 'TRAINER_CONFLICT: Trainer already has an overlapping PT session'
      USING ERRCODE = '23505';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.pt_sessions
    WHERE organization_id = p_org_id
      AND member_id = p_member_id
      AND status = 'scheduled'
      AND starts_at < p_ends_at
      AND ends_at > p_starts_at
  ) THEN
    RAISE EXCEPTION 'MEMBER_CONFLICT: Member already has an overlapping PT session'
      USING ERRCODE = '23505';
  END IF;

  INSERT INTO public.pt_sessions (
    id, organization_id, branch_id, trainer_id, member_id,
    starts_at, ends_at, credit_cost, status, idempotency_key
  ) VALUES (
    v_pt_id, p_org_id, v_branch_id, p_trainer_id, p_member_id,
    p_starts_at, p_ends_at, v_cost, 'scheduled', v_key
  );

  FOR v_grant IN
    SELECT cg.id, cg.remaining_amount
    FROM public.credit_grants cg
    LEFT JOIN public.member_subscriptions ms ON ms.id = cg.subscription_id
    WHERE cg.organization_id = p_org_id
      AND cg.member_id = p_member_id
      AND cg.credit_type = 'pt_credit'
      AND cg.status = 'active'
      AND (ms.id IS NULL OR ms.status <> 'frozen')
      AND cg.remaining_amount > 0
      AND (cg.expires_at IS NULL OR cg.expires_at > now())
      AND (
        cg.branch_access_scope = 'all_branches'
        OR EXISTS (
          SELECT 1 FROM public.credit_grant_branches cgb
          WHERE cgb.organization_id = p_org_id AND cgb.grant_id = cg.id AND cgb.branch_id = v_branch_id
        )
      )
    ORDER BY cg.expires_at ASC NULLS LAST, cg.created_at ASC, cg.id ASC
    FOR UPDATE OF cg
  LOOP
    v_total_available := v_total_available + v_grant.remaining_amount;
    v_grant_ids := array_append(v_grant_ids, v_grant.id);
    v_grant_amounts := array_append(v_grant_amounts, v_grant.remaining_amount);
  END LOOP;

  IF v_total_available < v_cost THEN
    RAISE EXCEPTION 'INSUFFICIENT_PT_CREDITS: Available PT credits (%) less than required (%)',
      v_total_available, v_cost USING ERRCODE = '22023';
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
      p_org_id, p_member_id, v_grant_ids[i], 'pt_credit', 'consume', -v_take,
      'pt_session', v_pt_id, v_key || ':' || v_grant_ids[i]::text,
      'PT session booked', v_actor_id
    );

    v_remaining_to_debit := v_remaining_to_debit - v_take;
  END LOOP;

  RETURN jsonb_build_object('pt_session_id', v_pt_id, 'status', 'scheduled', 'credit_cost', v_cost, 'idempotent_replay', false);
END;
$$;

CREATE OR REPLACE FUNCTION public.complete_pt_session(
  p_org_id uuid,
  p_pt_session_id uuid,
  p_notes text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_pt public.pt_sessions%ROWTYPE;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_pt FROM public.pt_sessions
  WHERE id = p_pt_session_id AND organization_id = p_org_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: PT session not found' USING ERRCODE = 'P0002';
  END IF;

  IF NOT authz.has_permission(p_org_id, v_pt.branch_id, 'pt.manage') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing pt.manage permission' USING ERRCODE = '42501';
  END IF;

  IF v_pt.status <> 'scheduled' THEN
    RAISE EXCEPTION 'INVALID_STATE: Only scheduled PT sessions can be completed' USING ERRCODE = '22023';
  END IF;

  UPDATE public.pt_sessions
  SET status = 'completed', notes = COALESCE(p_notes, notes)
  WHERE id = p_pt_session_id;
END;
$$;

REVOKE ALL ON FUNCTION public.book_pt_session(uuid, uuid, uuid, uuid, timestamptz, timestamptz, integer, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.complete_pt_session(uuid, uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.book_pt_session(uuid, uuid, uuid, uuid, timestamptz, timestamptz, integer, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.complete_pt_session(uuid, uuid, text) TO authenticated;

REVOKE TRUNCATE, TRIGGER, REFERENCES ON ALL TABLES IN SCHEMA public FROM anon, authenticated;
