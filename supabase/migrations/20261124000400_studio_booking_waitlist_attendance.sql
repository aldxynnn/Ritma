-- RITMA Migration 000400: Studio Class Booking, Capacity Locking, Waitlist Promotion, Attendance & Dashboard KPIs
-- Fixes M4 (instructor roster PII & active assignment check), M6 (catalog org-only + soft delete), M7 (class_sessions insert/cancel guard + cutoff CHECK), M8 (subscription freeze guard), L1-L4, L9.

-- ---------------------------------------------------------------------------
-- Class Templates, Sessions & Bookings
-- ---------------------------------------------------------------------------

CREATE TABLE public.class_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  class_type_id uuid NOT NULL,
  title text NOT NULL CHECK (char_length(trim(title)) BETWEEN 2 AND 120),
  description text NOT NULL DEFAULT '',
  default_duration_minutes integer NOT NULL CHECK (default_duration_minutes > 0),
  default_capacity integer NOT NULL CHECK (default_capacity > 0),
  default_credit_cost integer NOT NULL DEFAULT 1 CHECK (default_credit_cost >= 0),
  cancellation_cutoff_minutes integer NOT NULL DEFAULT 720 CHECK (cancellation_cutoff_minutes >= 0),
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (organization_id, class_type_id)
    REFERENCES public.class_types(organization_id, id) ON DELETE RESTRICT,
  UNIQUE (organization_id, id)
);

CREATE TRIGGER trg_class_templates_updated_at
  BEFORE UPDATE ON public.class_templates
  FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();

CREATE TABLE public.class_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  room_id uuid NOT NULL,
  class_template_id uuid,
  class_type_id uuid NOT NULL,
  instructor_user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  instructor_display_name text NOT NULL DEFAULT '',
  title text NOT NULL CHECK (char_length(trim(title)) BETWEEN 2 AND 120),
  starts_at timestamptz NOT NULL,
  ends_at timestamptz NOT NULL,
  capacity integer NOT NULL CHECK (capacity > 0),
  confirmed_count integer NOT NULL DEFAULT 0 CHECK (confirmed_count >= 0 AND confirmed_count <= capacity),
  credit_cost integer NOT NULL DEFAULT 1 CHECK (credit_cost >= 0),
  cancellation_cutoff_at timestamptz NOT NULL,
  waitlist_enabled boolean NOT NULL DEFAULT true,
  status text NOT NULL DEFAULT 'scheduled'
    CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (organization_id, branch_id, room_id)
    REFERENCES public.rooms(organization_id, branch_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (organization_id, class_template_id)
    REFERENCES public.class_templates(organization_id, id) ON DELETE SET NULL (class_template_id),
  FOREIGN KEY (organization_id, class_type_id)
    REFERENCES public.class_types(organization_id, id) ON DELETE RESTRICT,
  UNIQUE (organization_id, branch_id, id),
  CHECK (ends_at > starts_at),
  CHECK (cancellation_cutoff_at <= starts_at)
);

CREATE INDEX idx_class_sessions_schedule
  ON public.class_sessions (organization_id, branch_id, starts_at);

CREATE INDEX idx_class_sessions_instructor
  ON public.class_sessions (organization_id, instructor_user_id, starts_at);

CREATE TRIGGER trg_class_sessions_updated_at
  BEFORE UPDATE ON public.class_sessions
  FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();

-- Session invariant guard: INSERT resets confirmed_count/status; UPDATE protects confirmed_count, capacity, cancel, and instructor assignment (M4, M7, F9).
CREATE OR REPLACE FUNCTION private.guard_class_session_invariants()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
BEGIN
  IF NEW.instructor_user_id IS NOT NULL AND (
    TG_OP = 'INSERT' OR NEW.instructor_user_id IS DISTINCT FROM OLD.instructor_user_id
  ) THEN
    IF NOT EXISTS (
      SELECT 1
      FROM public.user_role_assignments ura
      JOIN public.roles r ON r.id = ura.role_id
      WHERE ura.user_id = NEW.instructor_user_id
        AND ura.organization_id = NEW.organization_id
        AND ura.status = 'active'
        AND r.code <> 'member'
        AND (ura.branch_id IS NULL OR ura.branch_id = NEW.branch_id)
    ) THEN
      RAISE EXCEPTION 'VALIDATION_ERROR: Assigned instructor must hold an active staff role in this branch'
        USING ERRCODE = '22023';
    END IF;
  END IF;

  IF TG_OP = 'INSERT' THEN
    NEW.confirmed_count := 0;
    NEW.status := 'scheduled';
    RETURN NEW;
  END IF;

  IF NEW.confirmed_count IS DISTINCT FROM OLD.confirmed_count
     AND current_setting('ritma.allow_count_mutation', true) IS DISTINCT FROM 'on' THEN
    RAISE EXCEPTION 'FORBIDDEN: confirmed_count can only be changed by booking RPCs'
      USING ERRCODE = '42501';
  END IF;

  IF OLD.status IS DISTINCT FROM 'cancelled'
     AND NEW.status = 'cancelled'
     AND current_setting('ritma.allow_session_cancel', true) IS DISTINCT FROM 'on' THEN
    RAISE EXCEPTION 'FORBIDDEN: Sessions must be cancelled via cancel_class_session RPC so bookings are refunded'
      USING ERRCODE = '42501';
  END IF;

  IF NEW.capacity < NEW.confirmed_count THEN
    RAISE EXCEPTION 'CAPACITY_BELOW_BOOKED: Cannot reduce capacity below confirmed count (%)',
      NEW.confirmed_count USING ERRCODE = '22023';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_class_sessions_invariants
  BEFORE INSERT OR UPDATE ON public.class_sessions
  FOR EACH ROW EXECUTE FUNCTION private.guard_class_session_invariants();

