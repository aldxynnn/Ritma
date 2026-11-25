-- =============================================================================
-- Migration 20261125044138: Complete Audit Remediation, Security & Workflows
--
-- Addresses:
--   A. Personal Trainer: strict trainer session ownership, safe PT client lookup
--      RPC, resolved member names without PII exposure, and cancel_pt_session
--      with atomic PT credit refund + audit log.
--   B. Instructor & Class Assignment: strict class_sessions SELECT RLS isolating
--      instructors from unassigned classes, plus list_assignable_instructors RPC.
--   C. Package Selected Branches: server-side guard requiring >=1 branch row on
--      selected_branches package rules + atomic update_package_details RPC.
--   H. Report Export: permission- and branch-scoped get_report_export_data RPC.
--   I. Payment Refunds: append-only payment_refunds ledger, payment_records
--      refund tracking, manual_recorded channel enforcement, record_payment_refund
--      RPC, and net revenue calculation in get_operational_dashboard_metrics.
--   J. Staff Management: list_organization_staff, list_organization_invitations,
--      revoke_organization_invitation, and update_organization_settings RPCs.
--   + Operational notification hooks for PT sessions & equipment tickets.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Personal Training Ownership, Safe Client Lookup & Cancellation Refunds
-- -----------------------------------------------------------------------------

