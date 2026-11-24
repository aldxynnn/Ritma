-- RITMA SQL Test 04: Rotating QR Issuance, Nonce Replay (M1), NULL Override Bypass Defense (H1), Key Rotation (H5) & Cross-Org Check-In

BEGIN;

DO $$
DECLARE
  v_owner uuid := 'aaaaaaaa-3333-0000-0000-000000000001';
  v_recep uuid := 'aaaaaaaa-3333-0000-0000-000000000003';
  v_other_owner uuid := 'bbbbbbbb-3333-0000-0000-000000000001';
  v_member_user uuid := 'aaaaaaaa-3333-0000-0000-000000000002';
  v_org jsonb;
  v_org_id uuid;
  v_branch_1 uuid;
  v_branch_2 uuid;
  v_other_org jsonb;
  v_other_org_id uuid;
  v_other_branch uuid;
  v_pkg_branch1 uuid;
  v_member_id uuid;
  v_member_no_pass uuid;
  v_inv_recep jsonb;
  v_claim jsonb;
  v_qr jsonb;
  v_token text;
  v_tampered text;
  v_res jsonb;
BEGIN
  INSERT INTO auth.users (id, email) VALUES
    (v_owner, 'owner_qr@ritma.test'),
    (v_recep, 'recep_qr@ritma.test'),
    (v_other_owner, 'other_qr@ritma.test'),
    (v_member_user, 'member_qr@ritma.test')
  ON CONFLICT (id) DO NOTHING;

  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_owner, 'email', 'owner_qr@ritma.test', 'role', 'authenticated')::text, true);
  SET LOCAL ROLE authenticated;

  v_org := public.create_organization_with_owner('QR Club', 'qr-club', 'traditional_gym', 'UTC', 'USD', 'Branch 1', 'B1');
  v_org_id := (v_org ->> 'organization_id')::uuid;
  v_branch_1 := (v_org ->> 'branch_id')::uuid;

  INSERT INTO public.branches (organization_id, name, code)
  VALUES (v_org_id, 'Branch 2', 'B2') RETURNING id INTO v_branch_2;

  v_inv_recep := public.invite_user_to_organization(v_org_id, 'recep_qr@ritma.test', 'receptionist', v_branch_1);
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_recep, 'email', 'recep_qr@ritma.test', 'role', 'authenticated')::text, true);
  PERFORM public.accept_organization_invitation(v_inv_recep ->> 'token');

  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_owner, 'email', 'owner_qr@ritma.test', 'role', 'authenticated')::text, true);

  INSERT INTO public.packages (organization_id, name, package_type, price_minor)
  VALUES (v_org_id, 'Branch 1 Gym', 'gym_membership', 5000) RETURNING id INTO v_pkg_branch1;
  INSERT INTO public.package_entitlement_rules (organization_id, package_id, entitlement_kind, duration_days, branch_access_scope)
  VALUES (v_org_id, v_pkg_branch1, 'facility_access', 30, 'single_branch');

  INSERT INTO public.members (organization_id, home_branch_id, member_code, full_name)
  VALUES
    (v_org_id, v_branch_1, 'QR-001', 'QR Member'),
    (v_org_id, v_branch_1, 'QR-002', 'No Pass Member');

  SELECT id INTO v_member_id FROM public.members WHERE member_code = 'QR-001' AND organization_id = v_org_id;
  SELECT id INTO v_member_no_pass FROM public.members WHERE member_code = 'QR-002' AND organization_id = v_org_id;

  v_claim := public.invite_member_claim(v_org_id, v_member_id, 'member_qr@ritma.test');
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_member_user, 'email', 'member_qr@ritma.test', 'role', 'authenticated')::text, true);
  PERFORM public.claim_member_profile(v_claim ->> 'token');

  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_owner, 'email', 'owner_qr@ritma.test', 'role', 'authenticated')::text, true);
  PERFORM public.assign_package_to_member(v_org_id, v_branch_1, v_member_id, v_pkg_branch1, now(), 'cash', 'qr-assign-1');

  -- H1 test: Receptionist passing p_force_override = NULL must NOT admit member without entitlement
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_recep, 'email', 'recep_qr@ritma.test', 'role', 'authenticated')::text, true);
  v_res := public.manual_facility_check_in(v_org_id, v_branch_1, v_member_no_pass, NULL, NULL, 'null-bypass-test');
  IF (v_res ->> 'allowed')::boolean IS NOT FALSE OR (v_res ->> 'reason_code') <> 'NO_FACILITY_ENTITLEMENT' THEN
    RAISE EXCEPTION 'Expected H1 NULL override to deny check-in, got %', v_res;
  END IF;

  -- Member issues own rotating QR token
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_member_user, 'email', 'member_qr@ritma.test', 'role', 'authenticated')::text, true);
  v_qr := public.issue_member_qr_token(v_org_id, v_member_id);
  v_token := v_qr ->> 'token';

  -- Staff validates at Branch 1 -> ALLOWED
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_owner, 'email', 'owner_qr@ritma.test', 'role', 'authenticated')::text, true);
  v_res := public.validate_and_check_in(v_org_id, v_branch_1, v_token, 'scan-1', 15);
  IF (v_res ->> 'allowed')::boolean IS NOT TRUE THEN
    RAISE EXCEPTION 'Expected Branch 1 QR check-in to succeed: %', v_res;
  END IF;

  -- M1 test: Replaying the exact same QR token (even at Branch 2) MUST fail with QR_REPLAYED
  v_res := public.validate_and_check_in(v_org_id, v_branch_2, v_token, 'scan-replay-b2', 15);
  IF (v_res ->> 'reason_code') <> 'QR_REPLAYED' THEN
    RAISE EXCEPTION 'Expected QR_REPLAYED on nonce reuse, got %', v_res;
  END IF;

  -- Fresh token at Branch 2 -> BRANCH_NOT_COVERED
  v_qr := public.issue_member_qr_token(v_org_id, v_member_id);
  v_res := public.validate_and_check_in(v_org_id, v_branch_2, v_qr ->> 'token', 'scan-b2', 15);
  IF (v_res ->> 'reason_code') <> 'BRANCH_NOT_COVERED' THEN
    RAISE EXCEPTION 'Expected BRANCH_NOT_COVERED, got %', v_res;
  END IF;

  -- Tampered signature -> QR_INVALID_SIGNATURE
  v_tampered := substr(v_qr ->> 'token', 1, length(v_qr ->> 'token') - 2) || 'XX';
  v_res := public.validate_and_check_in(v_org_id, v_branch_1, v_tampered, 'scan-tamper', 15);
  IF (v_res ->> 'reason_code') <> 'QR_INVALID_SIGNATURE' THEN
    RAISE EXCEPTION 'Expected QR_INVALID_SIGNATURE, got %', v_res;
  END IF;

  -- H5 test: Key rotation issues version 2 cleanly
  IF (public.rotate_org_signing_key(v_org_id) ->> 'key_version')::integer <> 2 THEN
    RAISE EXCEPTION 'Expected rotated key_version 2';
  END IF;

  -- Cross-org scan -> QR_ORG_MISMATCH
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_other_owner, 'email', 'other_qr@ritma.test', 'role', 'authenticated')::text, true);
  v_other_org := public.create_organization_with_owner('Other Club', 'other-club', 'traditional_gym', 'UTC', 'USD', 'Other', 'OTH');
  v_other_org_id := (v_other_org ->> 'organization_id')::uuid;
  v_other_branch := (v_other_org ->> 'branch_id')::uuid;

  v_res := public.validate_and_check_in(v_other_org_id, v_other_branch, v_qr ->> 'token', 'scan-cross-org', 15);
  IF (v_res ->> 'reason_code') <> 'QR_ORG_MISMATCH' THEN
    RAISE EXCEPTION 'Expected QR_ORG_MISMATCH, got %', v_res;
  END IF;
END $$;

ROLLBACK;