CREATE TABLE public.class_bookings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  session_id uuid NOT NULL,
  member_id uuid NOT NULL,
  status text NOT NULL DEFAULT 'confirmed'
    CHECK (status IN ('confirmed', 'waitlisted', 'cancelled_early', 'cancelled_late', 'expired_unpromoted')),
  attendance_status text NOT NULL DEFAULT 'pending'
    CHECK (attendance_status IN ('pending', 'checked_in', 'no_show')),
  waitlist_position integer CHECK (waitlist_position IS NULL OR waitlist_position > 0),
  credit_cost integer NOT NULL DEFAULT 0 CHECK (credit_cost >= 0),
  booked_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  idempotency_key text NOT NULL,
  booked_at timestamptz NOT NULL DEFAULT now(),
  cancelled_at timestamptz,
  attendance_marked_at timestamptz,
  attendance_marked_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (organization_id, branch_id, session_id)
    REFERENCES public.class_sessions(organization_id, branch_id, id) ON DELETE CASCADE,
  FOREIGN KEY (organization_id, member_id)
    REFERENCES public.members(organization_id, id) ON DELETE RESTRICT,
  UNIQUE (organization_id, idempotency_key)
);

CREATE UNIQUE INDEX idx_class_bookings_one_active_per_member
  ON public.class_bookings (session_id, member_id)
  WHERE status IN ('confirmed', 'waitlisted');

CREATE INDEX idx_class_bookings_waitlist_queue
  ON public.class_bookings (session_id, waitlist_position, booked_at)
  WHERE status = 'waitlisted';

CREATE INDEX idx_class_bookings_member
  ON public.class_bookings (organization_id, member_id, booked_at DESC);

CREATE TRIGGER trg_class_bookings_updated_at
  BEFORE UPDATE ON public.class_bookings
  FOR EACH ROW EXECUTE FUNCTION private.set_updated_at();

-- ---------------------------------------------------------------------------
-- RLS Policies (M4, M6)
-- ---------------------------------------------------------------------------

ALTER TABLE public.class_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.class_templates FORCE ROW LEVEL SECURITY;
ALTER TABLE public.class_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.class_sessions FORCE ROW LEVEL SECURITY;
ALTER TABLE public.class_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.class_bookings FORCE ROW LEVEL SECURITY;

CREATE POLICY class_templates_select ON public.class_templates
  FOR SELECT TO authenticated
  USING (authz.is_org_participant(organization_id));

-- Org-wide schedule/package permission only, no DELETE (M6)
CREATE POLICY class_templates_insert ON public.class_templates
  FOR INSERT TO authenticated
  WITH CHECK (
    authz.has_permission(organization_id, NULL, 'schedule.manage')
    OR authz.has_permission(organization_id, NULL, 'package.manage')
  );

CREATE POLICY class_templates_update ON public.class_templates
  FOR UPDATE TO authenticated
  USING (
    authz.has_permission(organization_id, NULL, 'schedule.manage')
    OR authz.has_permission(organization_id, NULL, 'package.manage')
  )
  WITH CHECK (
    authz.has_permission(organization_id, NULL, 'schedule.manage')
    OR authz.has_permission(organization_id, NULL, 'package.manage')
  );

CREATE POLICY class_sessions_select ON public.class_sessions
  FOR SELECT TO authenticated
  USING (authz.is_org_participant(organization_id));

CREATE POLICY class_sessions_insert ON public.class_sessions
  FOR INSERT TO authenticated
  WITH CHECK (authz.has_permission(organization_id, branch_id, 'schedule.manage'));

CREATE POLICY class_sessions_update ON public.class_sessions
  FOR UPDATE TO authenticated
  USING (authz.has_permission(organization_id, branch_id, 'schedule.manage'))
  WITH CHECK (authz.has_permission(organization_id, branch_id, 'schedule.manage'));

