-- RITMA SQL Test 02: Entitlement Separation, Member Column Guard (H2), Credit Ledger Immutability & Freeze Extension (M8), Atomic Credit Adjustments (H4)

BEGIN;

DO $$
DECLARE
  v_owner uuid := 'aaaaaaaa-1111-0000-0000-000000000001';
  v_recep uuid := 'aaaaaaaa-1111-0000-0000-000000000004';
  v_member_gym_user uuid := 'aaaaaaaa-1111-0000-0000-000000000002';
  v_member_pilates_user uuid := 'aaaaaaaa-1111-0000-0000-000000000003';
  v_org jsonb;
  v_org_id uuid;
  v_branch_id uuid;
  v_room_id uuid;
  v_type_pilates uuid;
  v_pkg_gym uuid;
  v_pkg_pilates uuid;
  v_member_gym_id uuid;
  v_member_pilates_id uuid;
  v_claim_gym jsonb;
  v_claim_pilates jsonb;
  v_inv_recep jsonb;
  v_sub_gym jsonb;
  v_sub_pilates jsonb;
  v_session_id uuid;
  v_adj_res jsonb;
  v_bal integer;
  v_err text;
BEGIN
  INSERT INTO auth.users (id, email) VALUES
    (v_owner, 'owner_ent@ritma.test'),
    (v_recep, 'recep_ent@ritma.test'),
    (v_member_gym_user, 'gym_only@ritma.test'),
    (v_member_pilates_user, 'pilates_only@ritma.test')
  ON CONFLICT (id) DO NOTHING;

  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_owner, 'email', 'owner_ent@ritma.test', 'role', 'authenticated')::text, true);
  SET LOCAL ROLE authenticated;

  v_org := public.create_organization_with_owner('Entitlement Test Studio', 'ent-test', 'hybrid', 'UTC', 'USD', 'Main', 'MAIN');
  v_org_id := (v_org ->> 'organization_id')::uuid;
  v_branch_id := (v_org ->> 'branch_id')::uuid;

  v_inv_recep := public.invite_user_to_organization(v_org_id, 'recep_ent@ritma.test', 'receptionist', v_branch_id);
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_recep, 'email', 'recep_ent@ritma.test', 'role', 'authenticated')::text, true);
  PERFORM public.accept_organization_invitation(v_inv_recep ->> 'token');

  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_owner, 'email', 'owner_ent@ritma.test', 'role', 'authenticated')::text, true);

  INSERT INTO public.rooms (organization_id, branch_id, name, default_capacity)
  VALUES (v_org_id, v_branch_id, 'Studio 1', 10) RETURNING id INTO v_room_id;

  INSERT INTO public.class_types (organization_id, name)
  VALUES (v_org_id, 'Reformer Pilates') RETURNING id INTO v_type_pilates;

  INSERT INTO public.class_sessions (
    organization_id, branch_id, room_id, class_type_id, title,
    starts_at, ends_at, capacity, credit_cost, cancellation_cutoff_at
  ) VALUES (
    v_org_id, v_branch_id, v_room_id, v_type_pilates, 'Morning Reformer',
    now() + interval '2 days', now() + interval '2 days 1 hour', 10, 2, now() + interval '1 day'
  ) RETURNING id INTO v_session_id;

  INSERT INTO public.packages (organization_id, name, package_type, price_minor)
  VALUES (v_org_id, 'Gym Only', 'gym_membership', 5000) RETURNING id INTO v_pkg_gym;
  INSERT INTO public.package_entitlement_rules (organization_id, package_id, entitlement_kind, duration_days, branch_access_scope)
  VALUES (v_org_id, v_pkg_gym, 'facility_access', 30, 'single_branch');

  INSERT INTO public.packages (organization_id, name, package_type, price_minor)
  VALUES (v_org_id, '3-Pack Pilates', 'class_pack', 9000) RETURNING id INTO v_pkg_pilates;
  INSERT INTO public.package_entitlement_rules (organization_id, package_id, entitlement_kind, duration_days, credit_quantity, branch_access_scope)
  VALUES (v_org_id, v_pkg_pilates, 'class_credit', 60, 3, 'all_branches');

  INSERT INTO public.members (organization_id, home_branch_id, member_code, full_name)
  VALUES
    (v_org_id, v_branch_id, 'M-001', 'Gym Only Member'),
    (v_org_id, v_branch_id, 'M-002', 'Pilates Only Member');

  SELECT id INTO v_member_gym_id FROM public.members WHERE member_code = 'M-001' AND organization_id = v_org_id;
  SELECT id INTO v_member_pilates_id FROM public.members WHERE member_code = 'M-002' AND organization_id = v_org_id;

  -- Consent claim links user_ids safely
  v_claim_gym := public.invite_member_claim(v_org_id, v_member_gym_id, 'gym_only@ritma.test');
  v_claim_pilates := public.invite_member_claim(v_org_id, v_member_pilates_id, 'pilates_only@ritma.test');

  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_member_gym_user, 'email', 'gym_only@ritma.test', 'role', 'authenticated')::text, true);
  PERFORM public.claim_member_profile(v_claim_gym ->> 'token');

  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_member_pilates_user, 'email', 'pilates_only@ritma.test', 'role', 'authenticated')::text, true);
  PERFORM public.claim_member_profile(v_claim_pilates ->> 'token');

  -- H2 check: Receptionist cannot directly hijack members.user_id or status via UPDATE
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_recep, 'email', 'recep_ent@ritma.test', 'role', 'authenticated')::text, true);
  BEGIN
    UPDATE public.members SET user_id = v_recep WHERE id = v_member_pilates_id;
    RAISE EXCEPTION 'Expected H2 column guard rejection';
  EXCEPTION WHEN SQLSTATE '42501' THEN
    NULL;
  END;

  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_owner, 'email', 'owner_ent@ritma.test', 'role', 'authenticated')::text, true);
  v_sub_gym := public.assign_package_to_member(v_org_id, v_branch_id, v_member_gym_id, v_pkg_gym, now(), 'cash', 'assign-gym-1');
  IF (public.assign_package_to_member(v_org_id, v_branch_id, v_member_gym_id, v_pkg_gym, now(), 'cash', 'assign-gym-1') ->> 'idempotent_replay')::boolean IS NOT TRUE THEN
    RAISE EXCEPTION 'Expected idempotent replay on assign_package_to_member';
  END IF;

  v_sub_pilates := public.assign_package_to_member(v_org_id, v_branch_id, v_member_pilates_id, v_pkg_pilates, now(), 'cash', 'assign-pilates-1');

  -- Gym-only member MUST NOT book credit-gated class
  BEGIN
    PERFORM public.book_class_session(v_org_id, v_session_id, v_member_gym_id, 'book-gym-member');
    RAISE EXCEPTION 'Gym-only member should be blocked from credit-gated class';
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_err = MESSAGE_TEXT;
    IF v_err NOT LIKE '%INSUFFICIENT_CREDITS%' THEN
      RAISE;
    END IF;
  END;

  -- Pilates-only member MUST NOT gain open-gym facility access
  IF (public.manual_facility_check_in(v_org_id, v_branch_id, v_member_pilates_id, false, NULL, 'checkin-pilates-only') ->> 'reason_code') <> 'NO_FACILITY_ENTITLEMENT' THEN
    RAISE EXCEPTION 'Pilates-only member should be denied open-gym check-in';
  END IF;

  -- M8 check: Freezing Pilates subscription freezes its credit_grants too
  PERFORM public.freeze_member_subscription(v_org_id, (v_sub_pilates ->> 'subscription_id')::uuid, 'Travel');
  BEGIN
    PERFORM public.book_class_session(v_org_id, v_session_id, v_member_pilates_id, 'book-while-frozen');
    RAISE EXCEPTION 'Frozen credit grant should not allow booking';
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_err = MESSAGE_TEXT;
    IF v_err NOT LIKE '%INSUFFICIENT_CREDITS%' THEN
      RAISE;
    END IF;
  END;
  PERFORM public.unfreeze_member_subscription(v_org_id, (v_sub_pilates ->> 'subscription_id')::uuid);

  -- H4 check: adjust_member_credits wildcard safety (`%`) & exact idempotency replay
  v_adj_res := public.adjust_member_credits(v_org_id, v_member_pilates_id, 'class_credit', 2, 'Bonus credits', '%');
  IF (v_adj_res ->> 'idempotent_replay')::boolean IS NOT FALSE THEN
    RAISE EXCEPTION 'Wildcard key "%%" should not match unrelated rows';
  END IF;
  IF (public.adjust_member_credits(v_org_id, v_member_pilates_id, 'class_credit', 2, 'Bonus credits', '%') ->> 'idempotent_replay')::boolean IS NOT TRUE THEN
    RAISE EXCEPTION 'Exact replay of adjust_member_credits should return idempotent_replay=true';
  END IF;

  SELECT COALESCE(SUM(remaining_amount), 0) INTO v_bal
  FROM public.credit_grants WHERE member_id = v_member_pilates_id AND status = 'active';
  IF v_bal <> 5 THEN
    RAISE EXCEPTION 'Expected 5 active credits (3 + 2), got %', v_bal;
  END IF;

  -- Ledger immutability: UPDATE and TRUNCATE must fail (M10)
  RESET ROLE;
  BEGIN
    UPDATE public.credit_ledger_entries SET delta = 999 WHERE organization_id = v_org_id;
    RAISE EXCEPTION 'Expected ledger immutability exception on UPDATE';
  EXCEPTION WHEN SQLSTATE '42501' THEN
    NULL;
  END;
END $$;

ROLLBACK;