DROP POLICY IF EXISTS pt_sessions_select ON public.pt_sessions;
CREATE POLICY pt_sessions_select ON public.pt_sessions
  FOR SELECT TO authenticated
  USING (
    authz.is_self_member(organization_id, member_id)
    OR authz.has_permission(organization_id, branch_id, 'schedule.manage')
    OR authz.has_permission(organization_id, branch_id, 'booking.read')
    OR (
      authz.has_permission(organization_id, branch_id, 'pt.manage')
      AND EXISTS (
        SELECT 1
        FROM public.trainer_profiles tp
        WHERE tp.id = pt_sessions.trainer_id
          AND tp.organization_id = pt_sessions.organization_id
          AND tp.user_id = (SELECT auth.uid())
      )
    )
  );

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
  v_is_self boolean;
  v_is_ops_mgr boolean;
  v_is_owning_trainer boolean;
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

  v_branch_id := v_trainer.home_branch_id;
  IF p_branch_id IS NOT NULL AND p_branch_id IS DISTINCT FROM v_branch_id THEN
    RAISE EXCEPTION 'VALIDATION_ERROR: Trainer does not operate at requested branch'
      USING ERRCODE = '22023';
  END IF;

  v_is_self := authz.is_self_member(p_org_id, p_member_id);
  v_is_ops_mgr := authz.has_permission(p_org_id, v_branch_id, 'schedule.manage')
    OR authz.has_permission(p_org_id, v_branch_id, 'booking.manage');
  v_is_owning_trainer := authz.has_permission(p_org_id, v_branch_id, 'pt.manage')
    AND v_trainer.user_id = v_actor_id;

  IF NOT v_is_self AND NOT v_is_ops_mgr AND NOT v_is_owning_trainer THEN
    IF authz.has_permission(p_org_id, v_branch_id, 'pt.manage') THEN
      RAISE EXCEPTION 'FORBIDDEN: Personal trainers can only book sessions for themselves'
        USING ERRCODE = '42501';
    END IF;
    RAISE EXCEPTION 'FORBIDDEN: Not authorized to book PT session' USING ERRCODE = '42501';
  END IF;

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
    RETURN jsonb_build_object(
      'pt_session_id', v_existing.id,
      'status', v_existing.status,
      'credit_cost', v_existing.credit_cost,
      'idempotent_replay', true
    );
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

  RETURN jsonb_build_object(
    'pt_session_id', v_pt_id,
    'status', 'scheduled',
    'credit_cost', v_cost,
    'idempotent_replay', false
  );
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
  v_is_owning_trainer boolean;
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

  SELECT EXISTS (
    SELECT 1 FROM public.trainer_profiles tp
    WHERE tp.id = v_pt.trainer_id
      AND tp.organization_id = p_org_id
      AND tp.user_id = v_actor_id
  ) INTO v_is_owning_trainer;

  IF NOT authz.has_permission(p_org_id, v_pt.branch_id, 'schedule.manage') THEN
    IF NOT authz.has_permission(p_org_id, v_pt.branch_id, 'pt.manage') THEN
      RAISE EXCEPTION 'FORBIDDEN: Missing pt.manage permission' USING ERRCODE = '42501';
    END IF;
    IF NOT v_is_owning_trainer THEN
      RAISE EXCEPTION 'FORBIDDEN: Personal trainers can only complete their own PT sessions'
        USING ERRCODE = '42501';
    END IF;
  END IF;

  IF v_pt.status <> 'scheduled' THEN
    RAISE EXCEPTION 'INVALID_STATE: Only scheduled PT sessions can be completed' USING ERRCODE = '22023';
  END IF;

  UPDATE public.pt_sessions
  SET status = 'completed', notes = COALESCE(NULLIF(trim(p_notes), ''), notes)
  WHERE id = p_pt_session_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.cancel_pt_session(
  p_org_id uuid,
  p_pt_session_id uuid,
  p_reason text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_pt public.pt_sessions%ROWTYPE;
  v_is_self boolean;
  v_is_ops_mgr boolean;
  v_is_owning_trainer boolean;
  v_is_early boolean;
  v_new_status text;
  v_refund_row RECORD;
  v_refunded_total integer := 0;
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

  v_is_self := authz.is_self_member(p_org_id, v_pt.member_id);
  v_is_ops_mgr := authz.has_permission(p_org_id, v_pt.branch_id, 'schedule.manage')
    OR authz.has_permission(p_org_id, v_pt.branch_id, 'booking.manage');
  SELECT (
    authz.has_permission(p_org_id, v_pt.branch_id, 'pt.manage')
    AND EXISTS (
      SELECT 1 FROM public.trainer_profiles tp
      WHERE tp.id = v_pt.trainer_id
        AND tp.organization_id = p_org_id
        AND tp.user_id = v_actor_id
    )
  ) INTO v_is_owning_trainer;

  IF NOT v_is_self AND NOT v_is_ops_mgr AND NOT v_is_owning_trainer THEN
    RAISE EXCEPTION 'FORBIDDEN: Not authorized to cancel this PT session' USING ERRCODE = '42501';
  END IF;

  IF v_pt.status IN ('cancelled_early', 'cancelled_late') THEN
    RETURN jsonb_build_object(
      'status', v_pt.status,
      'refunded_credits', 0,
      'idempotent_replay', true
    );
  END IF;

  IF v_pt.status <> 'scheduled' THEN
    RAISE EXCEPTION 'INVALID_STATE: Only scheduled PT sessions can be cancelled'
      USING ERRCODE = '22023';
  END IF;

  v_is_early := (now() <= v_pt.starts_at - interval '2 hours') OR (v_is_ops_mgr OR v_is_owning_trainer);
  v_new_status := CASE WHEN v_is_early THEN 'cancelled_early' ELSE 'cancelled_late' END;

  UPDATE public.pt_sessions
  SET
    status = v_new_status,
    notes = CASE
      WHEN NULLIF(trim(p_reason), '') IS NOT NULL THEN
        CASE
          WHEN notes IS NOT NULL AND trim(notes) <> '' THEN notes || E'\nCancelled: ' || trim(p_reason)
          ELSE 'Cancelled: ' || trim(p_reason)
        END
      ELSE notes
    END
  WHERE id = p_pt_session_id;

  IF v_is_early THEN
    FOR v_refund_row IN
      SELECT cg.id AS grant_id, cg.status AS grant_status, cg.expires_at, (-cle.delta) AS consumed_amount
      FROM public.credit_ledger_entries cle
      JOIN public.credit_grants cg ON cg.id = cle.grant_id
      WHERE cle.organization_id = p_org_id
        AND cle.reference_type = 'pt_session'
        AND cle.reference_id = p_pt_session_id
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
          p_org_id, v_pt.member_id, v_refund_row.grant_id, 'pt_credit', 'refund',
          v_refund_row.consumed_amount, 'pt_session', p_pt_session_id,
          'refund_pt:' || p_pt_session_id::text || ':' || v_refund_row.grant_id::text,
          COALESCE(NULLIF(trim(p_reason), ''), 'PT session cancelled refund'),
          v_actor_id
        );

        v_refunded_total := v_refunded_total + v_refund_row.consumed_amount;
      END IF;
    END LOOP;
  END IF;

  INSERT INTO public.audit_logs (
    organization_id, branch_id, actor_user_id, action, target_type, target_id, metadata
  ) VALUES (
    p_org_id, v_pt.branch_id, v_actor_id, 'pt_session.cancelled', 'pt_session', p_pt_session_id,
    jsonb_build_object('status', v_new_status, 'refunded_credits', v_refunded_total, 'reason', NULLIF(trim(p_reason), ''))
  );

  RETURN jsonb_build_object(
    'status', v_new_status,
    'refunded_credits', v_refunded_total,
    'idempotent_replay', false
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.get_pt_sessions_for_workspace(
  p_org_id uuid,
  p_branch_id uuid DEFAULT NULL,
  p_member_id uuid DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_is_ops_mgr boolean;
  v_is_trainer boolean;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  IF p_member_id IS NOT NULL THEN
    IF NOT authz.is_self_member(p_org_id, p_member_id)
       AND NOT authz.has_permission(p_org_id, p_branch_id, 'schedule.manage')
       AND NOT authz.has_permission(p_org_id, p_branch_id, 'booking.read') THEN
      RAISE EXCEPTION 'FORBIDDEN: Not authorized to view member PT sessions' USING ERRCODE = '42501';
    END IF;

    RETURN (
      SELECT COALESCE(
        jsonb_agg(
          jsonb_build_object(
            'id', pt.id,
            'organization_id', pt.organization_id,
            'branch_id', pt.branch_id,
            'trainer_id', pt.trainer_id,
            'trainer_user_id', tp.user_id,
            'member_id', pt.member_id,
            'starts_at', pt.starts_at,
            'ends_at', pt.ends_at,
            'credit_cost', pt.credit_cost,
            'status', pt.status,
            'notes', pt.notes,
            'trainer_display_name', tp.display_name,
            'member_display_name', m.full_name,
            'member_code', m.member_code
          )
          ORDER BY pt.starts_at ASC
        ),
        '[]'::jsonb
      )
      FROM public.pt_sessions pt
      JOIN public.trainer_profiles tp ON tp.id = pt.trainer_id AND tp.organization_id = pt.organization_id
      JOIN public.members m ON m.id = pt.member_id AND m.organization_id = pt.organization_id
      WHERE pt.organization_id = p_org_id
        AND pt.member_id = p_member_id
        AND (p_branch_id IS NULL OR pt.branch_id = p_branch_id)
    );
  END IF;

  v_is_ops_mgr := authz.has_permission(p_org_id, p_branch_id, 'schedule.manage')
    OR authz.has_permission(p_org_id, p_branch_id, 'booking.read');

  IF v_is_ops_mgr THEN
    RETURN (
      SELECT COALESCE(
        jsonb_agg(
          jsonb_build_object(
            'id', pt.id,
            'organization_id', pt.organization_id,
            'branch_id', pt.branch_id,
            'trainer_id', pt.trainer_id,
            'trainer_user_id', tp.user_id,
            'member_id', pt.member_id,
            'starts_at', pt.starts_at,
            'ends_at', pt.ends_at,
            'credit_cost', pt.credit_cost,
            'status', pt.status,
            'notes', pt.notes,
            'trainer_display_name', tp.display_name,
            'member_display_name', m.full_name,
            'member_code', m.member_code
          )
          ORDER BY pt.starts_at ASC
        ),
        '[]'::jsonb
      )
      FROM public.pt_sessions pt
      JOIN public.trainer_profiles tp ON tp.id = pt.trainer_id AND tp.organization_id = pt.organization_id
      JOIN public.members m ON m.id = pt.member_id AND m.organization_id = pt.organization_id
      WHERE pt.organization_id = p_org_id
        AND (p_branch_id IS NULL OR pt.branch_id = p_branch_id)
    );
  END IF;

  v_is_trainer := CASE
    WHEN p_branch_id IS NULL THEN authz.has_any_branch_permission(p_org_id, 'pt.manage')
    ELSE authz.has_permission(p_org_id, p_branch_id, 'pt.manage')
  END;

  IF NOT v_is_trainer THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing PT workspace permission' USING ERRCODE = '42501';
  END IF;

  RETURN (
    SELECT COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'id', pt.id,
          'organization_id', pt.organization_id,
          'branch_id', pt.branch_id,
          'trainer_id', pt.trainer_id,
          'trainer_user_id', tp.user_id,
          'member_id', pt.member_id,
          'starts_at', pt.starts_at,
          'ends_at', pt.ends_at,
          'credit_cost', pt.credit_cost,
          'status', pt.status,
          'notes', pt.notes,
          'trainer_display_name', tp.display_name,
          'member_display_name', m.full_name,
          'member_code', m.member_code
        )
        ORDER BY pt.starts_at ASC
      ),
      '[]'::jsonb
    )
    FROM public.pt_sessions pt
    JOIN public.trainer_profiles tp ON tp.id = pt.trainer_id AND tp.organization_id = pt.organization_id
    JOIN public.members m ON m.id = pt.member_id AND m.organization_id = pt.organization_id
    WHERE pt.organization_id = p_org_id
      AND tp.user_id = v_actor_id
      AND (p_branch_id IS NULL OR pt.branch_id = p_branch_id)
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.lookup_members_for_pt_booking(
  p_org_id uuid,
  p_branch_id uuid,
  p_query text DEFAULT ''
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_clean text := trim(COALESCE(p_query, ''));
  v_q text := '%' || replace(replace(replace(v_clean, '\', '\\'), '%', '\%'), '_', '\_') || '%';
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  IF NOT authz.has_permission(p_org_id, p_branch_id, 'pt.manage')
     AND NOT authz.has_permission(p_org_id, p_branch_id, 'schedule.manage')
     AND NOT authz.has_permission(p_org_id, p_branch_id, 'booking.manage') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing PT booking authorization for this branch' USING ERRCODE = '42501';
  END IF;

  RETURN (
    SELECT COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'id', row_data.id,
          'member_code', row_data.member_code,
          'full_name', row_data.full_name,
          'home_branch_id', row_data.home_branch_id,
          'status', row_data.status,
          'available_pt_credits', row_data.available_pt_credits
        )
        ORDER BY row_data.available_pt_credits DESC, row_data.full_name ASC
      ),
      '[]'::jsonb
    )
    FROM (
      SELECT
        m.id,
        m.member_code,
        m.full_name,
        m.home_branch_id,
        m.status,
        COALESCE((
          SELECT SUM(cg.remaining_amount)::integer
          FROM public.credit_grants cg
          LEFT JOIN public.member_subscriptions ms ON ms.id = cg.subscription_id
          WHERE cg.organization_id = p_org_id
            AND cg.member_id = m.id
            AND cg.credit_type = 'pt_credit'
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
        ), 0) AS available_pt_credits
      FROM public.members m
      WHERE m.organization_id = p_org_id
        AND m.status = 'active'
        AND (
          v_clean = ''
          OR m.full_name ILIKE v_q ESCAPE '\'
          OR m.member_code ILIKE v_q ESCAPE '\'
        )
      ORDER BY available_pt_credits DESC, m.full_name ASC
      LIMIT 30
    ) row_data
  );
END;
$$;

-- -----------------------------------------------------------------------------
-- 2. Instructor Class Session Isolation & Assignable Instructors Lookup
-- -----------------------------------------------------------------------------

DROP POLICY IF EXISTS class_sessions_select ON public.class_sessions;
CREATE POLICY class_sessions_select ON public.class_sessions
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.members m
      WHERE m.organization_id = class_sessions.organization_id
        AND m.user_id = (SELECT auth.uid())
        AND m.status IN ('active', 'frozen')
    )
    OR authz.has_permission(organization_id, branch_id, 'schedule.manage')
    OR authz.has_permission(organization_id, branch_id, 'booking.read')
    OR (
      authz.has_permission(organization_id, branch_id, 'attendance.mark')
      AND instructor_user_id = (SELECT auth.uid())
    )
  );

