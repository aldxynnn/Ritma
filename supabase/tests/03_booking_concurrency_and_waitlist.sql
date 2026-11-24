-- RITMA SQL Test 03: Class Booking Capacity Lock, Direct-Write Guards (M7), Multi-Grant Refund & Waitlist Credit Skip

BEGIN;

DO $$
DECLARE
  v_owner uuid := 'aaaaaaaa-2222-0000-0000-000000000001';
  v_org jsonb;
  v_org_id uuid;
  v_branch_id uuid;
  v_room_id uuid;
  v_type_id uuid;
  v_pkg_2credits uuid;
  v_m1 uuid;
  v_m2 uuid;
  v_m3 uuid;
  v_session_id uuid;
  v_b1 jsonb;
  v_b2 jsonb;
  v_b3 jsonb;
  v_cancel jsonb;
  v_m1_bal integer;
  v_m3_bal integer;
  v_confirmed integer;
  v_err text;
BEGIN
  INSERT INTO auth.users (id, email) VALUES (v_owner, 'owner_book@ritma.test') ON CONFLICT (id) DO NOTHING;
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_owner, 'email', 'owner_book@ritma.test', 'role', 'authenticated')::text, true);
  SET LOCAL ROLE authenticated;

  v_org := public.create_organization_with_owner('Booking Test Studio', 'book-test', 'boutique_studio', 'UTC', 'USD', 'Main', 'MAIN');
  v_org_id := (v_org ->> 'organization_id')::uuid;
  v_branch_id := (v_org ->> 'branch_id')::uuid;

  INSERT INTO public.rooms (organization_id, branch_id, name, default_capacity)
  VALUES (v_org_id, v_branch_id, 'Cycle Studio', 1) RETURNING id INTO v_room_id;

  INSERT INTO public.class_types (organization_id, name)
  VALUES (v_org_id, 'Indoor Cycling') RETURNING id INTO v_type_id;

  -- M7: Attempting to INSERT with fake confirmed_count=1 is sanitized back to 0
  INSERT INTO public.class_sessions (
    organization_id, branch_id, room_id, class_type_id, title,
    starts_at, ends_at, capacity, confirmed_count, credit_cost, cancellation_cutoff_at, waitlist_enabled
  ) VALUES (
    v_org_id, v_branch_id, v_room_id, v_type_id, 'Rhythm Ride',
    now() + interval '3 days', now() + interval '3 days 1 hour', 1, 1, 2, now() + interval '2 days', true
  ) RETURNING id, confirmed_count INTO v_session_id, v_confirmed;

  IF v_confirmed <> 0 THEN
    RAISE EXCEPTION 'Expected INSERT trigger to sanitize confirmed_count to 0, got %', v_confirmed;
  END IF;

  INSERT INTO public.packages (organization_id, name, package_type, price_minor)
  VALUES (v_org_id, '2-Credit Pack', 'class_pack', 4000) RETURNING id INTO v_pkg_2credits;
  INSERT INTO public.package_entitlement_rules (organization_id, package_id, entitlement_kind, duration_days, credit_quantity, branch_access_scope)
  VALUES (v_org_id, v_pkg_2credits, 'class_credit', 30, 2, 'all_branches');

  INSERT INTO public.members (organization_id, home_branch_id, member_code, full_name)
  VALUES
    (v_org_id, v_branch_id, 'B-1', 'Member One'),
    (v_org_id, v_branch_id, 'B-2', 'Member Two (Will Deplete)'),
    (v_org_id, v_branch_id, 'B-3', 'Member Three (Has Credits)');

  SELECT id INTO v_m1 FROM public.members WHERE member_code = 'B-1' AND organization_id = v_org_id;
  SELECT id INTO v_m2 FROM public.members WHERE member_code = 'B-2' AND organization_id = v_org_id;
  SELECT id INTO v_m3 FROM public.members WHERE member_code = 'B-3' AND organization_id = v_org_id;

  PERFORM public.assign_package_to_member(v_org_id, v_branch_id, v_m1, v_pkg_2credits, now(), 'cash', 'p-m1');
  PERFORM public.assign_package_to_member(v_org_id, v_branch_id, v_m2, v_pkg_2credits, now(), 'cash', 'p-m2');
  PERFORM public.assign_package_to_member(v_org_id, v_branch_id, v_m3, v_pkg_2credits, now(), 'cash', 'p-m3');

  v_b1 := public.book_class_session(v_org_id, v_session_id, v_m1, 'key-b1');
  IF (v_b1 ->> 'status') <> 'confirmed' THEN
    RAISE EXCEPTION 'Expected confirmed booking for M1';
  END IF;

  IF (public.book_class_session(v_org_id, v_session_id, v_m1, 'key-b1') ->> 'idempotent_replay')::boolean IS NOT TRUE THEN
    RAISE EXCEPTION 'Expected idempotent replay';
  END IF;

  BEGIN
    PERFORM public.book_class_session(v_org_id, v_session_id, v_m1, 'key-b1-dup');
    RAISE EXCEPTION 'Expected duplicate active booking failure';
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_err = MESSAGE_TEXT;
    IF v_err NOT LIKE '%ALREADY_BOOKED%' THEN
      RAISE;
    END IF;
  END;

  v_b2 := public.book_class_session(v_org_id, v_session_id, v_m2, 'key-b2');
  v_b3 := public.book_class_session(v_org_id, v_session_id, v_m3, 'key-b3');
  IF (v_b2 ->> 'waitlist_position')::integer <> 1 OR (v_b3 ->> 'waitlist_position')::integer <> 2 THEN
    RAISE EXCEPTION 'Unexpected waitlist positions';
  END IF;

  -- M2 loses credits before promotion occurs -> waitlist promoter skips M2 and promotes M3
  PERFORM public.adjust_member_credits(v_org_id, v_m2, 'class_credit', -2, 'Test credit removal', 'adj-m2');

  -- F9/M7: Direct capacity shrink below confirmed_count (while keeping capacity > 0 via capacity=2 -> confirmed=2 or here direct cancel block)
  BEGIN
    UPDATE public.class_sessions SET status = 'cancelled' WHERE id = v_session_id;
    RAISE EXCEPTION 'Expected M7 direct session cancellation rejection';
  EXCEPTION WHEN SQLSTATE '42501' THEN
    NULL;
  END;

  v_cancel := public.cancel_class_booking(v_org_id, (v_b1 ->> 'booking_id')::uuid, 'Schedule conflict');
  IF (v_cancel ->> 'refunded_credits')::integer <> 2 THEN
    RAISE EXCEPTION 'Expected 2 credits refunded to M1';
  END IF;
  IF (v_cancel ->> 'promoted_booking_id')::uuid <> (v_b3 ->> 'booking_id')::uuid THEN
    RAISE EXCEPTION 'Expected M3 to be promoted after skipping credit-less M2';
  END IF;

  SELECT COALESCE(SUM(remaining_amount), 0) INTO v_m1_bal FROM public.credit_grants WHERE member_id = v_m1;
  SELECT COALESCE(SUM(remaining_amount), 0) INTO v_m3_bal FROM public.credit_grants WHERE member_id = v_m3;
  SELECT confirmed_count INTO v_confirmed FROM public.class_sessions WHERE id = v_session_id;

  IF v_m1_bal <> 2 OR v_m3_bal <> 0 OR v_confirmed <> 1 THEN
    RAISE EXCEPTION 'Unexpected post-promotion state: m1=%, m3=%, confirmed=%', v_m1_bal, v_m3_bal, v_confirmed;
  END IF;

  -- M7: Cancelling entire session via RPC refunds M3 cleanly
  PERFORM public.cancel_class_session(v_org_id, v_session_id, 'Instructor sick');
  SELECT COALESCE(SUM(remaining_amount), 0) INTO v_m3_bal FROM public.credit_grants WHERE member_id = v_m3;
  IF v_m3_bal <> 2 THEN
    RAISE EXCEPTION 'Expected M3 credits refunded when studio cancels session, got %', v_m3_bal;
  END IF;
END $$;

ROLLBACK;
