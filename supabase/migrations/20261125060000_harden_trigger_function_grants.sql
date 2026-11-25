-- =============================================================================
-- Migration 20261125060000: Harden Roster Auth Guard & Trigger Function Grants
--
-- Fixes & Hardening:
--   1. public.get_session_roster: Eliminates SQL three-valued NULL bypass when
--      class_sessions.instructor_user_id IS NULL by requiring
--      v_session.instructor_user_id IS NOT NULL before evaluating equality.
--   2. Trigger Functions Least-Privilege Grants: Revokes EXECUTE from PUBLIC,
--      anon, and authenticated on private.guard_class_session_invariants(),
--      private.handle_new_auth_user(), and Supabase-managed
--      public.rls_auto_enable() (if present), since trigger & event_trigger
--      execution uses owner context and does not require client EXECUTE.
-- =============================================================================

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

  SELECT * INTO v_session
  FROM public.class_sessions
  WHERE id = p_session_id AND organization_id = p_org_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: Session not found' USING ERRCODE = 'P0002';
  END IF;

  IF NOT authz.has_permission(p_org_id, v_session.branch_id, 'booking.read')
     AND NOT (
       v_session.instructor_user_id IS NOT NULL
       AND v_session.instructor_user_id = v_actor_id
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
    JOIN public.members m
      ON m.id = cb.member_id
     AND m.organization_id = cb.organization_id
    WHERE cb.organization_id = p_org_id
      AND cb.session_id = p_session_id
      AND cb.status IN ('confirmed', 'waitlisted')
  );
END;
$$;

REVOKE ALL ON FUNCTION public.get_session_roster(uuid, uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_session_roster(uuid, uuid) TO authenticated;

REVOKE ALL ON FUNCTION private.guard_class_session_invariants() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION private.handle_new_auth_user() FROM PUBLIC, anon, authenticated;

DO $$
BEGIN
  IF to_regprocedure('public.rls_auto_enable()') IS NOT NULL THEN
    REVOKE ALL ON FUNCTION public.rls_auto_enable() FROM PUBLIC, anon, authenticated;
  END IF;
END $$;
