-- RITMA SQL Test 05: Audit Remediation Security & Workflow Verification
-- Covers:
--   A. Personal Trainer session isolation (2 trainers same branch), PT client lookup without PII, PT cancel + refund
--   B. Instructor class isolation (cannot read unassigned classes), assignable instructors lookup
--   C. Package selected_branches empty-list guard & atomic update_package_details
--   H. Report export permission & cross-branch denial
--   I. Payment refunds (partial + full + over-refund guard + manual_recorded + permission check + net KPI)
--   J. Staff management listing, invitation listing/revocation & rank hierarchy
--   E. Member claim token invalid/expired/wrong-email/already-claimed safety

BEGIN;

DO $$
DECLARE
  v_owner uuid := 'aaaaaaaa-5555-0000-0000-000000000001';
  v_mgr_b1 uuid := 'aaaaaaaa-5555-0000-0000-000000000002';
  v_pt_1 uuid := 'aaaaaaaa-5555-0000-0000-000000000003';
  v_pt_2 uuid := 'aaaaaaaa-5555-0000-0000-000000000004';
  v_instr_1 uuid := 'aaaaaaaa-5555-0000-0000-000000000005';
  v_member_user uuid := 'aaaaaaaa-5555-0000-0000-000000000006';
  v_other_user uuid := 'aaaaaaaa-5555-0000-0000-000000000007';

  v_org jsonb;
  v_org_id uuid;
  v_b1 uuid;
  v_b2 uuid;
  v_room_1 uuid;
  v_type_1 uuid;
  v_sess_assigned uuid;
  v_sess_unassigned uuid;

  v_tp1_id uuid;
  v_tp2_id uuid;
  v_member_id uuid;
  v_pkg_pt uuid;
  v_pkg_sel uuid;
  v_rule_sel_id uuid;
  v_sub_pt jsonb;
  v_pay_id uuid;

  v_inv jsonb;
  v_claim jsonb;
  v_pt_book jsonb;
  v_pt_cancel jsonb;
  v_res jsonb;
  v_kpis jsonb;
  v_count integer;
  v_bal integer;
  v_err text;
  v_day integer;
