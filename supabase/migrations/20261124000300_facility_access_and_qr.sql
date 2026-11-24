-- RITMA Migration 000300: Facility Access Engine & Per-Org Signed QR Check-In
-- Fixes H1 (NULL p_force_override bypass), H5 (revoked/rotated keys + rotation RPC), M1 (nonce replay prevention + server-clamped cooldown), M2 (idempotency fingerprint binding), M3 (manual check-in member status), M9 (PG15 column SET NULL), L6 (empty array guard).

-- ---------------------------------------------------------------------------
-- Base64url, Constant-Time Comparison & Nonce Replay Tracking (private schema)
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION private.base64url_encode(p_data bytea)
RETURNS text
LANGUAGE sql
IMMUTABLE
SET search_path = pg_catalog, public, pg_temp
AS $$
  SELECT replace(replace(replace(replace(encode(p_data, 'base64'), E'\n', ''), '+', '-'), '/', '_'), '=', '');
$$;

CREATE OR REPLACE FUNCTION private.base64url_decode(p_input text)
RETURNS bytea
LANGUAGE plpgsql
IMMUTABLE
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_norm text := replace(replace(p_input, '-', '+'), '_', '/');
  v_pad integer := (4 - (length(v_norm) % 4)) % 4;
BEGIN
  IF v_pad > 0 THEN
    v_norm := v_norm || repeat('=', v_pad);
  END IF;
  RETURN decode(v_norm, 'base64');
END;
$$;

CREATE OR REPLACE FUNCTION private.constant_time_equal(p_a bytea, p_b bytea)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_len integer;
  v_diff integer := 0;
  i integer;