-- Direct writes to class_bookings DENIED; instructor access requires active attendance.mark role & recent/upcoming session window (M4).
CREATE POLICY class_bookings_select ON public.class_bookings
  FOR SELECT TO authenticated
  USING (
    authz.is_self_member(organization_id, member_id)
    OR authz.has_permission(organization_id, branch_id, 'booking.read')
    OR EXISTS (
      SELECT 1 FROM public.class_sessions cs
      WHERE cs.id = class_bookings.session_id
        AND cs.organization_id = class_bookings.organization_id
        AND cs.instructor_user_id = (SELECT auth.uid())
        AND cs.starts_at > now() - interval '2 days'
        AND authz.has_permission(cs.organization_id, cs.branch_id, 'attendance.mark')
    )
  );

-- ---------------------------------------------------------------------------
-- Helper: Consume FIFO credits inside locked transaction
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION private.consume_member_class_credits(
  p_org_id uuid,
  p_branch_id uuid,
  p_class_type_id uuid,
  p_member_id uuid,
  p_cost integer,
  p_booking_id uuid,
  p_idempotency_key text,
  p_actor_id uuid,
  p_reason text
)
RETURNS boolean
LANGUAGE plpgsql
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_has_unlimited boolean;
  v_grant RECORD;
  v_total_available integer := 0;
  v_remaining_to_debit integer := p_cost;
  v_take integer;
  v_grant_ids uuid[] := '{}';
  v_grant_amounts integer[] := '{}';
  i integer;
BEGIN
  IF p_cost = 0 THEN
    RETURN true;
  END IF;

  SELECT EXISTS (
    SELECT 1
    FROM public.member_entitlements me
    JOIN public.member_subscriptions ms ON ms.id = me.subscription_id
    WHERE me.organization_id = p_org_id
      AND me.member_id = p_member_id
      AND me.entitlement_kind = 'unlimited_class'
      AND me.status = 'active'
      AND ms.status = 'active'
      AND me.valid_from <= now()
      AND me.valid_until > now()
      AND (
        me.branch_access_scope = 'all_branches'
        OR EXISTS (
          SELECT 1 FROM public.member_entitlement_branches meb
          WHERE meb.organization_id = p_org_id
            AND meb.entitlement_id = me.id
            AND meb.branch_id = p_branch_id
        )
      )
      AND (
        me.class_scope = 'all_classes'
        OR EXISTS (
          SELECT 1 FROM public.member_entitlement_class_types mec
          WHERE mec.organization_id = p_org_id
            AND mec.entitlement_id = me.id
            AND mec.class_type_id = p_class_type_id
        )
      )
  ) INTO v_has_unlimited;

  IF v_has_unlimited THEN
    RETURN true;
  END IF;

  -- Lock eligible unexpired non-frozen grants in canonical FIFO + id order (F5, F6, M8, L3)
  FOR v_grant IN
    SELECT cg.id, cg.remaining_amount
    FROM public.credit_grants cg
    LEFT JOIN public.member_subscriptions ms ON ms.id = cg.subscription_id
    WHERE cg.organization_id = p_org_id
      AND cg.member_id = p_member_id
      AND cg.credit_type = 'class_credit'
      AND cg.status = 'active'
      AND (ms.id IS NULL OR ms.status <> 'frozen')
      AND cg.remaining_amount > 0
      AND (cg.expires_at IS NULL OR cg.expires_at > now())
      AND (
        cg.branch_access_scope = 'all_branches'
        OR EXISTS (
          SELECT 1 FROM public.credit_grant_branches cgb
          WHERE cgb.organization_id = p_org_id
            AND cgb.grant_id = cg.id
            AND cgb.branch_id = p_branch_id
        )
      )
      AND (
        cg.class_scope = 'all_classes'
        OR EXISTS (
          SELECT 1 FROM public.credit_grant_class_types cgc
          WHERE cgc.organization_id = p_org_id
            AND cgc.grant_id = cg.id
            AND cgc.class_type_id = p_class_type_id
        )
      )
    ORDER BY cg.expires_at ASC NULLS LAST, cg.created_at ASC, cg.id ASC
    FOR UPDATE OF cg
  LOOP
    v_total_available := v_total_available + v_grant.remaining_amount;
    v_grant_ids := array_append(v_grant_ids, v_grant.id);
    v_grant_amounts := array_append(v_grant_amounts, v_grant.remaining_amount);
  END LOOP;

  IF v_total_available < p_cost THEN
    RETURN false;
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
      p_org_id, p_member_id, v_grant_ids[i], 'class_credit', 'consume', -v_take,
      'class_booking', p_booking_id, p_idempotency_key || ':' || v_grant_ids[i]::text,
      p_reason, p_actor_id
    );

    v_remaining_to_debit := v_remaining_to_debit - v_take;
  END LOOP;

  RETURN true;
END;
$$;

-- ---------------------------------------------------------------------------
-- Transactional RPCs: Booking, Cancellation/Waitlist, Session Cancel, Roster, Attendance, KPIs
-- ---------------------------------------------------------------------------

