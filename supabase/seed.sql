-- RITMA Local Development Seed (NON-PRODUCTION ONLY)
-- Demonstrates multi-branch hybrid fitness operations:
--   Organization: Ritma Flagship Club (Traditional Gym + Boutique Studio)
--   Branches: Downtown Studio (DTN), Westside Athletic (WST)
--   Packages: Gym-Only Monthly, 10-Class Pilates Pack, Hybrid All-Access
-- Safe and idempotent when executed against local Supabase (`supabase db reset`).

DO $$
DECLARE
  v_org_id uuid := '11111111-1111-1111-1111-111111111111';
  v_branch_dtn uuid := '22222222-2222-2222-2222-222222222201';
  v_branch_wst uuid := '22222222-2222-2222-2222-222222222202';
  v_room_reformer uuid := '33333333-3333-3333-3333-333333333301';
  v_room_turf uuid := '33333333-3333-3333-3333-333333333302';
  v_type_pilates uuid := '44444444-4444-4444-4444-444444444401';
  v_type_hiit uuid := '44444444-4444-4444-4444-444444444402';
  v_pkg_gym uuid := '55555555-5555-5555-5555-555555555501';
  v_pkg_pilates uuid := '55555555-5555-5555-5555-555555555502';
  v_pkg_hybrid uuid := '55555555-5555-5555-5555-555555555503';
BEGIN
  INSERT INTO public.organizations (id, name, slug, business_type, timezone, currency_code)
  VALUES (v_org_id, 'Ritma Flagship Club', 'ritma-flagship', 'hybrid', 'Asia/Jakarta', 'USD')
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO private.organization_signing_keys (organization_id, key_version, secret_key, is_active)
  VALUES (v_org_id, 1, extensions.gen_random_bytes(32), true)
  ON CONFLICT (organization_id, key_version) DO NOTHING;

  INSERT INTO public.branches (id, organization_id, name, code, address, timezone) VALUES
    (v_branch_dtn, v_org_id, 'Downtown Studio', 'DTN', '120 Sudirman Ave', 'Asia/Jakarta'),
    (v_branch_wst, v_org_id, 'Westside Athletic', 'WST', '45 Kemang Rd', 'Asia/Jakarta')
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.rooms (id, organization_id, branch_id, name, room_type, default_capacity) VALUES
    (v_room_reformer, v_org_id, v_branch_dtn, 'Reformer Lab', 'pilates_studio', 12),
    (v_room_turf, v_org_id, v_branch_wst, 'Performance Turf', 'functional', 20)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.class_types (id, organization_id, name, color_token) VALUES
    (v_type_pilates, v_org_id, 'Reformer Pilates', 'sage'),
    (v_type_hiit, v_org_id, 'Kinetic Conditioning', 'lime')
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.packages (id, organization_id, name, description, package_type, price_minor, currency_code) VALUES
    (v_pkg_gym, v_org_id, 'Open Gym Monthly (Single Branch)', 'Unlimited gym floor entry at assigned branch. Does not include studio credits.', 'gym_membership', 8900, 'USD'),
    (v_pkg_pilates, v_org_id, '10-Class Pilates Pack', '10 studio credits valid across all branches. Does not include open-gym floor entry.', 'class_pack', 24000, 'USD'),
    (v_pkg_hybrid, v_org_id, 'Ritma All-Access Hybrid', 'All-branch gym floor access + 8 monthly class credits.', 'hybrid', 28900, 'USD')
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.package_entitlement_rules (id, organization_id, package_id, entitlement_kind, duration_days, credit_quantity, branch_access_scope, class_scope) VALUES
    ('66666666-6666-6666-6666-666666666601', v_org_id, v_pkg_gym, 'facility_access', 30, NULL, 'single_branch', 'all_classes'),
    ('66666666-6666-6666-6666-666666666602', v_org_id, v_pkg_pilates, 'class_credit', 90, 10, 'all_branches', 'selected_classes'),
    ('66666666-6666-6666-6666-666666666603', v_org_id, v_pkg_hybrid, 'facility_access', 30, NULL, 'all_branches', 'all_classes'),
    ('66666666-6666-6666-6666-666666666604', v_org_id, v_pkg_hybrid, 'class_credit', 30, 8, 'all_branches', 'all_classes')
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.package_rule_class_types (organization_id, rule_id, class_type_id)
  VALUES (v_org_id, '66666666-6666-6666-6666-666666666602', v_type_pilates)
  ON CONFLICT DO NOTHING;
END $$;