BEGIN
  IF p_a IS NULL OR p_b IS NULL OR octet_length(p_a) <> octet_length(p_b) THEN
    RETURN false;
  END IF;
  v_len := octet_length(p_a);
  FOR i IN 0..(v_len - 1) LOOP
    v_diff := v_diff | (get_byte(p_a, i) # get_byte(p_b, i));
  END LOOP;
  RETURN v_diff = 0;
END;
$$;

-- Single-use QR nonce store preventing replay attacks across branches/cooldowns (M1).
CREATE TABLE private.qr_token_uses (
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  nonce text NOT NULL,
  expires_at timestamptz NOT NULL,
  used_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (organization_id, nonce)
);

CREATE INDEX idx_qr_token_uses_expires ON private.qr_token_uses (expires_at);
REVOKE ALL ON TABLE private.qr_token_uses FROM PUBLIC, anon, authenticated;

-- ---------------------------------------------------------------------------
-- Facility Visits & Access Attempts
-- ---------------------------------------------------------------------------

CREATE TABLE public.facility_visits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL,
  branch_id uuid NOT NULL,
  member_id uuid NOT NULL,
  entitlement_id uuid,
  check_in_method text NOT NULL CHECK (check_in_method IN ('qr', 'manual', 'manual_override')),
  override_reason text,
  checked_in_at timestamptz NOT NULL DEFAULT now(),
  checked_out_at timestamptz,
  checked_in_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  idempotency_key text NOT NULL,
  request_fingerprint text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (organization_id, branch_id)
    REFERENCES public.branches(organization_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (organization_id, member_id)
    REFERENCES public.members(organization_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (organization_id, entitlement_id)
    REFERENCES public.member_entitlements(organization_id, id) ON DELETE SET NULL (entitlement_id),
  UNIQUE (organization_id, idempotency_key),
  CHECK (checked_out_at IS NULL OR checked_out_at >= checked_in_at)
);

CREATE INDEX idx_facility_visits_branch_time
  ON public.facility_visits (organization_id, branch_id, checked_in_at DESC);

CREATE INDEX idx_facility_visits_member_cooldown
  ON public.facility_visits (organization_id, branch_id, member_id, checked_in_at DESC);

CREATE TABLE public.facility_access_attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  branch_id uuid NOT NULL,
  member_id uuid,
  result text NOT NULL CHECK (result IN ('allowed', 'denied')),
  reason_code text NOT NULL,
  scanned_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  attempted_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (organization_id, branch_id)
    REFERENCES public.branches(organization_id, id) ON DELETE RESTRICT,
  FOREIGN KEY (organization_id, member_id)
    REFERENCES public.members(organization_id, id) ON DELETE SET NULL (member_id)
);

CREATE INDEX idx_facility_attempts_branch_time
  ON public.facility_access_attempts (organization_id, branch_id, attempted_at DESC);

ALTER TABLE public.facility_visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.facility_visits FORCE ROW LEVEL SECURITY;
ALTER TABLE public.facility_access_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.facility_access_attempts FORCE ROW LEVEL SECURITY;

CREATE POLICY facility_visits_select ON public.facility_visits
  FOR SELECT TO authenticated
  USING (
    authz.is_self_member(organization_id, member_id)
    OR authz.has_permission(organization_id, branch_id, 'checkin.read')
  );

CREATE POLICY facility_attempts_select ON public.facility_access_attempts
  FOR SELECT TO authenticated
  USING (
    authz.is_self_member(organization_id, member_id)
    OR authz.has_permission(organization_id, branch_id, 'checkin.read')
  );

-- ---------------------------------------------------------------------------
-- Key Rotation, QR Issuance & Validation RPCs
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.rotate_org_signing_key(p_org_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_current_version integer := 0;
  v_new_version integer;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  IF NOT authz.has_permission(p_org_id, NULL, 'org.manage') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing org.manage permission' USING ERRCODE = '42501';
  END IF;

  PERFORM id
  FROM private.organization_signing_keys
  WHERE organization_id = p_org_id
  FOR UPDATE;

  SELECT COALESCE(MAX(key_version), 0) INTO v_current_version
  FROM private.organization_signing_keys
  WHERE organization_id = p_org_id;

  UPDATE private.organization_signing_keys
  SET is_active = false, rotated_at = now()
  WHERE organization_id = p_org_id AND is_active = true;

  v_new_version := v_current_version + 1;

  INSERT INTO private.organization_signing_keys (
    organization_id, key_version, secret_key, is_active
  ) VALUES (
    p_org_id, v_new_version, extensions.gen_random_bytes(32), true
  );

  INSERT INTO public.audit_logs (
    organization_id, actor_user_id, action, target_type, target_id, metadata
  ) VALUES (
    p_org_id, v_actor_id, 'signing_key.rotated', 'organization', p_org_id,
    jsonb_build_object('new_key_version', v_new_version)
  );

  RETURN jsonb_build_object('key_version', v_new_version);
END;
$$;

CREATE OR REPLACE FUNCTION public.issue_member_qr_token(
  p_org_id uuid,
  p_member_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_member public.members%ROWTYPE;
  v_key private.organization_signing_keys%ROWTYPE;
  v_issued_at bigint := floor(extract(epoch FROM now()))::bigint;
  v_expires_at bigint := v_issued_at + 60;
  v_nonce text := encode(extensions.gen_random_bytes(12), 'hex');
  v_payload text;
  v_payload_b64 text;
  v_sig bytea;
  v_token text;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  IF NOT authz.is_self_member(p_org_id, p_member_id)
     AND NOT authz.has_any_branch_permission(p_org_id, 'checkin.perform') THEN
    RAISE EXCEPTION 'FORBIDDEN: Not authorized to generate QR pass for this member'
      USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_member
  FROM public.members
  WHERE id = p_member_id AND organization_id = p_org_id;
  IF NOT FOUND OR v_member.status = 'archived' THEN
    RAISE EXCEPTION 'NOT_FOUND: Member not found' USING ERRCODE = 'P0002';
  END IF;

  SELECT * INTO v_key
  FROM private.organization_signing_keys
  WHERE organization_id = p_org_id AND is_active = true
  ORDER BY key_version DESC
  LIMIT 1;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'INTERNAL_ERROR: Active organization signing key missing'
      USING ERRCODE = 'P0001';
  END IF;

  -- Canonical token format: v1.<base64url(org_id|member_id|issued_epoch|expires_epoch|key_version|nonce)>.<sig>
  v_payload := p_org_id::text || '|' || p_member_id::text || '|' ||
    v_issued_at::text || '|' || v_expires_at::text || '|' ||
    v_key.key_version::text || '|' || v_nonce;
  v_payload_b64 := private.base64url_encode(convert_to(v_payload, 'UTF8'));
  v_sig := extensions.hmac(convert_to(v_payload_b64, 'UTF8'), v_key.secret_key, 'sha256');
  v_token := 'v1.' || v_payload_b64 || '.' || private.base64url_encode(v_sig);

  RETURN jsonb_build_object(
    'token', v_token,
    'issued_at', to_timestamp(v_issued_at),
    'expires_at', to_timestamp(v_expires_at),
    'ttl_seconds', 60
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.validate_and_check_in(
  p_org_id uuid,
  p_branch_id uuid,
  p_qr_token text,
  p_idempotency_key text,
  p_cooldown_minutes integer DEFAULT 15
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_key text := 'qr:' || COALESCE(NULLIF(trim(p_idempotency_key), ''), gen_random_uuid()::text);
  v_fingerprint text := encode(
    extensions.digest(convert_to(p_branch_id::text || '|' || COALESCE(p_qr_token, ''), 'UTF8'), 'sha256'),
    'hex'
  );
  v_cooldown integer := GREATEST(COALESCE(p_cooldown_minutes, 15), 1);
  v_existing_visit public.facility_visits%ROWTYPE;
  v_parts text[];
  v_payload_str text;
  v_fields text[];
  v_token_org_id uuid;
  v_member_id uuid;
  v_issued_epoch bigint;
  v_expires_epoch bigint;
  v_key_version integer;
  v_nonce text;
  v_used_nonce text;
  v_sig_bytes bytea;
  v_expected_sig bytea;
  v_signing_key bytea;
  v_member public.members%ROWTYPE;
  v_entitlement public.member_entitlements%ROWTYPE;
  v_visit_id uuid;
  v_has_other_branch boolean;
  v_now_epoch bigint := floor(extract(epoch FROM now()))::bigint;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  IF NOT authz.has_permission(p_org_id, p_branch_id, 'checkin.perform') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing checkin.perform permission for this branch'
      USING ERRCODE = '42501';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.branches
    WHERE id = p_branch_id AND organization_id = p_org_id AND is_active = true
  ) THEN
    RAISE EXCEPTION 'NOT_FOUND: Active branch not found in organization' USING ERRCODE = 'P0002';
  END IF;

  -- Idempotency replay bound to fingerprint (M2)
  SELECT * INTO v_existing_visit
  FROM public.facility_visits
  WHERE organization_id = p_org_id AND idempotency_key = v_key;
  IF FOUND THEN
    IF v_existing_visit.request_fingerprint <> v_fingerprint THEN
      RAISE EXCEPTION 'IDEMPOTENCY_KEY_REUSED: Key already used for different check-in request'
        USING ERRCODE = '23505';
    END IF;
    RETURN jsonb_build_object(
      'allowed', true,
      'reason_code', 'OK',
      'visit_id', v_existing_visit.id,
      'member_id', v_existing_visit.member_id,
      'idempotent_replay', true
    );
  END IF;

  -- Parse token safely (L6 NULL array_length guard)
  v_parts := string_to_array(trim(COALESCE(p_qr_token, '')), '.');
  IF COALESCE(array_length(v_parts, 1), 0) <> 3 OR v_parts[1] <> 'v1' THEN
    INSERT INTO public.facility_access_attempts (organization_id, branch_id, result, reason_code, scanned_by)
    VALUES (p_org_id, p_branch_id, 'denied', 'QR_MALFORMED', v_actor_id);
    RETURN jsonb_build_object('allowed', false, 'reason_code', 'QR_MALFORMED');
  END IF;

  BEGIN
    v_payload_str := convert_from(private.base64url_decode(v_parts[2]), 'UTF8');
    v_sig_bytes := private.base64url_decode(v_parts[3]);
    v_fields := string_to_array(v_payload_str, '|');
    IF COALESCE(array_length(v_fields, 1), 0) <> 6 THEN
      RAISE EXCEPTION 'bad_fields';
    END IF;
    v_token_org_id := v_fields[1]::uuid;
    v_member_id := v_fields[2]::uuid;
    v_issued_epoch := v_fields[3]::bigint;
    v_expires_epoch := v_fields[4]::bigint;
    v_key_version := v_fields[5]::integer;
    v_nonce := v_fields[6];
    IF length(COALESCE(v_nonce, '')) < 8 THEN
      RAISE EXCEPTION 'bad_nonce';
    END IF;
  EXCEPTION WHEN OTHERS THEN
    INSERT INTO public.facility_access_attempts (organization_id, branch_id, result, reason_code, scanned_by)
    VALUES (p_org_id, p_branch_id, 'denied', 'QR_MALFORMED', v_actor_id);
    RETURN jsonb_build_object('allowed', false, 'reason_code', 'QR_MALFORMED');
  END;

  IF v_token_org_id <> p_org_id THEN
    INSERT INTO public.facility_access_attempts (organization_id, branch_id, result, reason_code, scanned_by)
    VALUES (p_org_id, p_branch_id, 'denied', 'QR_ORG_MISMATCH', v_actor_id);
    RETURN jsonb_build_object('allowed', false, 'reason_code', 'QR_ORG_MISMATCH');
  END IF;

  -- Enforce active signing key OR short 2-minute rotation grace window (H5)
  SELECT secret_key INTO v_signing_key
  FROM private.organization_signing_keys
  WHERE organization_id = p_org_id
    AND key_version = v_key_version
    AND (is_active = true OR rotated_at > now() - interval '2 minutes');

  IF v_signing_key IS NULL THEN
    INSERT INTO public.facility_access_attempts (organization_id, branch_id, result, reason_code, scanned_by)
    VALUES (p_org_id, p_branch_id, 'denied', 'QR_INVALID_KEY', v_actor_id);
    RETURN jsonb_build_object('allowed', false, 'reason_code', 'QR_INVALID_KEY');
  END IF;

  v_expected_sig := extensions.hmac(convert_to(v_parts[2], 'UTF8'), v_signing_key, 'sha256');
  IF NOT private.constant_time_equal(v_sig_bytes, v_expected_sig) THEN
    INSERT INTO public.facility_access_attempts (organization_id, branch_id, result, reason_code, scanned_by)
    VALUES (p_org_id, p_branch_id, 'denied', 'QR_INVALID_SIGNATURE', v_actor_id);
    RETURN jsonb_build_object('allowed', false, 'reason_code', 'QR_INVALID_SIGNATURE');
  END IF;

  -- Enforce tight token lifetime bounds & expiry (H5)
  IF v_expires_epoch < v_issued_epoch
     OR (v_expires_epoch - v_issued_epoch) > 65
     OR v_issued_epoch > (v_now_epoch + 10) THEN
    INSERT INTO public.facility_access_attempts (organization_id, branch_id, result, reason_code, scanned_by)
    VALUES (p_org_id, p_branch_id, 'denied', 'QR_MALFORMED', v_actor_id);
    RETURN jsonb_build_object('allowed', false, 'reason_code', 'QR_MALFORMED');
  END IF;

  SELECT * INTO v_member
  FROM public.members
  WHERE id = v_member_id AND organization_id = p_org_id;
  IF NOT FOUND THEN
    INSERT INTO public.facility_access_attempts (organization_id, branch_id, result, reason_code, scanned_by)
    VALUES (p_org_id, p_branch_id, 'denied', 'MEMBER_NOT_FOUND', v_actor_id);
    RETURN jsonb_build_object('allowed', false, 'reason_code', 'MEMBER_NOT_FOUND');
  END IF;

  IF v_now_epoch > (v_expires_epoch + 10) THEN
    INSERT INTO public.facility_access_attempts (organization_id, branch_id, member_id, result, reason_code, scanned_by)
    VALUES (p_org_id, p_branch_id, v_member_id, 'denied', 'QR_TOKEN_EXPIRED', v_actor_id);
    RETURN jsonb_build_object('allowed', false, 'reason_code', 'QR_TOKEN_EXPIRED', 'member_name', v_member.full_name);
  END IF;

  -- Single-use nonce enforcement (M1)
  DELETE FROM private.qr_token_uses WHERE expires_at < now() - interval '1 day';

  INSERT INTO private.qr_token_uses (organization_id, nonce, expires_at)
  VALUES (p_org_id, v_nonce, to_timestamp(v_expires_epoch + 10))
  ON CONFLICT (organization_id, nonce) DO NOTHING
  RETURNING nonce INTO v_used_nonce;

  IF v_used_nonce IS NULL THEN
    INSERT INTO public.facility_access_attempts (organization_id, branch_id, member_id, result, reason_code, scanned_by)
    VALUES (p_org_id, p_branch_id, v_member_id, 'denied', 'QR_REPLAYED', v_actor_id);
    RETURN jsonb_build_object('allowed', false, 'reason_code', 'QR_REPLAYED', 'member_name', v_member.full_name);
  END IF;

  PERFORM pg_advisory_xact_lock(hashtextextended(v_member_id::text || ':' || p_branch_id::text, 0));

  IF v_member.status = 'frozen' THEN
    INSERT INTO public.facility_access_attempts (organization_id, branch_id, member_id, result, reason_code, scanned_by)
    VALUES (p_org_id, p_branch_id, v_member_id, 'denied', 'MEMBER_FROZEN', v_actor_id);
    RETURN jsonb_build_object('allowed', false, 'reason_code', 'MEMBER_FROZEN', 'member_name', v_member.full_name);
  ELSIF v_member.status <> 'active' THEN
    INSERT INTO public.facility_access_attempts (organization_id, branch_id, member_id, result, reason_code, scanned_by)
    VALUES (p_org_id, p_branch_id, v_member_id, 'denied', 'MEMBER_INACTIVE', v_actor_id);
    RETURN jsonb_build_object('allowed', false, 'reason_code', 'MEMBER_INACTIVE', 'member_name', v_member.full_name);
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.facility_visits fv
    WHERE fv.organization_id = p_org_id
      AND fv.branch_id = p_branch_id
      AND fv.member_id = v_member_id
      AND fv.checked_in_at > now() - make_interval(mins => v_cooldown)
  ) THEN
    INSERT INTO public.facility_access_attempts (organization_id, branch_id, member_id, result, reason_code, scanned_by)
    VALUES (p_org_id, p_branch_id, v_member_id, 'denied', 'DUPLICATE_COOLDOWN', v_actor_id);
    RETURN jsonb_build_object('allowed', false, 'reason_code', 'DUPLICATE_COOLDOWN', 'member_name', v_member.full_name);
  END IF;

  SELECT me.* INTO v_entitlement
  FROM public.member_entitlements me
  WHERE me.organization_id = p_org_id
    AND me.member_id = v_member_id
    AND me.entitlement_kind = 'facility_access'
    AND me.status = 'active'
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
  ORDER BY me.valid_until DESC
  LIMIT 1;

  IF NOT FOUND THEN
    SELECT EXISTS (
      SELECT 1 FROM public.member_entitlements me
      WHERE me.organization_id = p_org_id
        AND me.member_id = v_member_id
        AND me.entitlement_kind = 'facility_access'
        AND me.status = 'active'
        AND me.valid_from <= now()
        AND me.valid_until > now()
    ) INTO v_has_other_branch;

    INSERT INTO public.facility_access_attempts (organization_id, branch_id, member_id, result, reason_code, scanned_by)
    VALUES (
      p_org_id, p_branch_id, v_member_id, 'denied',
      CASE WHEN v_has_other_branch THEN 'BRANCH_NOT_COVERED' ELSE 'NO_FACILITY_ENTITLEMENT' END,
      v_actor_id
    );

    RETURN jsonb_build_object(
      'allowed', false,
      'reason_code', CASE WHEN v_has_other_branch THEN 'BRANCH_NOT_COVERED' ELSE 'NO_FACILITY_ENTITLEMENT' END,
      'member_id', v_member_id,
      'member_name', v_member.full_name
    );
  END IF;

  INSERT INTO public.facility_visits (
    organization_id, branch_id, member_id, entitlement_id,
    check_in_method, checked_in_by, idempotency_key, request_fingerprint
  ) VALUES (
    p_org_id, p_branch_id, v_member_id, v_entitlement.id,
    'qr', v_actor_id, v_key, v_fingerprint
  )
  RETURNING id INTO v_visit_id;

  INSERT INTO public.facility_access_attempts (
    organization_id, branch_id, member_id, result, reason_code, scanned_by
  ) VALUES (
    p_org_id, p_branch_id, v_member_id, 'allowed', 'OK', v_actor_id
  );

  RETURN jsonb_build_object(
    'allowed', true,
    'reason_code', 'OK',
    'visit_id', v_visit_id,
    'member_id', v_member_id,
    'member_name', v_member.full_name,
    'entitlement_valid_until', v_entitlement.valid_until,
    'idempotent_replay', false
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.manual_facility_check_in(
  p_org_id uuid,
  p_branch_id uuid,
  p_member_id uuid,
  p_force_override boolean DEFAULT false,
  p_reason text DEFAULT NULL,
  p_idempotency_key text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, extensions, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_force boolean := COALESCE(p_force_override, false);
  v_key text := 'manual:' || COALESCE(NULLIF(trim(p_idempotency_key), ''), gen_random_uuid()::text);
  v_fingerprint text := encode(
    extensions.digest(convert_to(p_branch_id::text || '|' || p_member_id::text || '|' || v_force::text, 'UTF8'), 'sha256'),
    'hex'
  );
  v_existing public.facility_visits%ROWTYPE;
  v_member public.members%ROWTYPE;
  v_entitlement_id uuid;
  v_visit_id uuid;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  IF NOT authz.has_permission(p_org_id, p_branch_id, 'checkin.perform') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing checkin.perform permission' USING ERRCODE = '42501';
  END IF;

  IF v_force THEN
    IF NOT authz.has_permission(p_org_id, p_branch_id, 'checkin.force_override') THEN
      RAISE EXCEPTION 'FORBIDDEN: Missing checkin.force_override permission' USING ERRCODE = '42501';
    END IF;
    IF NULLIF(trim(p_reason), '') IS NULL THEN
      RAISE EXCEPTION 'VALIDATION_ERROR: Override reason is required' USING ERRCODE = '22023';
    END IF;
  END IF;

  SELECT * INTO v_existing
  FROM public.facility_visits
  WHERE organization_id = p_org_id AND idempotency_key = v_key;
  IF FOUND THEN
    IF v_existing.request_fingerprint <> v_fingerprint THEN
      RAISE EXCEPTION 'IDEMPOTENCY_KEY_REUSED: Key already used for different check-in'
        USING ERRCODE = '23505';
    END IF;
    RETURN jsonb_build_object('allowed', true, 'visit_id', v_existing.id, 'idempotent_replay', true);
  END IF;

  PERFORM pg_advisory_xact_lock(hashtextextended(p_member_id::text || ':' || p_branch_id::text, 0));

  SELECT * INTO v_member FROM public.members WHERE id = p_member_id AND organization_id = p_org_id;
  IF NOT FOUND OR v_member.status = 'archived' THEN
    RAISE EXCEPTION 'NOT_FOUND: Member not found' USING ERRCODE = 'P0002';
  END IF;

  -- Enforce member status identically to QR path unless force-override is explicitly authorized (M3)
  IF NOT v_force THEN
    IF v_member.status = 'frozen' THEN
      INSERT INTO public.facility_access_attempts (organization_id, branch_id, member_id, result, reason_code, scanned_by)
      VALUES (p_org_id, p_branch_id, p_member_id, 'denied', 'MEMBER_FROZEN', v_actor_id);
      RETURN jsonb_build_object('allowed', false, 'reason_code', 'MEMBER_FROZEN');
    ELSIF v_member.status <> 'active' THEN
      INSERT INTO public.facility_access_attempts (organization_id, branch_id, member_id, result, reason_code, scanned_by)
      VALUES (p_org_id, p_branch_id, p_member_id, 'denied', 'MEMBER_INACTIVE', v_actor_id);
      RETURN jsonb_build_object('allowed', false, 'reason_code', 'MEMBER_INACTIVE');
    END IF;
  END IF;

  SELECT me.id INTO v_entitlement_id
  FROM public.member_entitlements me
  WHERE me.organization_id = p_org_id
    AND me.member_id = p_member_id
    AND me.entitlement_kind = 'facility_access'
    AND me.status = 'active'
    AND me.valid_from <= now()
    AND me.valid_until > now()
    AND (
      me.branch_access_scope = 'all_branches'
      OR EXISTS (
        SELECT 1 FROM public.member_entitlement_branches meb
        WHERE meb.organization_id = p_org_id AND meb.entitlement_id = me.id AND meb.branch_id = p_branch_id
      )
    )
  ORDER BY me.valid_until DESC
  LIMIT 1;

  IF v_entitlement_id IS NULL AND NOT v_force THEN
    INSERT INTO public.facility_access_attempts (organization_id, branch_id, member_id, result, reason_code, scanned_by)
    VALUES (p_org_id, p_branch_id, p_member_id, 'denied', 'NO_FACILITY_ENTITLEMENT', v_actor_id);
    RETURN jsonb_build_object('allowed', false, 'reason_code', 'NO_FACILITY_ENTITLEMENT');
  END IF;

  INSERT INTO public.facility_visits (
    organization_id, branch_id, member_id, entitlement_id,
    check_in_method, override_reason, checked_in_by, idempotency_key, request_fingerprint
  ) VALUES (
    p_org_id, p_branch_id, p_member_id, v_entitlement_id,
    CASE WHEN v_entitlement_id IS NULL OR v_member.status <> 'active' THEN 'manual_override' ELSE 'manual' END,
    CASE WHEN v_entitlement_id IS NULL OR v_member.status <> 'active' THEN trim(p_reason) ELSE NULL END,
    v_actor_id, v_key, v_fingerprint
  )
  RETURNING id INTO v_visit_id;

  INSERT INTO public.facility_access_attempts (
    organization_id, branch_id, member_id, result, reason_code, scanned_by
  ) VALUES (
    p_org_id, p_branch_id, p_member_id, 'allowed',
    CASE WHEN v_entitlement_id IS NULL OR v_member.status <> 'active' THEN 'MANUAL_OVERRIDE' ELSE 'OK' END,
    v_actor_id
  );

  IF v_entitlement_id IS NULL OR v_member.status <> 'active' THEN
    INSERT INTO public.audit_logs (
      organization_id, branch_id, actor_user_id, action, target_type, target_id, metadata
    ) VALUES (
      p_org_id, p_branch_id, v_actor_id, 'checkin.force_override', 'facility_visit', v_visit_id,
      jsonb_build_object('member_id', p_member_id, 'reason', trim(p_reason))
    );
  END IF;

  RETURN jsonb_build_object('allowed', true, 'reason_code', 'OK', 'visit_id', v_visit_id, 'idempotent_replay', false);
END;
$$;

CREATE OR REPLACE FUNCTION public.check_out_facility_visit(
  p_org_id uuid,
  p_visit_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $$
DECLARE
  v_actor_id uuid := (SELECT auth.uid());
  v_visit public.facility_visits%ROWTYPE;
BEGIN
  IF v_actor_id IS NULL THEN
    RAISE EXCEPTION 'UNAUTHORIZED: Authentication required' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_visit FROM public.facility_visits
  WHERE id = p_visit_id AND organization_id = p_org_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'NOT_FOUND: Facility visit not found' USING ERRCODE = 'P0002';
  END IF;

  IF NOT authz.has_permission(p_org_id, v_visit.branch_id, 'checkin.perform') THEN
    RAISE EXCEPTION 'FORBIDDEN: Missing checkin.perform permission' USING ERRCODE = '42501';
  END IF;

  UPDATE public.facility_visits
  SET checked_out_at = COALESCE(checked_out_at, now())
  WHERE id = p_visit_id;
END;
$$;

REVOKE ALL ON FUNCTION public.rotate_org_signing_key(uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.issue_member_qr_token(uuid, uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.validate_and_check_in(uuid, uuid, text, text, integer) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.manual_facility_check_in(uuid, uuid, uuid, boolean, text, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.check_out_facility_visit(uuid, uuid) FROM PUBLIC, anon;

GRANT EXECUTE ON FUNCTION public.rotate_org_signing_key(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.issue_member_qr_token(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.validate_and_check_in(uuid, uuid, text, text, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.manual_facility_check_in(uuid, uuid, uuid, boolean, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.check_out_facility_visit(uuid, uuid) TO authenticated;

REVOKE TRUNCATE, TRIGGER, REFERENCES ON ALL TABLES IN SCHEMA public FROM anon, authenticated;