CREATE OR REPLACE FUNCTION public.list_assignable_instructors(
  p_org_id uuid,
  p_branch_id uuid DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  IF NOT authz.has_permission(p_org_id, p_branch_id, 'schedule.manage') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing schedule.manage permission' USING ERRCODE = '42501';
  END IF;

  RETURN (
    SELECT COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'user_id', chosen.user_id,
          'display_name', chosen.display_name,
          'role_code', chosen.role_code,
          'role_display_name', chosen.role_display_name
        )
        ORDER BY chosen.priority ASC, chosen.display_name ASC
      ),
      '[]'::jsonb
    )
    FROM (
      SELECT DISTINCT ON (ura.user_id)
        ura.user_id,
        COALESCE(
          NULLIF(trim(tp.display_name), ''),
          NULLIF(trim(up.full_name), ''),
          'Staff ' || left(ura.user_id::text, 8)
        ) AS display_name,
        r.code AS role_code,
        r.display_name AS role_display_name,
        CASE r.code
          WHEN 'instructor' THEN 1
          WHEN 'personal_trainer' THEN 2
          WHEN 'branch_manager' THEN 3
          WHEN 'org_admin' THEN 4
          WHEN 'org_owner' THEN 5
          ELSE 6
        END AS priority
      FROM public.user_role_assignments ura
      JOIN public.roles r ON r.id = ura.role_id
      LEFT JOIN public.user_profiles up ON up.user_id = ura.user_id
      LEFT JOIN public.trainer_profiles tp
        ON tp.organization_id = ura.organization_id AND tp.user_id = ura.user_id AND tp.is_active = true
      WHERE ura.organization_id = p_org_id
        AND ura.status = 'active'
        AND r.code <> 'member'
        AND (
          ura.branch_id IS NULL
          OR p_branch_id IS NULL
          OR ura.branch_id = p_branch_id
        )
      ORDER BY ura.user_id, priority ASC, r.rank DESC
    ) chosen
  );
END;
$$;

-- -----------------------------------------------------------------------------
-- 3. Package Selected-Branches Integrity & Atomic Update
-- -----------------------------------------------------------------------------

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

  IF EXISTS (
    SELECT 1
    FROM public.package_entitlement_rules per
    WHERE per.organization_id = p_org_id
      AND per.package_id = p_package_id
      AND per.branch_access_scope = 'selected_branches'
      AND NOT EXISTS (
        SELECT 1 FROM public.package_rule_branches prb
        WHERE prb.organization_id = p_org_id AND prb.rule_id = per.id
      )
  ) THEN
    RAISE EXCEPTION 'VALIDATION_ERROR: Selected-branches package rule has no configured branches'
      USING ERRCODE = '22023';
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