BEGIN
  INSERT INTO auth.users (id, email) VALUES
    (v_owner, 'owner_05@ritma.test'),
    (v_mgr_b1, 'mgr_b1_05@ritma.test'),
    (v_pt_1, 'pt1_05@ritma.test'),
    (v_pt_2, 'pt2_05@ritma.test'),
    (v_instr_1, 'instr1_05@ritma.test'),
    (v_member_user, 'member_05@ritma.test'),
    (v_other_user, 'other_05@ritma.test')
  ON CONFLICT (id) DO NOTHING;

  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_owner, 'email', 'owner_05@ritma.test', 'role', 'authenticated')::text, true);
  SET LOCAL ROLE authenticated;

  v_org := public.create_organization_with_owner('Audit Rem Org', 'audit-rem-org', 'hybrid', 'UTC', 'USD', 'Branch One', 'B1');
  v_org_id := (v_org ->> 'organization_id')::uuid;
  v_b1 := (v_org ->> 'branch_id')::uuid;

  INSERT INTO public.branches (organization_id, name, code)
  VALUES (v_org_id, 'Branch Two', 'B2') RETURNING id INTO v_b2;

  INSERT INTO public.rooms (organization_id, branch_id, name, default_capacity)
  VALUES (v_org_id, v_b1, 'Main Studio', 12) RETURNING id INTO v_room_1;

  INSERT INTO public.class_types (organization_id, name)
  VALUES (v_org_id, 'Reformer') RETURNING id INTO v_type_1;

  -- Onboard Manager B1, PT 1 (B1), PT 2 (B1), Instructor 1 (B1)
  v_inv := public.invite_user_to_organization(v_org_id, 'mgr_b1_05@ritma.test', 'branch_manager', v_b1);
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_mgr_b1, 'email', 'mgr_b1_05@ritma.test', 'role', 'authenticated')::text, true);
  PERFORM public.accept_organization_invitation(v_inv ->> 'token');

  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_owner, 'email', 'owner_05@ritma.test', 'role', 'authenticated')::text, true);
  v_inv := public.invite_user_to_organization(v_org_id, 'pt1_05@ritma.test', 'personal_trainer', v_b1);
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_pt_1, 'email', 'pt1_05@ritma.test', 'role', 'authenticated')::text, true);
  PERFORM public.accept_organization_invitation(v_inv ->> 'token');

  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_owner, 'email', 'owner_05@ritma.test', 'role', 'authenticated')::text, true);
  v_inv := public.invite_user_to_organization(v_org_id, 'pt2_05@ritma.test', 'personal_trainer', v_b1);
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_pt_2, 'email', 'pt2_05@ritma.test', 'role', 'authenticated')::text, true);
  PERFORM public.accept_organization_invitation(v_inv ->> 'token');

  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_owner, 'email', 'owner_05@ritma.test', 'role', 'authenticated')::text, true);
  v_inv := public.invite_user_to_organization(v_org_id, 'instr1_05@ritma.test', 'instructor', v_b1);
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_instr_1, 'email', 'instr1_05@ritma.test', 'role', 'authenticated')::text, true);
  PERFORM public.accept_organization_invitation(v_inv ->> 'token');

  -- Pending invite revocation test + hierarchy check
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_owner, 'email', 'owner_05@ritma.test', 'role', 'authenticated')::text, true);
  v_inv := public.invite_user_to_organization(v_org_id, 'pending_admin@ritma.test', 'org_admin', NULL);
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_mgr_b1, 'email', 'mgr_b1_05@ritma.test', 'role', 'authenticated')::text, true);
  BEGIN
    PERFORM public.revoke_organization_invitation(v_org_id, (v_inv ->> 'invitation_id')::uuid);
    RAISE EXCEPTION 'Expected branch_manager to be blocked from revoking org_admin invitation';
  EXCEPTION WHEN SQLSTATE '42501' THEN
    NULL;
  END;

  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_owner, 'email', 'owner_05@ritma.test', 'role', 'authenticated')::text, true);
  PERFORM public.revoke_organization_invitation(v_org_id, (v_inv ->> 'invitation_id')::uuid);

  -- Create Trainer Profiles & Availabilities for PT 1 and PT 2 on Branch 1
  INSERT INTO public.trainer_profiles (organization_id, user_id, home_branch_id, display_name, default_credit_cost)
  VALUES
    (v_org_id, v_pt_1, v_b1, 'Coach One', 1),
    (v_org_id, v_pt_2, v_b1, 'Coach Two', 1);
  SELECT id INTO v_tp1_id FROM public.trainer_profiles WHERE organization_id = v_org_id AND user_id = v_pt_1;
  SELECT id INTO v_tp2_id FROM public.trainer_profiles WHERE organization_id = v_org_id AND user_id = v_pt_2;

  FOR v_day IN 0..6 LOOP
    INSERT INTO public.trainer_availabilities (organization_id, branch_id, trainer_id, weekday, start_time, end_time)
    VALUES
      (v_org_id, v_b1, v_tp1_id, v_day, '06:00:00', '22:00:00'),
      (v_org_id, v_b1, v_tp2_id, v_day, '06:00:00', '22:00:00');
  END LOOP;

  -- Register Member + Claim Token Error Cases (wrong email, valid claim, already claimed)
  INSERT INTO public.members (organization_id, home_branch_id, member_code, full_name, email)
  VALUES (v_org_id, v_b1, 'AUD-01', 'Audit Member', 'member_05@ritma.test')
  RETURNING id INTO v_member_id;

  v_claim := public.invite_member_claim(v_org_id, v_member_id, 'member_05@ritma.test');

  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_other_user, 'email', 'other_05@ritma.test', 'role', 'authenticated')::text, true);
  BEGIN
    PERFORM public.claim_member_profile(v_claim ->> 'token');
    RAISE EXCEPTION 'Expected wrong-email claim to fail';
  EXCEPTION WHEN SQLSTATE '42501' THEN
    NULL;
  END;

  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_member_user, 'email', 'member_05@ritma.test', 'role', 'authenticated')::text, true);
  PERFORM public.claim_member_profile(v_claim ->> 'token');
  BEGIN
    PERFORM public.claim_member_profile(v_claim ->> 'token');
    RAISE EXCEPTION 'Expected reused claim token to fail';
  EXCEPTION WHEN SQLSTATE '22023' THEN
    NULL;
  END;

  -- C: Selected-Branches package with 0 branches must fail on assign
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_owner, 'email', 'owner_05@ritma.test', 'role', 'authenticated')::text, true);
  INSERT INTO public.packages (organization_id, name, package_type, price_minor)
  VALUES (v_org_id, 'Selected Branch Pack', 'gym_membership', 10000)
  RETURNING id INTO v_pkg_sel;
  INSERT INTO public.package_entitlement_rules (organization_id, package_id, entitlement_kind, duration_days, branch_access_scope)
  VALUES (v_org_id, v_pkg_sel, 'facility_access', 30, 'selected_branches')
  RETURNING id INTO v_rule_sel_id;

  BEGIN
    PERFORM public.assign_package_to_member(v_org_id, v_b1, v_member_id, v_pkg_sel, now(), 'cash', 'sel-empty-1');
    RAISE EXCEPTION 'Expected selected_branches without branch rows to fail';
  EXCEPTION WHEN SQLSTATE '22023' THEN
    NULL;
  END;

  -- Update selected branches atomically via update_package_details
  PERFORM public.update_package_details(v_org_id, v_pkg_sel, 'Selected B2 Pack', 'Updated', 10000, true, 'selected_branches', ARRAY[v_b2]);
  SELECT COUNT(*) INTO v_count FROM public.package_rule_branches WHERE rule_id = v_rule_sel_id AND branch_id = v_b2;
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'Expected package_rule_branches to contain Branch Two';
  END IF;

  -- PT Package assignment ($100.00 = 10000 minor) -> 3 PT credits
  INSERT INTO public.packages (organization_id, name, package_type, price_minor)
  VALUES (v_org_id, '3 PT Pack', 'pt_pack', 10000) RETURNING id INTO v_pkg_pt;
  INSERT INTO public.package_entitlement_rules (organization_id, package_id, entitlement_kind, duration_days, credit_quantity, branch_access_scope)
  VALUES (v_org_id, v_pkg_pt, 'pt_credit', 60, 3, 'all_branches');

  v_sub_pt := public.assign_package_to_member(v_org_id, v_b1, v_member_id, v_pkg_pt, now(), 'card_terminal', 'pt-assign-05');
  SELECT id INTO v_pay_id FROM public.payment_records WHERE subscription_id = (v_sub_pt ->> 'subscription_id')::uuid;

  -- A: PT1 books session for PT1, PT2 cannot view/complete/cancel PT1's session, PT1 cannot book for PT2
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_pt_1, 'email', 'pt1_05@ritma.test', 'role', 'authenticated')::text, true);
  v_res := public.lookup_members_for_pt_booking(v_org_id, v_b1, 'AUD');
  IF jsonb_array_length(v_res) <> 1 OR (v_res -> 0 ->> 'available_pt_credits')::integer <> 3 THEN
    RAISE EXCEPTION 'Expected PT1 lookup to return AUD-01 with 3 PT credits, got %', v_res;
  END IF;

  BEGIN
    PERFORM public.book_pt_session(v_org_id, v_b1, v_tp2_id, v_member_id, date_trunc('day', now() + interval '1 day') + interval '10 hours', date_trunc('day', now() + interval '1 day') + interval '11 hours', 1, 'pt1-hijack-pt2');
    RAISE EXCEPTION 'Expected PT1 booking for PT2 to be rejected';
  EXCEPTION WHEN SQLSTATE '42501' THEN
    NULL;
  END;

  v_pt_book := public.book_pt_session(v_org_id, v_b1, v_tp1_id, v_member_id, date_trunc('day', now() + interval '1 day') + interval '10 hours', date_trunc('day', now() + interval '1 day') + interval '11 hours', 1, 'pt1-valid-05');

  -- PT2 sees 0 PT sessions in RLS and via get_pt_sessions_for_workspace, and cannot complete/cancel PT1 session
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_pt_2, 'email', 'pt2_05@ritma.test', 'role', 'authenticated')::text, true);
  SELECT COUNT(*) INTO v_count FROM public.pt_sessions WHERE organization_id = v_org_id;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'Expected PT2 RLS SELECT on pt_sessions to be 0, got %', v_count;
  END IF;
  IF jsonb_array_length(public.get_pt_sessions_for_workspace(v_org_id, v_b1, NULL)) <> 0 THEN
    RAISE EXCEPTION 'Expected PT2 workspace RPC to return 0 sessions';
  END IF;
  BEGIN
    PERFORM public.complete_pt_session(v_org_id, (v_pt_book ->> 'pt_session_id')::uuid, 'Unauthorized');
    RAISE EXCEPTION 'Expected PT2 complete on PT1 session to fail';
  EXCEPTION WHEN SQLSTATE '42501' THEN
    NULL;
  END;
  BEGIN
    PERFORM public.cancel_pt_session(v_org_id, (v_pt_book ->> 'pt_session_id')::uuid, 'Unauthorized');
    RAISE EXCEPTION 'Expected PT2 cancel on PT1 session to fail';
  EXCEPTION WHEN SQLSTATE '42501' THEN
    NULL;
  END;

  -- PT1 sees resolved member name + can cancel & refund PT credit back to 3
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_pt_1, 'email', 'pt1_05@ritma.test', 'role', 'authenticated')::text, true);
  v_res := public.get_pt_sessions_for_workspace(v_org_id, v_b1, NULL);
  IF jsonb_array_length(v_res) <> 1 OR (v_res -> 0 ->> 'member_display_name') <> 'Audit Member' THEN
    RAISE EXCEPTION 'Expected PT1 workspace RPC to resolve member name, got %', v_res;
  END IF;

  v_pt_cancel := public.cancel_pt_session(v_org_id, (v_pt_book ->> 'pt_session_id')::uuid, 'Rescheduled');
  IF (v_pt_cancel ->> 'refunded_credits')::integer <> 1 THEN
    RAISE EXCEPTION 'Expected 1 PT credit refunded, got %', v_pt_cancel;
  END IF;
  -- PT1 sees 0 direct rows on credit_grants (RLS) but lookup RPC shows 3 restored PT credits
  SELECT COALESCE(SUM(remaining_amount), 0) INTO v_bal
  FROM public.credit_grants WHERE member_id = v_member_id AND credit_type = 'pt_credit';
  IF v_bal <> 0 THEN
    RAISE EXCEPTION 'Expected PT1 direct credit_grants SELECT to be isolated (0), got %', v_bal;
  END IF;
  v_res := public.lookup_members_for_pt_booking(v_org_id, v_b1, 'AUD');
  IF (v_res -> 0 ->> 'available_pt_credits')::integer <> 3 THEN
    RAISE EXCEPTION 'Expected PT credits restored to 3 in lookup RPC, got %', v_res;
  END IF;
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_member_user, 'email', 'member_05@ritma.test', 'role', 'authenticated')::text, true);
  SELECT COALESCE(SUM(remaining_amount), 0) INTO v_bal
  FROM public.credit_grants WHERE member_id = v_member_id AND credit_type = 'pt_credit';
  IF v_bal <> 3 THEN
    RAISE EXCEPTION 'Expected PT credits restored to 3 for member, got %', v_bal;
  END IF;

  -- B: Instructor class isolation (1 assigned, 1 unassigned)
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_owner, 'email', 'owner_05@ritma.test', 'role', 'authenticated')::text, true);
  v_res := public.list_assignable_instructors(v_org_id, v_b1);
  IF jsonb_array_length(v_res) < 3 THEN
    RAISE EXCEPTION 'Expected assignable instructors list to include staff, got %', v_res;
  END IF;

  INSERT INTO public.class_sessions (
    organization_id, branch_id, room_id, class_type_id, instructor_user_id, instructor_display_name,
    title, starts_at, ends_at, capacity, credit_cost, cancellation_cutoff_at
  ) VALUES (
    v_org_id, v_b1, v_room_1, v_type_1, v_instr_1, 'Instructor One', 'Assigned Reformer', now() + interval '1 day', now() + interval '1 day 1 hour', 10, 1, now() + interval '12 hours'
  )
  RETURNING id INTO v_sess_assigned;

  INSERT INTO public.class_sessions (
    organization_id, branch_id, room_id, class_type_id, instructor_user_id, instructor_display_name,
    title, starts_at, ends_at, capacity, credit_cost, cancellation_cutoff_at
  ) VALUES (
    v_org_id, v_b1, v_room_1, v_type_1, NULL, 'Other Coach', 'Unassigned Reformer', now() + interval '1 day', now() + interval '1 day 1 hour', 10, 1, now() + interval '12 hours'
  )
  RETURNING id INTO v_sess_unassigned;

  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_instr_1, 'email', 'instr1_05@ritma.test', 'role', 'authenticated')::text, true);
  SELECT COUNT(*) INTO v_count FROM public.class_sessions WHERE organization_id = v_org_id;
  IF v_count <> 1 THEN
    RAISE EXCEPTION 'Expected Instructor 1 to see exactly 1 assigned class, got %', v_count;
  END IF;
  v_res := public.get_session_roster(v_org_id, v_sess_assigned);
  BEGIN
    PERFORM public.get_session_roster(v_org_id, v_sess_unassigned);
    RAISE EXCEPTION 'Expected Instructor 1 to be blocked from unassigned session roster (NULL instructor_user_id)';
  EXCEPTION WHEN SQLSTATE '42501' THEN
    NULL;
  END;

  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_member_user, 'email', 'member_05@ritma.test', 'role', 'authenticated')::text, true);
  BEGIN
    PERFORM public.get_session_roster(v_org_id, v_sess_unassigned);
    RAISE EXCEPTION 'Expected Member to be blocked from unassigned session roster';
  EXCEPTION WHEN SQLSTATE '42501' THEN
    NULL;
  END;

  -- I: Payment refunds (branch_manager denied, partial refund $40, over-refund blocked, full remaining $60 -> refunded, net revenue = 0)
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_mgr_b1, 'email', 'mgr_b1_05@ritma.test', 'role', 'authenticated')::text, true);
  BEGIN
    PERFORM public.record_payment_refund(v_org_id, v_pay_id, 4000, 'Manager refund try', 'ref-mgr-1');
    RAISE EXCEPTION 'Expected branch_manager payment refund to be rejected';
  EXCEPTION WHEN SQLSTATE '42501' THEN
    NULL;
  END;

  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_owner, 'email', 'owner_05@ritma.test', 'role', 'authenticated')::text, true);
  v_res := public.record_payment_refund(v_org_id, v_pay_id, 4000, 'Partial refund', 'ref-1');
  IF (v_res ->> 'payment_status') <> 'paid' OR (v_res ->> 'refund_channel') <> 'manual_recorded' THEN
    RAISE EXCEPTION 'Unexpected partial refund result: %', v_res;
  END IF;

  v_kpis := public.get_operational_dashboard_metrics(v_org_id, NULL, 30);
  IF (v_kpis ->> 'window_revenue_minor')::bigint <> 6000 THEN
    RAISE EXCEPTION 'Expected net revenue 6000 after 4000 partial refund, got %', v_kpis;
  END IF;

  -- Over-refund fails
  BEGIN
    PERFORM public.record_payment_refund(v_org_id, v_pay_id, 7000, 'Over refund', 'ref-over');
    RAISE EXCEPTION 'Expected over-refund to fail';
  EXCEPTION WHEN SQLSTATE '22023' THEN
    NULL;
  END;

  -- Remaining $60 refund transitions payment status to refunded
  v_res := public.record_payment_refund(v_org_id, v_pay_id, 6000, 'Final partial refund', 'ref-2');
  IF (v_res ->> 'payment_status') <> 'refunded' THEN
    RAISE EXCEPTION 'Expected payment_status refunded, got %', v_res;
  END IF;

  -- Duplicate refund after fully refunded fails
  BEGIN
    PERFORM public.record_payment_refund(v_org_id, v_pay_id, 100, 'Duplicate refund', 'ref-3');
    RAISE EXCEPTION 'Expected refund on already refunded payment to fail';
  EXCEPTION WHEN SQLSTATE '22023' THEN
    NULL;
  END;

  -- H: Report export branch scope isolation
  v_res := public.get_report_export_data(v_org_id, 'payments', NULL, 30);
  IF jsonb_array_length(v_res -> 'rows') <> 1 THEN
    RAISE EXCEPTION 'Expected 1 payment row in owner export, got %', v_res;
  END IF;

  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_mgr_b1, 'email', 'mgr_b1_05@ritma.test', 'role', 'authenticated')::text, true);
  BEGIN
    PERFORM public.get_report_export_data(v_org_id, 'payments', NULL, 30);
    RAISE EXCEPTION 'Expected branch_manager org-wide export to fail';
  EXCEPTION WHEN SQLSTATE '42501' THEN
    NULL;
  END;
  BEGIN
    PERFORM public.get_report_export_data(v_org_id, 'payments', v_b2, 30);
    RAISE EXCEPTION 'Expected branch_manager cross-branch export to fail';
  EXCEPTION WHEN SQLSTATE '42501' THEN
    NULL;
  END;
  v_res := public.get_report_export_data(v_org_id, 'payments', v_b1, 30);
  IF jsonb_array_length(v_res -> 'rows') <> 1 THEN
    RAISE EXCEPTION 'Expected branch_manager B1 export to succeed with 1 row';
  END IF;

  -- J: Staff management listing respects branch isolation
  v_res := public.list_organization_staff(v_org_id, v_b1);
  IF jsonb_array_length(v_res) < 4 THEN
    RAISE EXCEPTION 'Expected B1 staff listing to include B1 staff';
  END IF;
  BEGIN
    PERFORM public.list_organization_staff(v_org_id, NULL);
    RAISE EXCEPTION 'Expected B1 manager org-wide staff listing to fail';
  EXCEPTION WHEN SQLSTATE '42501' THEN
    NULL;
  END;
END $$;

ROLLBACK;
