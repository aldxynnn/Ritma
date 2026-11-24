-- RITMA SQL Test 01: Multi-Tenant & Branch Isolation, Consent Invitations (C1), Composite FK Integrity, Role Hierarchy & Last-Owner Guard

BEGIN;

DO $$
DECLARE
  v_user_owner_a uuid := 'aaaaaaaa-0000-0000-0000-000000000001';
  v_user_mgr_a1 uuid := 'aaaaaaaa-0000-0000-0000-000000000002';
  v_user_admin_a uuid := 'aaaaaaaa-0000-0000-0000-000000000003';
  v_user_owner_b uuid := 'bbbbbbbb-0000-0000-0000-000000000001';
  v_org_a jsonb;
  v_org_b jsonb;
  v_org_a_id uuid;
  v_branch_a1 uuid;
  v_branch_a2 uuid;
  v_org_b_id uuid;
  v_branch_b1 uuid;
  v_inv_mgr jsonb;
  v_inv_admin jsonb;
  v_owner_assign_id uuid;
  v_count integer;
  v_err text;
BEGIN
  INSERT INTO auth.users (id, email) VALUES
    (v_user_owner_a, 'owner_a@ritma.test'),
    (v_user_mgr_a1, 'mgr_a1@ritma.test'),
    (v_user_admin_a, 'admin_a@ritma.test'),
    (v_user_owner_b, 'owner_b@ritma.test')
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.user_profiles (user_id, full_name, phone) VALUES
    (v_user_owner_b, 'Owner Beta Private', '+1-555-0199')
  ON CONFLICT (user_id) DO UPDATE SET phone = '+1-555-0199';

  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_user_owner_a, 'email', 'owner_a@ritma.test', 'role', 'authenticated')::text, true);
  SET LOCAL ROLE authenticated;

  v_org_a := public.create_organization_with_owner('Org Alpha', 'org-alpha-test', 'hybrid', 'UTC', 'USD', 'Alpha One', 'A1');
  v_org_a_id := (v_org_a ->> 'organization_id')::uuid;
  v_branch_a1 := (v_org_a ->> 'branch_id')::uuid;

  INSERT INTO public.branches (organization_id, name, code)
  VALUES (v_org_a_id, 'Alpha Two', 'A2')
  RETURNING id INTO v_branch_a2;

  -- C1 test: Cannot unilaterally attach an outside user without invitation consent
  BEGIN
    PERFORM public.assign_user_role(v_org_a_id, v_user_owner_b, 'member', NULL);
    RAISE EXCEPTION 'Expected CONSENT_REQUIRED failure';
  EXCEPTION WHEN SQLSTATE '42501' THEN
    NULL;
  END;

  -- C1 test: Attacker cannot read outside user_profiles PII
  SELECT COUNT(*) INTO v_count FROM public.user_profiles WHERE user_id = v_user_owner_b;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'PII leak detected: Owner A read Owner B profile';
  END IF;

  -- Consent-based invitation & acceptance flow
  v_inv_mgr := public.invite_user_to_organization(v_org_a_id, 'mgr_a1@ritma.test', 'branch_manager', v_branch_a1);
  v_inv_admin := public.invite_user_to_organization(v_org_a_id, 'admin_a@ritma.test', 'org_admin', NULL);

  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_user_mgr_a1, 'email', 'mgr_a1@ritma.test', 'role', 'authenticated')::text, true);
  PERFORM public.accept_organization_invitation(v_inv_mgr ->> 'token');

  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_user_admin_a, 'email', 'admin_a@ritma.test', 'role', 'authenticated')::text, true);
  PERFORM public.accept_organization_invitation(v_inv_admin ->> 'token');

  -- Verify Last Owner Guard (F8)
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_user_owner_a, 'email', 'owner_a@ritma.test', 'role', 'authenticated')::text, true);
  SELECT id INTO v_owner_assign_id
  FROM public.user_role_assignments
  WHERE organization_id = v_org_a_id AND user_id = v_user_owner_a AND status = 'active'
  LIMIT 1;

  BEGIN
    PERFORM public.revoke_user_role(v_org_a_id, v_owner_assign_id);
    RAISE EXCEPTION 'Expected LAST_ORG_OWNER failure';
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_err = MESSAGE_TEXT;
    IF v_err NOT LIKE '%LAST_ORG_OWNER%' THEN
      RAISE;
    END IF;
  END;

  -- Verify Org Admin cannot assign Org Owner (F8 privilege escalation blocked)
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_user_admin_a, 'email', 'admin_a@ritma.test', 'role', 'authenticated')::text, true);
  BEGIN
    PERFORM public.assign_user_role(v_org_a_id, v_user_admin_a, 'org_owner', NULL);
    RAISE EXCEPTION 'Expected privilege escalation rejection';
  EXCEPTION WHEN SQLSTATE '42501' THEN
    NULL;
  END;

  -- Act as Owner B and create Org B
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_user_owner_b, 'email', 'owner_b@ritma.test', 'role', 'authenticated')::text, true);
  v_org_b := public.create_organization_with_owner('Org Beta', 'org-beta-test', 'traditional_gym', 'UTC', 'USD', 'Beta One', 'B1');
  v_org_b_id := (v_org_b ->> 'organization_id')::uuid;
  v_branch_b1 := (v_org_b ->> 'branch_id')::uuid;

  -- Tenant isolation: Owner B sees 0 rows from Org A
  SELECT COUNT(*) INTO v_count FROM public.organizations WHERE id = v_org_a_id;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'Tenant isolation failed: Owner B read Org A';
  END IF;

  -- Branch isolation: Branch Manager A1 cannot invite staff in Branch A2
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_user_mgr_a1, 'email', 'mgr_a1@ritma.test', 'role', 'authenticated')::text, true);
  BEGIN
    PERFORM public.invite_user_to_organization(v_org_a_id, 'new_staff@ritma.test', 'receptionist', v_branch_a2);
    RAISE EXCEPTION 'Expected cross-branch role invite rejection';
  EXCEPTION WHEN SQLSTATE '42501' THEN
    NULL;
  END;

  -- Composite FK isolation (F1): inserting room with Org A + Branch B1 fails
  RESET ROLE;
  BEGIN
    INSERT INTO public.rooms (organization_id, branch_id, name, default_capacity)
    VALUES (v_org_a_id, v_branch_b1, 'Cross Tenant Room', 10);
    RAISE EXCEPTION 'Expected composite FK violation';
  EXCEPTION WHEN foreign_key_violation THEN
    NULL;
  END;
END $$;

ROLLBACK;