CREATE OR REPLACE FUNCTION public.update_package_details(
  p_org_id uuid,
  p_package_id uuid,
  p_name text,
  p_description text DEFAULT '',
  p_price_minor bigint DEFAULT NULL,
  p_is_active boolean DEFAULT true,
  p_branch_access_scope text DEFAULT NULL,
  p_allowed_branch_ids uuid[] DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_pkg public.packages%ROWTYPE;
  v_rule RECORD;
  v_branch_id uuid;
  v_valid_branch_count integer := 0;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  IF NOT authz.has_permission(p_org_id, NULL, 'package.manage') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing package.manage permission' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_pkg
  FROM public.packages
  WHERE id = p_package_id AND organization_id = p_org_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: Package not found in organization' USING ERRCODE = 'P0002';
  END IF;

  IF char_length(trim(COALESCE(p_name, ''))) < 2 THEN
    RAISE EXCEPTION 'VALIDATION_ERROR: Package name must be at least 2 characters' USING ERRCODE = '22023';
  END IF;

  IF p_price_minor IS NOT NULL AND p_price_minor < 0 THEN
    RAISE EXCEPTION 'VALIDATION_ERROR: Price must be zero or positive' USING ERRCODE = '22023';
  END IF;

  IF p_branch_access_scope IS NOT NULL THEN
    IF p_branch_access_scope NOT IN ('single_branch', 'selected_branches', 'all_branches') THEN
      RAISE EXCEPTION 'VALIDATION_ERROR: Invalid branch_access_scope' USING ERRCODE = '22023';
    END IF;
    IF p_branch_access_scope = 'selected_branches' THEN
      SELECT COUNT(*) INTO v_valid_branch_count
      FROM public.branches b
      WHERE b.organization_id = p_org_id
        AND b.id = ANY(COALESCE(p_allowed_branch_ids, '{}'::uuid[]));
      IF v_valid_branch_count < 1 THEN
        RAISE EXCEPTION 'VALIDATION_ERROR: Select at least one valid branch for Selected Branches access'
          USING ERRCODE = '22023';
      END IF;
    END IF;
  END IF;

  UPDATE public.packages
  SET
    name = trim(p_name),
    description = COALESCE(trim(p_description), ''),
    price_minor = COALESCE(p_price_minor, price_minor),
    is_active = COALESCE(p_is_active, is_active)
  WHERE id = p_package_id;

  IF p_branch_access_scope IS NOT NULL THEN
    FOR v_rule IN
      SELECT id FROM public.package_entitlement_rules
      WHERE organization_id = p_org_id AND package_id = p_package_id
    LOOP
      UPDATE public.package_entitlement_rules
      SET branch_access_scope = p_branch_access_scope
      WHERE id = v_rule.id;

      DELETE FROM public.package_rule_branches
      WHERE organization_id = p_org_id AND rule_id = v_rule.id;

      IF p_branch_access_scope = 'selected_branches' THEN
        FOREACH v_branch_id IN ARRAY COALESCE(p_allowed_branch_ids, '{}'::uuid[]) LOOP
          IF EXISTS (
            SELECT 1 FROM public.branches b
            WHERE b.id = v_branch_id AND b.organization_id = p_org_id
          ) THEN
            INSERT INTO public.package_rule_branches (organization_id, rule_id, branch_id)
            VALUES (p_org_id, v_rule.id, v_branch_id)
            ON CONFLICT DO NOTHING;
          END IF;
        END LOOP;
      END IF;
    END LOOP;
  END IF;

  INSERT INTO public.audit_logs (
    organization_id, actor_user_id, action, target_type, target_id, metadata
  ) VALUES (
    p_org_id, v_actor_id, 'package.updated', 'package', p_package_id,
    jsonb_build_object(
      'name', trim(p_name),
      'is_active', COALESCE(p_is_active, v_pkg.is_active),
      'branch_access_scope', p_branch_access_scope
    )
  );
END;
$$;

-- -----------------------------------------------------------------------------
-- 4. Payment Refunds, Append-Only Financial Audit Trail & Net Dashboard KPI
-- -----------------------------------------------------------------------------

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'uq_payment_records_org_id'
      AND conrelid = 'public.payment_records'::regclass
  ) THEN
    ALTER TABLE public.payment_records
      ADD CONSTRAINT uq_payment_records_org_id UNIQUE (organization_id, id);
  END IF;
END $$;