-- Safe PII-filtered roster view for instructors & branch staff (M4).
CREATE OR REPLACE FUNCTION public.get_session_roster(
  p_org_id uuid,
  p_session_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_session public.class_sessions%ROWTYPE;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_session FROM public.class_sessions
  WHERE id = p_session_id AND organization_id = p_org_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: Session not found' USING ERRCODE = 'P0002';
  END IF;

  IF NOT authz.has_permission(p_org_id, v_session.branch_id, 'booking.read')
     AND NOT (
       v_session.instructor_user_id = v_actor_id
       AND v_session.starts_at > now() - interval '2 days'
       AND authz.has_permission(p_org_id, v_session.branch_id, 'attendance.mark')
     ) THEN
    RAISE EXCEPTION 'FORBIDDEN: Not authorized to view session roster' USING ERRCODE = '42501';
  END IF;

  RETURN (
    SELECT COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'booking_id', cb.id,
          'member_id', m.id,
          'member_display_name', m.full_name,
          'member_code', m.member_code,
          'status', cb.status,
          'attendance_status', cb.attendance_status,
          'waitlist_position', cb.waitlist_position,
          'booked_at', cb.booked_at
        )
        ORDER BY cb.status ASC, cb.waitlist_position ASC NULLS FIRST, cb.booked_at ASC
      ),
      '[]'::jsonb
    )
    FROM public.class_bookings cb
    JOIN public.members m ON m.id = cb.member_id AND m.organization_id = cb.organization_id
    WHERE cb.organization_id = p_org_id
      AND cb.session_id = p_session_id
      AND cb.status IN ('confirmed', 'waitlisted')
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.book_class_session(
  p_org_id uuid,
  p_session_id uuid,
  p_member_id uuid,
  p_idempotency_key text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_key text := 'book:' || COALESCE(NULLIF(trim(p_idempotency_key), ''), gen_random_uuid()::text);
  v_branch_id uuid;
  v_existing public.class_bookings%ROWTYPE;
  v_session public.class_sessions%ROWTYPE;
  v_member public.members%ROWTYPE;
  v_booking_id uuid := gen_random_uuid();
  v_consumed boolean;
  v_next_waitlist integer;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  -- Resolve branch and authorize caller BEFORE locking or checking replays (L1)
  SELECT branch_id INTO v_branch_id FROM public.class_sessions
  WHERE id = p_session_id AND organization_id = p_org_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: Class session not found' USING ERRCODE = 'P0002';
  END IF;

  IF NOT authz.is_self_member(p_org_id, p_member_id)
     AND NOT authz.has_permission(p_org_id, v_branch_id, 'booking.manage') THEN
    RAISE EXCEPTION 'FORBIDDEN: Not authorized to book for this member' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_existing
  FROM public.class_bookings
  WHERE organization_id = p_org_id AND idempotency_key = v_key;
  IF FOUND THEN
    IF v_existing.member_id <> p_member_id OR v_existing.session_id <> p_session_id THEN
      RAISE EXCEPTION 'IDEMPOTENCY_KEY_REUSED: Key already used for different booking'
        USING ERRCODE = '23505';
    END IF;
    RETURN jsonb_build_object(
      'booking_id', v_existing.id,
      'status', v_existing.status,
      'waitlist_position', v_existing.waitlist_position,
      'idempotent_replay', true
    );
  END IF;

  -- Canonical lock order: class_sessions first (F6)
  SELECT * INTO v_session
  FROM public.class_sessions
  WHERE id = p_session_id AND organization_id = p_org_id
  FOR UPDATE;

  SELECT * INTO v_member FROM public.members
  WHERE id = p_member_id AND organization_id = p_org_id;
  IF NOT FOUND OR v_member.status <> 'active' THEN
    RAISE EXCEPTION 'MEMBER_INACTIVE: Active member status required to book classes'
      USING ERRCODE = '22023';
  END IF;

  IF v_session.status <> 'scheduled' OR v_session.starts_at <= now() THEN
    RAISE EXCEPTION 'SESSION_CLOSED: Class session is not open for booking'
      USING ERRCODE = '22023';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.class_bookings
    WHERE session_id = p_session_id
      AND member_id = p_member_id
      AND status IN ('confirmed', 'waitlisted')
  ) THEN
    RAISE EXCEPTION 'ALREADY_BOOKED: Member already holds an active or waitlisted booking'
      USING ERRCODE = '23505';
  END IF;

  IF v_session.confirmed_count < v_session.capacity THEN
    INSERT INTO public.class_bookings (
      id, organization_id, branch_id, session_id, member_id,
      status, credit_cost, booked_by, idempotency_key
    ) VALUES (
      v_booking_id, p_org_id, v_session.branch_id, p_session_id, p_member_id,
      'confirmed', v_session.credit_cost, v_actor_id, v_key
    );

    v_consumed := private.consume_member_class_credits(
      p_org_id, v_session.branch_id, v_session.class_type_id,
      p_member_id, v_session.credit_cost, v_booking_id,
      v_key, v_actor_id, 'Class booked: ' || v_session.title
    );

    IF NOT v_consumed THEN
      RAISE EXCEPTION 'INSUFFICIENT_CREDITS: Insufficient eligible class credits or active pass'
        USING ERRCODE = '22023';
    END IF;

    PERFORM set_config('ritma.allow_count_mutation', 'on', true);
    UPDATE public.class_sessions
    SET confirmed_count = confirmed_count + 1
    WHERE id = p_session_id;
    PERFORM set_config('ritma.allow_count_mutation', 'off', true);

    RETURN jsonb_build_object(
      'booking_id', v_booking_id,
      'status', 'confirmed',
      'waitlist_position', NULL,
      'idempotent_replay', false
    );
  ELSIF v_session.waitlist_enabled THEN
    SELECT COALESCE(MAX(waitlist_position), 0) + 1 INTO v_next_waitlist
    FROM public.class_bookings
    WHERE session_id = p_session_id AND status = 'waitlisted';

    INSERT INTO public.class_bookings (
      id, organization_id, branch_id, session_id, member_id,
      status, waitlist_position, credit_cost, booked_by, idempotency_key
    ) VALUES (
      v_booking_id, p_org_id, v_session.branch_id, p_session_id, p_member_id,
      'waitlisted', v_next_waitlist, v_session.credit_cost, v_actor_id, v_key
    );

    RETURN jsonb_build_object(
      'booking_id', v_booking_id,
      'status', 'waitlisted',
      'waitlist_position', v_next_waitlist,
      'idempotent_replay', false
    );
  ELSE
    RAISE EXCEPTION 'CAPACITY_EXCEEDED: Class session is full' USING ERRCODE = '22023';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.cancel_class_booking(
  p_org_id uuid,
  p_booking_id uuid,
  p_reason text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_target_session_id uuid;
  v_target_branch_id uuid;
  v_target_member_id uuid;
  v_session public.class_sessions%ROWTYPE;
  v_booking public.class_bookings%ROWTYPE;
  v_is_early boolean;
  v_new_status text;
  v_refund_row RECORD;
  v_refunded_total integer := 0;
  v_waitlist_row RECORD;
  v_promoted_booking_id uuid;
  v_promoted boolean;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  SELECT session_id, branch_id, member_id
  INTO v_target_session_id, v_target_branch_id, v_target_member_id
  FROM public.class_bookings
  WHERE id = p_booking_id AND organization_id = p_org_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: Booking not found' USING ERRCODE = 'P0002';
  END IF;

  -- Authorize BEFORE acquiring locks (L1)
  IF NOT authz.is_self_member(p_org_id, v_target_member_id)
     AND NOT authz.has_permission(p_org_id, v_target_branch_id, 'booking.manage') THEN
    RAISE EXCEPTION 'FORBIDDEN: Not authorized to cancel this booking' USING ERRCODE = '42501';
  END IF;

  -- Canonical lock order: class_sessions -> class_bookings -> credit_grants (F6, L3)
  SELECT * INTO v_session
  FROM public.class_sessions
  WHERE id = v_target_session_id AND organization_id = p_org_id
  FOR UPDATE;

  SELECT * INTO v_booking
  FROM public.class_bookings
  WHERE id = p_booking_id AND organization_id = p_org_id
  FOR UPDATE;

  IF v_booking.status IN ('cancelled_early', 'cancelled_late', 'expired_unpromoted') THEN
    RETURN jsonb_build_object('status', v_booking.status, 'idempotent_replay', true);
  END IF;

  IF v_booking.status = 'waitlisted' THEN
    UPDATE public.class_bookings
    SET status = 'cancelled_early', waitlist_position = NULL, cancelled_at = now()
    WHERE id = p_booking_id;
    RETURN jsonb_build_object('status', 'cancelled_early', 'refunded_credits', 0, 'promoted_booking_id', NULL);
  END IF;

  v_is_early := now() <= v_session.cancellation_cutoff_at;
  v_new_status := CASE WHEN v_is_early THEN 'cancelled_early' ELSE 'cancelled_late' END;

  UPDATE public.class_bookings
  SET status = v_new_status, cancelled_at = now()
  WHERE id = p_booking_id;

  PERFORM set_config('ritma.allow_count_mutation', 'on', true);
  UPDATE public.class_sessions
  SET confirmed_count = GREATEST(confirmed_count - 1, 0)
  WHERE id = v_session.id;
  PERFORM set_config('ritma.allow_count_mutation', 'off', true);

  -- Lock grants in canonical FIFO + id order matching consumption (L3) and never revive revoked grants (L4)
  IF v_is_early THEN
    FOR v_refund_row IN
      SELECT cg.id AS grant_id, cg.status AS grant_status, cg.expires_at, (-cle.delta) AS consumed_amount
      FROM public.credit_ledger_entries cle
      JOIN public.credit_grants cg ON cg.id = cle.grant_id
      WHERE cle.organization_id = p_org_id
        AND cle.reference_type = 'class_booking'
        AND cle.reference_id = p_booking_id
        AND cle.entry_type = 'consume'
      ORDER BY cg.expires_at ASC NULLS LAST, cg.created_at ASC, cg.id ASC
      FOR UPDATE OF cg
    LOOP
      IF v_refund_row.grant_status IN ('active', 'depleted')
         AND (v_refund_row.expires_at IS NULL OR v_refund_row.expires_at > now()) THEN
        UPDATE public.credit_grants
        SET remaining_amount = remaining_amount + v_refund_row.consumed_amount, status = 'active'
        WHERE id = v_refund_row.grant_id;

        INSERT INTO public.credit_ledger_entries (
          organization_id, member_id, grant_id, credit_type, entry_type, delta,
          reference_type, reference_id, idempotency_key, reason, actor_user_id
        ) VALUES (
          p_org_id, v_booking.member_id, v_refund_row.grant_id, 'class_credit', 'refund',
          v_refund_row.consumed_amount, 'class_booking', p_booking_id,
          'refund:' || p_booking_id::text || ':' || v_refund_row.grant_id::text,
          COALESCE(NULLIF(trim(p_reason), ''), 'Early class cancellation refund'),
          v_actor_id
        );

        v_refunded_total := v_refunded_total + v_refund_row.consumed_amount;
      END IF;
    END LOOP;
  END IF;

  IF v_session.status = 'scheduled' AND now() < v_session.starts_at THEN
    FOR v_waitlist_row IN
      SELECT cb.*
      FROM public.class_bookings cb
      JOIN public.members m ON m.id = cb.member_id
      WHERE cb.session_id = v_session.id
        AND cb.organization_id = p_org_id
        AND cb.status = 'waitlisted'
        AND m.status = 'active'
      ORDER BY cb.waitlist_position ASC NULLS LAST, cb.booked_at ASC
      FOR UPDATE OF cb
    LOOP
      v_promoted := private.consume_member_class_credits(
        p_org_id, v_session.branch_id, v_session.class_type_id,
        v_waitlist_row.member_id, v_session.credit_cost, v_waitlist_row.id,
        'promote:' || v_waitlist_row.id::text, v_actor_id,
        'Waitlist promoted: ' || v_session.title
      );

      IF v_promoted THEN
        UPDATE public.class_bookings
        SET status = 'confirmed', waitlist_position = NULL, credit_cost = v_session.credit_cost
        WHERE id = v_waitlist_row.id;

        PERFORM set_config('ritma.allow_count_mutation', 'on', true);
        UPDATE public.class_sessions
        SET confirmed_count = confirmed_count + 1
        WHERE id = v_session.id;
        PERFORM set_config('ritma.allow_count_mutation', 'off', true);

        v_promoted_booking_id := v_waitlist_row.id;

        INSERT INTO public.audit_logs (
          organization_id, branch_id, actor_user_id, action, target_type, target_id, metadata
        ) VALUES (
          p_org_id, v_session.branch_id, v_actor_id, 'waitlist.promoted',
          'class_booking', v_waitlist_row.id,
          jsonb_build_object('session_id', v_session.id, 'member_id', v_waitlist_row.member_id)
        );
        EXIT;
      ELSE
        INSERT INTO public.audit_logs (
          organization_id, branch_id, actor_user_id, action, target_type, target_id, metadata
        ) VALUES (
          p_org_id, v_session.branch_id, v_actor_id, 'waitlist.skipped_insufficient_credits',
          'class_booking', v_waitlist_row.id,
          jsonb_build_object('session_id', v_session.id, 'member_id', v_waitlist_row.member_id)
        );
      END IF;
    END LOOP;
  END IF;

  RETURN jsonb_build_object(
    'status', v_new_status,
    'refunded_credits', v_refunded_total,
    'promoted_booking_id', v_promoted_booking_id
  );
END;
$$;

-- Cancel an entire class session and atomically refund all confirmed bookings (M7).
CREATE OR REPLACE FUNCTION public.cancel_class_session(
  p_org_id uuid,
  p_session_id uuid,
  p_reason text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_session public.class_sessions%ROWTYPE;
  v_booking RECORD;
  v_refund_row RECORD;
  v_cancelled_count integer := 0;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_session
  FROM public.class_sessions
  WHERE id = p_session_id AND organization_id = p_org_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: Session not found' USING ERRCODE = 'P0002';
  END IF;

  IF NOT authz.has_permission(p_org_id, v_session.branch_id, 'schedule.manage') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing schedule.manage permission' USING ERRCODE = '42501';
  END IF;

  IF v_session.status = 'cancelled' THEN
    RETURN jsonb_build_object('status', 'cancelled', 'idempotent_replay', true);
  END IF;

  FOR v_booking IN
    SELECT * FROM public.class_bookings
    WHERE session_id = p_session_id AND organization_id = p_org_id
      AND status IN ('confirmed', 'waitlisted')
    ORDER BY id ASC
    FOR UPDATE
  LOOP
    IF v_booking.status = 'confirmed' THEN
      FOR v_refund_row IN
        SELECT cg.id AS grant_id, cg.status AS grant_status, cg.expires_at, (-cle.delta) AS consumed_amount
        FROM public.credit_ledger_entries cle
        JOIN public.credit_grants cg ON cg.id = cle.grant_id
        WHERE cle.organization_id = p_org_id
          AND cle.reference_type = 'class_booking'
          AND cle.reference_id = v_booking.id
          AND cle.entry_type = 'consume'
        ORDER BY cg.expires_at ASC NULLS LAST, cg.created_at ASC, cg.id ASC
        FOR UPDATE OF cg
      LOOP
        IF v_refund_row.grant_status IN ('active', 'depleted')
           AND (v_refund_row.expires_at IS NULL OR v_refund_row.expires_at > now()) THEN
          UPDATE public.credit_grants
          SET remaining_amount = remaining_amount + v_refund_row.consumed_amount, status = 'active'
          WHERE id = v_refund_row.grant_id;

          INSERT INTO public.credit_ledger_entries (
            organization_id, member_id, grant_id, credit_type, entry_type, delta,
            reference_type, reference_id, idempotency_key, reason, actor_user_id
          ) VALUES (
            p_org_id, v_booking.member_id, v_refund_row.grant_id, 'class_credit', 'refund',
            v_refund_row.consumed_amount, 'class_booking', v_booking.id,
            'refund:' || v_booking.id::text || ':' || v_refund_row.grant_id::text,
            COALESCE(NULLIF(trim(p_reason), ''), 'Class session cancelled by studio'),
            v_actor_id
          );
        END IF;
      END LOOP;
    END IF;

    UPDATE public.class_bookings
    SET status = 'cancelled_early', waitlist_position = NULL, cancelled_at = now()
    WHERE id = v_booking.id;
    v_cancelled_count := v_cancelled_count + 1;
  END LOOP;

  PERFORM set_config('ritma.allow_session_cancel', 'on', true);
  PERFORM set_config('ritma.allow_count_mutation', 'on', true);
  UPDATE public.class_sessions
  SET status = 'cancelled', confirmed_count = 0
  WHERE id = p_session_id;
  PERFORM set_config('ritma.allow_count_mutation', 'off', true);
  PERFORM set_config('ritma.allow_session_cancel', 'off', true);

  INSERT INTO public.audit_logs (
    organization_id, branch_id, actor_user_id, action, target_type, target_id, metadata
  ) VALUES (
    p_org_id, v_session.branch_id, v_actor_id, 'session.cancelled', 'class_session', p_session_id,
    jsonb_build_object('cancelled_bookings', v_cancelled_count, 'reason', p_reason)
  );

  RETURN jsonb_build_object('status', 'cancelled', 'cancelled_bookings', v_cancelled_count);
END;
$$;

CREATE OR REPLACE FUNCTION public.mark_class_attendance(
  p_org_id uuid,
  p_booking_id uuid,
  p_attendance_status text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_booking public.class_bookings%ROWTYPE;
  v_session public.class_sessions%ROWTYPE;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  IF p_attendance_status NOT IN ('pending', 'checked_in', 'no_show') THEN
    RAISE EXCEPTION 'VALIDATION_ERROR: Invalid attendance status' USING ERRCODE = '22023';
  END IF;

  SELECT * INTO v_booking
  FROM public.class_bookings
  WHERE id = p_booking_id AND organization_id = p_org_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: Booking not found' USING ERRCODE = 'P0002';
  END IF;

  IF v_booking.status <> 'confirmed' THEN
    RAISE EXCEPTION 'INVALID_STATE: Only confirmed bookings can have attendance marked'
      USING ERRCODE = '22023';
  END IF;

  SELECT * INTO v_session
  FROM public.class_sessions
  WHERE id = v_booking.session_id AND organization_id = p_org_id;

  IF NOT authz.has_permission(p_org_id, v_session.branch_id, 'attendance.mark') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing attendance.mark permission' USING ERRCODE = '42501';
  END IF;

  IF NOT authz.has_permission(p_org_id, v_session.branch_id, 'booking.read')
     AND v_session.instructor_user_id IS DISTINCT FROM v_actor_id THEN
    RAISE EXCEPTION 'FORBIDDEN: Instructors can only mark attendance for their assigned sessions'
      USING ERRCODE = '42501';
  END IF;

  UPDATE public.class_bookings
  SET
    attendance_status = p_attendance_status,
    attendance_marked_at = now(),
    attendance_marked_by = v_actor_id
  WHERE id = p_booking_id;
END;
$$;

-- Live database-backed Owner / Branch Manager KPI RPC using org/branch timezone (L9).
CREATE OR REPLACE FUNCTION public.get_operational_dashboard_metrics(
  p_org_id uuid,
  p_branch_id uuid DEFAULT NULL,
  p_window_days integer DEFAULT 30
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_window integer := LEAST(GREATEST(COALESCE(p_window_days, 30), 1), 365);
  v_tz text;
  v_today_start timestamptz;
  v_active_members integer;
  v_today_visits integer;
  v_window_revenue bigint;
  v_total_capacity integer;
  v_total_confirmed integer;
  v_expiring_7d integer;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  IF p_branch_id IS NULL THEN
    IF NOT authz.has_permission(p_org_id, NULL, 'dashboard.org.read') THEN
      RAISE EXCEPTION 'FORBIDDEN: Missing dashboard.org.read permission' USING ERRCODE = '42501';
    END IF;
    SELECT timezone INTO v_tz FROM public.organizations WHERE id = p_org_id;
  ELSE
    IF NOT authz.has_permission(p_org_id, p_branch_id, 'dashboard.branch.read') THEN
      RAISE EXCEPTION 'FORBIDDEN: Missing dashboard.branch.read permission' USING ERRCODE = '42501';
    END IF;
    SELECT COALESCE(b.timezone, o.timezone) INTO v_tz
    FROM public.branches b
    JOIN public.organizations o ON o.id = b.organization_id
    WHERE b.id = p_branch_id AND b.organization_id = p_org_id;
  END IF;

  v_tz := COALESCE(v_tz, 'UTC');
  v_today_start := date_trunc('day', now() AT TIME ZONE v_tz) AT TIME ZONE v_tz;

  SELECT COUNT(*) INTO v_active_members
  FROM public.members m
  WHERE m.organization_id = p_org_id
    AND m.status = 'active'
    AND (p_branch_id IS NULL OR m.home_branch_id = p_branch_id);

  SELECT COUNT(*) INTO v_today_visits
  FROM public.facility_visits fv
  WHERE fv.organization_id = p_org_id
    AND (p_branch_id IS NULL OR fv.branch_id = p_branch_id)
    AND fv.checked_in_at >= v_today_start;

  SELECT COALESCE(SUM(pr.amount_minor), 0) INTO v_window_revenue
  FROM public.payment_records pr
  WHERE pr.organization_id = p_org_id
    AND (p_branch_id IS NULL OR pr.branch_id = p_branch_id)
    AND pr.status = 'paid'
    AND pr.paid_at >= now() - make_interval(days => v_window);

  SELECT
    COALESCE(SUM(cs.capacity), 0),
    COALESCE(SUM(cs.confirmed_count), 0)
  INTO v_total_capacity, v_total_confirmed
  FROM public.class_sessions cs
  WHERE cs.organization_id = p_org_id
    AND (p_branch_id IS NULL OR cs.branch_id = p_branch_id)
    AND cs.status <> 'cancelled'
    AND cs.starts_at >= now() - make_interval(days => v_window)
    AND cs.starts_at <= now() + interval '7 days';

  SELECT COUNT(*) INTO v_expiring_7d
  FROM public.member_entitlements me
  JOIN public.members m ON m.id = me.member_id AND m.organization_id = me.organization_id
  WHERE me.organization_id = p_org_id
    AND (p_branch_id IS NULL OR m.home_branch_id = p_branch_id)
    AND me.status = 'active'
    AND me.valid_until > now()
    AND me.valid_until <= now() + interval '7 days';

  RETURN jsonb_build_object(
    'active_members', v_active_members,
    'today_visits', v_today_visits,
    'window_revenue_minor', v_window_revenue,
    'class_capacity_total', v_total_capacity,
    'class_confirmed_total', v_total_confirmed,
    'class_occupancy_pct', CASE WHEN v_total_capacity > 0
      THEN round((v_total_confirmed::numeric / v_total_capacity::numeric) * 100, 1)
      ELSE 0 END,
    'expiring_entitlements_7d', v_expiring_7d
  );
END;
$$;

REVOKE ALL ON FUNCTION public.get_session_roster(uuid, uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.book_class_session(uuid, uuid, uuid, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.cancel_class_booking(uuid, uuid, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.cancel_class_session(uuid, uuid, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.mark_class_attendance(uuid, uuid, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.get_operational_dashboard_metrics(uuid, uuid, integer) FROM PUBLIC, anon;

GRANT EXECUTE ON FUNCTION public.get_session_roster(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.book_class_session(uuid, uuid, uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.cancel_class_booking(uuid, uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.cancel_class_session(uuid, uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.mark_class_attendance(uuid, uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_operational_dashboard_metrics(uuid, uuid, integer) TO authenticated;

REVOKE TRUNCATE, TRIGGER, REFERENCES ON ALL TABLES IN SCHEMA public FROM anon, authenticated;