ALTER TABLE public.payment_records
  ADD COLUMN IF NOT EXISTS refunded_amount_minor bigint NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS refund_reason text,
  ADD COLUMN IF NOT EXISTS refund_channel text,
  ADD COLUMN IF NOT EXISTS refunded_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS refunded_at timestamptz;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'chk_payment_records_refunded_amount'
      AND conrelid = 'public.payment_records'::regclass
  ) THEN
    ALTER TABLE public.payment_records
      ADD CONSTRAINT chk_payment_records_refunded_amount
      CHECK (refunded_amount_minor >= 0 AND refunded_amount_minor <= amount_minor);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'chk_payment_records_refund_channel'
      AND conrelid = 'public.payment_records'::regclass
  ) THEN
    ALTER TABLE public.payment_records
      ADD CONSTRAINT chk_payment_records_refund_channel
      CHECK (refund_channel IS NULL OR refund_channel IN ('manual_recorded', 'provider_processed'));
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS public.payment_refunds (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  payment_id uuid NOT NULL,
  member_id uuid NOT NULL,
  amount_minor bigint NOT NULL CHECK (amount_minor > 0),
  currency_code text NOT NULL CHECK (char_length(currency_code) = 3),
  refund_channel text NOT NULL DEFAULT 'manual_recorded'
    CHECK (refund_channel IN ('manual_recorded', 'provider_processed')),
  reason text NOT NULL CHECK (char_length(trim(reason)) >= 3),
  external_reference text,
  idempotency_key text NOT NULL,
  refunded_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (organization_id, branch_id)
    REFERENCES public.branches(organization_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (organization_id, payment_id)
    REFERENCES public.payment_records(organization_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (organization_id, member_id)
    REFERENCES public.members(organization_id, id) ON DELETE RESTRICT,
  UNIQUE (organization_id, idempotency_key)
);

CREATE INDEX IF NOT EXISTS idx_payment_refunds_org_payment
  ON public.payment_refunds (organization_id, payment_id, created_at DESC);

DROP TRIGGER IF EXISTS trg_payment_refunds_immutable ON public.payment_refunds;
CREATE TRIGGER trg_payment_refunds_immutable
  BEFORE UPDATE OR DELETE ON public.payment_refunds
  FOR EACH ROW EXECUTE FUNCTION private.prevent_row_mutation();

DROP TRIGGER IF EXISTS trg_payment_refunds_no_truncate ON public.payment_refunds;
CREATE TRIGGER trg_payment_refunds_no_truncate
  BEFORE TRUNCATE ON public.payment_refunds
  FOR EACH STATEMENT EXECUTE FUNCTION private.prevent_row_mutation();

ALTER TABLE public.payment_refunds ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_refunds FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS payment_refunds_select ON public.payment_refunds;
CREATE POLICY payment_refunds_select ON public.payment_refunds
  FOR SELECT TO authenticated
  USING (
    authz.is_self_member(organization_id, member_id)
    OR authz.has_permission(organization_id, branch_id, 'payment.read')
  );

GRANT SELECT ON TABLE public.payment_refunds TO authenticated;
REVOKE TRUNCATE, TRIGGER, REFERENCES ON TABLE public.payment_refunds FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.record_payment_refund(
  p_org_id uuid,
  p_payment_id uuid,
  p_amount_minor bigint,
  p_reason text,
  p_idempotency_key text,
  p_external_reference text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_key text := 'refund:' || COALESCE(NULLIF(trim(p_idempotency_key), ''), gen_random_uuid()::text);
  v_payment public.payment_records%ROWTYPE;
  v_existing_refund public.payment_refunds%ROWTYPE;
  v_refund_id uuid := gen_random_uuid();
  v_new_total_refunded bigint;
  v_new_status text;
  v_clean_reason text := trim(COALESCE(p_reason, ''));
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  IF char_length(v_clean_reason) < 3 THEN
    RAISE EXCEPTION 'VALIDATION_ERROR: Refund reason must be at least 3 characters' USING ERRCODE = '22023';
  END IF;

  IF p_amount_minor IS NULL OR p_amount_minor <= 0 THEN
    RAISE EXCEPTION 'VALIDATION_ERROR: Refund amount must be greater than zero' USING ERRCODE = '22023';
  END IF;

  SELECT * INTO v_payment
  FROM public.payment_records
  WHERE id = p_payment_id AND organization_id = p_org_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: Payment record not found' USING ERRCODE = 'P0002';
  END IF;

  IF NOT authz.has_permission(p_org_id, v_payment.branch_id, 'payment.refund') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing payment.refund permission' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_existing_refund
  FROM public.payment_refunds
  WHERE organization_id = p_org_id AND idempotency_key = v_key;

  IF FOUND THEN
    IF v_existing_refund.payment_id <> p_payment_id OR v_existing_refund.amount_minor <> p_amount_minor THEN
      RAISE EXCEPTION 'IDEMPOTENCY_KEY_REUSED: Refund key already used for a different payment or amount'
        USING ERRCODE = '23505';
    END IF;
    RETURN jsonb_build_object(
      'refund_id', v_existing_refund.id,
      'payment_id', v_payment.id,
      'payment_status', v_payment.status,
      'amount_minor', v_existing_refund.amount_minor,
      'total_refunded_minor', v_payment.refunded_amount_minor,
      'refund_channel', v_existing_refund.refund_channel,
      'idempotent_replay', true
    );
  END IF;

  IF v_payment.status <> 'paid' THEN
    RAISE EXCEPTION 'INVALID_STATE: Only paid records with remaining refundable balance can be refunded'
      USING ERRCODE = '22023';
  END IF;

  IF v_payment.refunded_amount_minor + p_amount_minor > v_payment.amount_minor THEN
    RAISE EXCEPTION 'VALIDATION_ERROR: Refund amount exceeds remaining refundable balance'
      USING ERRCODE = '22023';
  END IF;

  v_new_total_refunded := v_payment.refunded_amount_minor + p_amount_minor;
  v_new_status := CASE
    WHEN v_new_total_refunded >= v_payment.amount_minor THEN 'refunded'
    ELSE 'paid'
  END;

  -- Strictly record as manual_recorded because no external payment gateway API is integrated.
  INSERT INTO public.payment_refunds (
    id, organization_id, branch_id, payment_id, member_id,
    amount_minor, currency_code, refund_channel, reason,
    external_reference, idempotency_key, refunded_by
  ) VALUES (
    v_refund_id, p_org_id, v_payment.branch_id, p_payment_id, v_payment.member_id,
    p_amount_minor, v_payment.currency_code, 'manual_recorded', v_clean_reason,
    NULLIF(trim(p_external_reference), ''), v_key, v_actor_id
  );

  UPDATE public.payment_records
  SET
    refunded_amount_minor = v_new_total_refunded,
    refund_reason = v_clean_reason,
    refund_channel = 'manual_recorded',
    refunded_by = v_actor_id,
    refunded_at = now(),
    status = v_new_status
  WHERE id = p_payment_id;

  INSERT INTO public.audit_logs (
    organization_id, branch_id, actor_user_id, action, target_type, target_id, metadata
  ) VALUES (
    p_org_id, v_payment.branch_id, v_actor_id, 'payment.refund_recorded', 'payment_record', p_payment_id,
    jsonb_build_object(
      'refund_id', v_refund_id,
      'amount_minor', p_amount_minor,
      'total_refunded_minor', v_new_total_refunded,
      'payment_status', v_new_status,
      'refund_channel', 'manual_recorded',
      'reason', v_clean_reason
    )
  );

  RETURN jsonb_build_object(
    'refund_id', v_refund_id,
    'payment_id', p_payment_id,
    'payment_status', v_new_status,
    'amount_minor', p_amount_minor,
    'total_refunded_minor', v_new_total_refunded,
    'refund_channel', 'manual_recorded',
    'idempotent_replay', false
  );
END;
$$;

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

  SELECT COALESCE(SUM(GREATEST(pr.amount_minor - pr.refunded_amount_minor, 0)), 0)
  INTO v_window_revenue
  FROM public.payment_records pr
  WHERE pr.organization_id = p_org_id
    AND (p_branch_id IS NULL OR pr.branch_id = p_branch_id)
    AND pr.status IN ('paid', 'refunded')
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

-- -----------------------------------------------------------------------------
-- 5. Staff Management & Organization Settings RPCs
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.list_organization_staff(
  p_org_id uuid,
  p_branch_id uuid DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  IF NOT authz.has_permission(p_org_id, p_branch_id, 'role.assign') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing role.assign permission in target scope' USING ERRCODE = '42501';
  END IF;

  RETURN (
    SELECT COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'assignment_id', ura.id,
          'user_id', ura.user_id,
          'full_name', COALESCE(NULLIF(trim(up.full_name), ''), au.email, 'Staff User'),
          'email', COALESCE(au.email, ''),
          'role_code', r.code,
          'role_display_name', r.display_name,
          'role_rank', r.rank,
          'branch_id', ura.branch_id,
          'branch_name', b.name,
          'status', ura.status,
          'created_at', ura.created_at,
          'revoked_at', ura.revoked_at
        )
        ORDER BY
          CASE WHEN ura.status = 'active' THEN 0 ELSE 1 END,
          r.rank DESC,
          COALESCE(NULLIF(trim(up.full_name), ''), au.email, '') ASC
      ),
      '[]'::jsonb
    )
    FROM public.user_role_assignments ura
    JOIN public.roles r ON r.id = ura.role_id
    JOIN auth.users au ON au.id = ura.user_id
    LEFT JOIN public.user_profiles up ON up.user_id = ura.user_id
    LEFT JOIN public.branches b ON b.id = ura.branch_id
    WHERE ura.organization_id = p_org_id
      AND (p_branch_id IS NULL OR ura.branch_id = p_branch_id)
      AND (ura.status = 'active' OR ura.revoked_at > now() - interval '30 days')
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.list_organization_invitations(
  p_org_id uuid,
  p_branch_id uuid DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  IF NOT authz.has_permission(p_org_id, p_branch_id, 'role.assign') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing role.assign permission in target scope' USING ERRCODE = '42501';
  END IF;

  RETURN (
    SELECT COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'id', oi.id,
          'invited_email', oi.invited_email,
          'role_code', r.code,
          'role_display_name', r.display_name,
          'role_rank', r.rank,
          'branch_id', oi.branch_id,
          'branch_name', b.name,
          'status', oi.status,
          'expires_at', oi.expires_at,
          'created_at', oi.created_at
        )
        ORDER BY
          CASE oi.status WHEN 'pending' THEN 0 WHEN 'accepted' THEN 1 ELSE 2 END,
          oi.created_at DESC
      ),
      '[]'::jsonb
    )
    FROM public.organization_invitations oi
    JOIN public.roles r ON r.id = oi.role_id
    LEFT JOIN public.branches b ON b.id = oi.branch_id
    WHERE oi.organization_id = p_org_id
      AND (p_branch_id IS NULL OR oi.branch_id = p_branch_id)
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.revoke_organization_invitation(
  p_org_id uuid,
  p_invitation_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_inv public.organization_invitations%ROWTYPE;
  v_role public.roles%ROWTYPE;
  v_caller_rank integer;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_inv
  FROM public.organization_invitations
  WHERE id = p_invitation_id AND organization_id = p_org_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: Invitation not found' USING ERRCODE = 'P0002';
  END IF;

  IF NOT authz.has_permission(p_org_id, v_inv.branch_id, 'role.assign') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing role.assign permission in target scope' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_role FROM public.roles WHERE id = v_inv.role_id;
  v_caller_rank := authz.user_max_role_rank(p_org_id, v_inv.branch_id);
  IF v_caller_rank < 100 AND v_role.rank >= v_caller_rank THEN
    RAISE EXCEPTION 'FORBIDDEN: Cannot revoke invitation for a role equal to or higher than your own rank'
      USING ERRCODE = '42501';
  END IF;

  IF v_inv.status <> 'pending' THEN
    RETURN;
  END IF;

  UPDATE public.organization_invitations
  SET status = 'revoked'
  WHERE id = p_invitation_id;

  INSERT INTO public.audit_logs (
    organization_id, branch_id, actor_user_id, action, target_type, target_id, metadata
  ) VALUES (
    p_org_id, v_inv.branch_id, v_actor_id, 'role.invitation_revoked', 'organization_invitation', p_invitation_id,
    jsonb_build_object('invited_email', v_inv.invited_email, 'role_code', v_role.code)
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.update_organization_settings(
  p_org_id uuid,
  p_name text,
  p_business_type text,
  p_timezone text,
  p_currency_code text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  IF NOT authz.has_permission(p_org_id, NULL, 'org.manage') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing org.manage permission' USING ERRCODE = '42501';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_catalog.pg_timezone_names WHERE name = p_timezone) THEN
    RAISE EXCEPTION 'VALIDATION_ERROR: Invalid timezone %', p_timezone USING ERRCODE = '22023';
  END IF;

  UPDATE public.organizations
  SET
    name = trim(p_name),
    business_type = p_business_type,
    timezone = p_timezone,
    currency_code = upper(trim(p_currency_code))
  WHERE id = p_org_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: Organization not found' USING ERRCODE = 'P0002';
  END IF;

  INSERT INTO public.audit_logs (
    organization_id, actor_user_id, action, target_type, target_id, metadata
  ) VALUES (
    p_org_id, v_actor_id, 'organization.updated', 'organization', p_org_id,
    jsonb_build_object(
      'name', trim(p_name),
      'business_type', p_business_type,
      'timezone', p_timezone,
      'currency_code', upper(trim(p_currency_code))
    )
  );
END;
$$;

-- -----------------------------------------------------------------------------
-- 6. Permission- and Branch-Scoped Report Export RPC
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.get_report_export_data(
  p_org_id uuid,
  p_report_type text,
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
  v_org public.organizations%ROWTYPE;
  v_branch_name text;
  v_columns jsonb;
  v_rows jsonb;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_org FROM public.organizations WHERE id = p_org_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: Organization not found' USING ERRCODE = 'P0002';
  END IF;

  IF p_branch_id IS NOT NULL THEN
    SELECT b.name INTO v_branch_name
    FROM public.branches b
    WHERE b.id = p_branch_id AND b.organization_id = p_org_id;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'NOT_FOUND: Branch not found in organization' USING ERRCODE = 'P0002';
    END IF;
  END IF;

  IF p_report_type = 'visits' THEN
    IF NOT authz.has_permission(p_org_id, p_branch_id, 'checkin.read')
       AND NOT authz.has_permission(p_org_id, p_branch_id, CASE WHEN p_branch_id IS NULL THEN 'dashboard.org.read' ELSE 'dashboard.branch.read' END) THEN
      RAISE EXCEPTION 'FORBIDDEN: Missing checkin.read or dashboard permission' USING ERRCODE = '42501';
    END IF;

    v_columns := jsonb_build_array(
      'Checked In At', 'Checked Out At', 'Branch', 'Member Code', 'Member Name', 'Method', 'Override Reason'
    );
    SELECT COALESCE(
      jsonb_agg(
        jsonb_build_array(
          to_char(fv.checked_in_at AT TIME ZONE COALESCE(b.timezone, v_org.timezone, 'UTC'), 'YYYY-MM-DD HH24:MI'),
          CASE WHEN fv.checked_out_at IS NOT NULL
            THEN to_char(fv.checked_out_at AT TIME ZONE COALESCE(b.timezone, v_org.timezone, 'UTC'), 'YYYY-MM-DD HH24:MI')
            ELSE '' END,
          b.name,
          m.member_code,
          m.full_name,
          fv.check_in_method,
          COALESCE(fv.override_reason, '')
        )
        ORDER BY fv.checked_in_at DESC
      ),
      '[]'::jsonb
    ) INTO v_rows
    FROM public.facility_visits fv
    JOIN public.branches b ON b.id = fv.branch_id AND b.organization_id = fv.organization_id
    JOIN public.members m ON m.id = fv.member_id AND m.organization_id = fv.organization_id
    WHERE fv.organization_id = p_org_id
      AND (p_branch_id IS NULL OR fv.branch_id = p_branch_id)
      AND fv.checked_in_at >= now() - make_interval(days => v_window);

  ELSIF p_report_type = 'payments' THEN
    IF NOT authz.has_permission(p_org_id, p_branch_id, 'payment.read') THEN
      RAISE EXCEPTION 'FORBIDDEN: Missing payment.read permission' USING ERRCODE = '42501';
    END IF;

    v_columns := jsonb_build_array(
      'Paid At', 'Branch', 'Member Code', 'Member Name', 'Package', 'Method', 'Status',
      'Currency', 'Gross Amount', 'Refunded Amount', 'Net Amount', 'Refund Channel', 'Refund Reason'
    );
    SELECT COALESCE(
      jsonb_agg(
        jsonb_build_array(
          to_char(pr.paid_at AT TIME ZONE COALESCE(b.timezone, v_org.timezone, 'UTC'), 'YYYY-MM-DD HH24:MI'),
          b.name,
          m.member_code,
          m.full_name,
          COALESCE(p.name, ''),
          pr.method,
          pr.status,
          pr.currency_code,
          to_char(round(pr.amount_minor / 100.0, 2), 'FM999999990.00'),
          to_char(round(pr.refunded_amount_minor / 100.0, 2), 'FM999999990.00'),
          to_char(round(GREATEST(pr.amount_minor - pr.refunded_amount_minor, 0) / 100.0, 2), 'FM999999990.00'),
          COALESCE(pr.refund_channel, ''),
          COALESCE(pr.refund_reason, '')
        )
        ORDER BY pr.paid_at DESC
      ),
      '[]'::jsonb
    ) INTO v_rows
    FROM public.payment_records pr
    JOIN public.branches b ON b.id = pr.branch_id AND b.organization_id = pr.organization_id
    JOIN public.members m ON m.id = pr.member_id AND m.organization_id = pr.organization_id
    LEFT JOIN public.member_subscriptions ms ON ms.id = pr.subscription_id AND ms.organization_id = pr.organization_id
    LEFT JOIN public.packages p ON p.id = ms.package_id AND p.organization_id = ms.organization_id
    WHERE pr.organization_id = p_org_id
      AND (p_branch_id IS NULL OR pr.branch_id = p_branch_id)
      AND pr.paid_at >= now() - make_interval(days => v_window);

  ELSIF p_report_type = 'members' THEN
    IF NOT authz.has_permission(p_org_id, p_branch_id, 'member.read') THEN
      RAISE EXCEPTION 'FORBIDDEN: Missing member.read permission' USING ERRCODE = '42501';
    END IF;

    v_columns := jsonb_build_array(
      'Member Code', 'Full Name', 'Home Branch', 'Status', 'Email', 'Phone',
      'Account Linked', 'Active Subscriptions', 'Class Credits', 'PT Credits', 'Joined At'
    );
    SELECT COALESCE(
      jsonb_agg(
        jsonb_build_array(
          m.member_code,
          m.full_name,
          b.name,
          m.status,
          COALESCE(m.email, ''),
          COALESCE(m.phone, ''),
          CASE WHEN m.user_id IS NOT NULL THEN 'Yes' ELSE 'No' END,
          COALESCE((
            SELECT COUNT(*)::integer FROM public.member_subscriptions ms
            WHERE ms.organization_id = p_org_id AND ms.member_id = m.id AND ms.status = 'active'
          ), 0),
          COALESCE((
            SELECT SUM(cg.remaining_amount)::integer FROM public.credit_grants cg
            WHERE cg.organization_id = p_org_id AND cg.member_id = m.id
              AND cg.credit_type = 'class_credit' AND cg.status = 'active'
              AND (cg.expires_at IS NULL OR cg.expires_at > now())
          ), 0),
          COALESCE((
            SELECT SUM(cg.remaining_amount)::integer FROM public.credit_grants cg
            WHERE cg.organization_id = p_org_id AND cg.member_id = m.id
              AND cg.credit_type = 'pt_credit' AND cg.status = 'active'
              AND (cg.expires_at IS NULL OR cg.expires_at > now())
          ), 0),
          to_char(m.created_at AT TIME ZONE COALESCE(v_org.timezone, 'UTC'), 'YYYY-MM-DD HH24:MI')
        )
        ORDER BY m.member_code ASC
      ),
      '[]'::jsonb
    ) INTO v_rows
    FROM public.members m
    JOIN public.branches b ON b.id = m.home_branch_id AND b.organization_id = m.organization_id
    WHERE m.organization_id = p_org_id
      AND (p_branch_id IS NULL OR m.home_branch_id = p_branch_id);

  ELSIF p_report_type = 'attendance' THEN
    IF NOT authz.has_permission(p_org_id, p_branch_id, 'booking.read') THEN
      RAISE EXCEPTION 'FORBIDDEN: Missing booking.read permission' USING ERRCODE = '42501';
    END IF;

    v_columns := jsonb_build_array(
      'Session Starts At', 'Branch', 'Class Title', 'Instructor', 'Member Code',
      'Member Name', 'Booking Status', 'Attendance Status', 'Credit Cost'
    );
    SELECT COALESCE(
      jsonb_agg(
        jsonb_build_array(
          to_char(cs.starts_at AT TIME ZONE COALESCE(b.timezone, v_org.timezone, 'UTC'), 'YYYY-MM-DD HH24:MI'),
          b.name,
          cs.title,
          cs.instructor_display_name,
          m.member_code,
          m.full_name,
          cb.status,
          cb.attendance_status,
          cb.credit_cost
        )
        ORDER BY cs.starts_at DESC, m.member_code ASC
      ),
      '[]'::jsonb
    ) INTO v_rows
    FROM public.class_bookings cb
    JOIN public.class_sessions cs ON cs.id = cb.session_id AND cs.organization_id = cb.organization_id
    JOIN public.branches b ON b.id = cs.branch_id AND b.organization_id = cs.organization_id
    JOIN public.members m ON m.id = cb.member_id AND m.organization_id = cb.organization_id
    WHERE cb.organization_id = p_org_id
      AND (p_branch_id IS NULL OR cs.branch_id = p_branch_id)
      AND cs.starts_at >= now() - make_interval(days => v_window);

  ELSE
    RAISE EXCEPTION 'VALIDATION_ERROR: Unsupported report type %', p_report_type USING ERRCODE = '22023';
  END IF;

  RETURN jsonb_build_object(
    'report_type', p_report_type,
    'organization_name', v_org.name,
    'branch_scope', COALESCE(v_branch_name, 'All Branches'),
    'currency_code', v_org.currency_code,
    'timezone', v_org.timezone,
    'generated_at', now(),
    'columns', v_columns,
    'rows', v_rows
  );
END;
$$;

-- -----------------------------------------------------------------------------
-- 7. Operational Notification Triggers (PT Sessions & Equipment Tickets)
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION private.notify_on_pt_session_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_member_uid uuid;
  v_trainer_uid uuid;
  v_trainer_name text;
  v_member_name text;
  v_title text;
  v_member_body text;
  v_trainer_body text;
BEGIN
  SELECT m.user_id, m.full_name INTO v_member_uid, v_member_name
  FROM public.members m
  WHERE m.id = NEW.member_id AND m.organization_id = NEW.organization_id;

  SELECT tp.user_id, tp.display_name INTO v_trainer_uid, v_trainer_name
  FROM public.trainer_profiles tp
  WHERE tp.id = NEW.trainer_id AND tp.organization_id = NEW.organization_id;

  IF TG_OP = 'INSERT' THEN
    v_title := 'PT Session Scheduled';
    v_member_body := 'Your 1-on-1 PT session with ' || COALESCE(NULLIF(trim(v_trainer_name), ''), 'your coach') || ' is scheduled.';
    v_trainer_body := 'New 1-on-1 PT session booked with ' || COALESCE(NULLIF(trim(v_member_name), ''), 'a member') || '.';
  ELSIF TG_OP = 'UPDATE' AND OLD.status IS DISTINCT FROM NEW.status THEN
    IF NEW.status = 'completed' THEN
      v_title := 'PT Session Completed';
      v_member_body := 'Your PT session with ' || COALESCE(NULLIF(trim(v_trainer_name), ''), 'your coach') || ' has been marked completed.';
      v_trainer_body := NULL;
    ELSIF NEW.status IN ('cancelled_early', 'cancelled_late') THEN
      v_title := 'PT Session Cancelled';
      v_member_body := 'Your PT session with ' || COALESCE(NULLIF(trim(v_trainer_name), ''), 'your coach') || ' was cancelled.';
      v_trainer_body := 'PT session with ' || COALESCE(NULLIF(trim(v_member_name), ''), 'member') || ' was cancelled.';
    ELSE
      RETURN NEW;
    END IF;
  ELSE
    RETURN NEW;
  END IF;

  IF v_member_uid IS NOT NULL THEN
    INSERT INTO public.user_notifications (
      organization_id, user_id, title, body, category, metadata
    ) VALUES (
      NEW.organization_id, v_member_uid, v_title, v_member_body, 'personal_training',
      jsonb_build_object('pt_session_id', NEW.id, 'status', NEW.status)
    );
  END IF;

  IF v_trainer_uid IS NOT NULL AND v_trainer_uid IS DISTINCT FROM v_member_uid AND v_trainer_body IS NOT NULL THEN
    INSERT INTO public.user_notifications (
      organization_id, user_id, title, body, category, metadata
    ) VALUES (
      NEW.organization_id, v_trainer_uid, v_title, v_trainer_body, 'personal_training',
      jsonb_build_object('pt_session_id', NEW.id, 'status', NEW.status)
    );
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_pt_session_change ON public.pt_sessions;
CREATE TRIGGER trg_notify_pt_session_change
  AFTER INSERT OR UPDATE OF status ON public.pt_sessions
  FOR EACH ROW EXECUTE FUNCTION private.notify_on_pt_session_change();

CREATE OR REPLACE FUNCTION private.notify_on_equipment_ticket_created()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_asset_code text;
BEGIN
  SELECT ea.asset_code INTO v_asset_code
  FROM public.equipment_assets ea
  WHERE ea.id = NEW.asset_id AND ea.organization_id = NEW.organization_id;

  INSERT INTO public.user_notifications (
    organization_id, user_id, title, body, category, metadata
  )
  SELECT DISTINCT
    NEW.organization_id,
    ura.user_id,
    'Equipment Maintenance Ticket',
    COALESCE(v_asset_code, 'Asset') || ' (' || NEW.priority || '): ' || NEW.summary,
    'equipment',
    jsonb_build_object('ticket_id', NEW.id, 'asset_id', NEW.asset_id, 'branch_id', NEW.branch_id)
  FROM public.user_role_assignments ura
  JOIN public.roles r ON r.id = ura.role_id
  WHERE ura.organization_id = NEW.organization_id
    AND ura.status = 'active'
    AND r.code IN ('org_owner', 'org_admin', 'branch_manager')
    AND (ura.branch_id IS NULL OR ura.branch_id = NEW.branch_id)
    AND ura.user_id IS DISTINCT FROM NEW.reported_by;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_equipment_ticket_created ON public.equipment_maintenance_tickets;
CREATE TRIGGER trg_notify_equipment_ticket_created
  AFTER INSERT ON public.equipment_maintenance_tickets
  FOR EACH ROW EXECUTE FUNCTION private.notify_on_equipment_ticket_created();

-- -----------------------------------------------------------------------------
-- 8. Function Permissions Hardening
-- -----------------------------------------------------------------------------

REVOKE ALL ON FUNCTION private.notify_on_pt_session_change() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION private.notify_on_equipment_ticket_created() FROM PUBLIC, anon, authenticated;

REVOKE ALL ON FUNCTION public.cancel_pt_session(uuid, uuid, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.get_pt_sessions_for_workspace(uuid, uuid, uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.lookup_members_for_pt_booking(uuid, uuid, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.list_assignable_instructors(uuid, uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.update_package_details(uuid, uuid, text, text, bigint, boolean, text, uuid[]) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.record_payment_refund(uuid, uuid, bigint, text, text, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.list_organization_staff(uuid, uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.list_organization_invitations(uuid, uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.revoke_organization_invitation(uuid, uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.update_organization_settings(uuid, text, text, text, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.get_report_export_data(uuid, text, uuid, integer) FROM PUBLIC, anon;

GRANT EXECUTE ON FUNCTION public.cancel_pt_session(uuid, uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_pt_sessions_for_workspace(uuid, uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.lookup_members_for_pt_booking(uuid, uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.list_assignable_instructors(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_package_details(uuid, uuid, text, text, bigint, boolean, text, uuid[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.record_payment_refund(uuid, uuid, bigint, text, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.list_organization_staff(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.list_organization_invitations(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.revoke_organization_invitation(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_organization_settings(uuid, text, text, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_report_export_data(uuid, text, uuid, integer) TO authenticated;
