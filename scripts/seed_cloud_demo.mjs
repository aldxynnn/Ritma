/**
 * Idempotent, additive live Cloud demo seeder for RITMA.
 *
 * Reads SUPABASE_URL + SUPABASE_ANON_KEY from local git-ignored `env/dev.json`.
 * Never prints API keys or modifies/deletes pre-existing organizations.
 * Seeds a dedicated showcase organization (`RITMA Atelier & Athletic`) via
 * standard Supabase Auth, PostgREST (RLS-enforced), and SECURITY DEFINER RPCs.
 *
 * Usage:
 *   node scripts/seed_cloud_demo.mjs
 */

import fs from 'node:fs';
import path from 'node:path';

const DEMO_PASSWORD = process.env.RITMA_DEMO_PASSWORD || 'RitmaDemo2026!';
const ORG_SLUG = 'ritma-atelier-athletic';
const ORG_NAME = 'RITMA Atelier & Athletic';

function loadEnvConfig() {
  const envPath = path.resolve(process.cwd(), 'env', 'dev.json');
  if (!fs.existsSync(envPath)) {
    throw new Error('Missing env/dev.json. Populate SUPABASE_URL and SUPABASE_ANON_KEY first.');
  }
  const rawText = fs.readFileSync(envPath, 'utf8').replace(/^\uFEFF/, '');
  const raw = JSON.parse(rawText);
  const url = String(raw.SUPABASE_URL || '').replace(/\/+$/, '');
  const anonKey = String(raw.SUPABASE_ANON_KEY || raw.SUPABASE_PUBLISHABLE_KEY || '');
  if (!url || !anonKey) {
    throw new Error('env/dev.json must contain SUPABASE_URL and SUPABASE_ANON_KEY.');
  }
  if (anonKey.startsWith('sb_secret_')) {
    throw new Error('Refusing to use a secret key in client seed script.');
  }
  return { url, anonKey };
}

class CloudSession {
  constructor(baseUrl, anonKey) {
    this.baseUrl = baseUrl;
    this.anonKey = anonKey;
    this.accessToken = null;
    this.userId = null;
    this.email = null;
  }

  headers(extra = {}) {
    const h = {
      apikey: this.anonKey,
      'Content-Type': 'application/json',
      ...extra,
    };
    if (this.accessToken) {
      h.Authorization = `Bearer ${this.accessToken}`;
    }
    return h;
  }

  async ensureAuthenticated(email, fullName) {
    // Try sign-in first so existing demo accounts reuse cleanly.
    const signInRes = await fetch(
      `${this.baseUrl}/auth/v1/token?grant_type=password`,
      {
        method: 'POST',
        headers: this.headers(),
        body: JSON.stringify({ email, password: DEMO_PASSWORD }),
      },
    );
    if (signInRes.ok) {
      const data = await signInRes.json();
      this.accessToken = data.access_token;
      this.userId = data.user.id;
      this.email = email;
      return this.userId;
    }

    const signUpRes = await fetch(`${this.baseUrl}/auth/v1/signup`, {
      method: 'POST',
      headers: this.headers(),
      body: JSON.stringify({
        email,
        password: DEMO_PASSWORD,
        data: { full_name: fullName },
      }),
    });
    const signUpData = await signUpRes.json();
    if (!signUpRes.ok || !signUpData.access_token) {
      throw new Error(
        `Failed to sign up ${email}: HTTP ${signUpRes.status} ${JSON.stringify(signUpData)}`,
      );
    }
    this.accessToken = signUpData.access_token;
    this.userId = signUpData.user.id;
    this.email = email;

    // Ensure profile full_name is populated.
    await this.rest('POST', 'user_profiles', {
      user_id: this.userId,
      full_name: fullName,
    }, {
      Prefer: 'resolution=merge-duplicates,return=representation',
    });

    return this.userId;
  }

  async rest(method, tableWithQuery, body = null, extraHeaders = {}) {
    const res = await fetch(`${this.baseUrl}/rest/v1/${tableWithQuery}`, {
      method,
      headers: this.headers({
        Prefer: 'return=representation',
        ...extraHeaders,
      }),
      body: body != null ? JSON.stringify(body) : undefined,
    });
    const text = await res.text();
    let parsed = null;
    try {
      parsed = text ? JSON.parse(text) : null;
    } catch {
      parsed = text;
    }
    if (!res.ok) {
      throw new Error(
        `REST ${method} ${tableWithQuery} failed (${res.status}): ${JSON.stringify(parsed)}`,
      );
    }
    return parsed;
  }

  async rpc(fnName, params = {}) {
    const res = await fetch(`${this.baseUrl}/rest/v1/rpc/${fnName}`, {
      method: 'POST',
      headers: this.headers(),
      body: JSON.stringify(params),
    });
    const text = await res.text();
    let parsed = null;
    try {
      parsed = text ? JSON.parse(text) : null;
    } catch {
      parsed = text;
    }
    if (!res.ok) {
      throw new Error(
        `RPC ${fnName} failed (${res.status}): ${JSON.stringify(parsed)}`,
      );
    }
    return parsed;
  }
}

async function main() {
  const { url, anonKey } = loadEnvConfig();
  console.log(`Connecting to Supabase Cloud project at ${url}...`);

  const owner = new CloudSession(url, anonKey);
  const ownerUid = await owner.ensureAuthenticated(
    'demo.owner@ritma.app',
    'Nadia Kusuma',
  );
  console.log(`Owner authenticated (${ownerUid})`);

  const manager = new CloudSession(url, anonKey);
  const managerUid = await manager.ensureAuthenticated(
    'demo.manager@ritma.app',
    'Raka Mahendra',
  );

  const memberUser = new CloudSession(url, anonKey);
  const memberUid = await memberUser.ensureAuthenticated(
    'demo.member@ritma.app',
    'Alya Rahma',
  );

  const trainer1User = new CloudSession(url, anonKey);
  const trainer1Uid = await trainer1User.ensureAuthenticated(
    'demo.trainer1@ritma.app',
    'Coach Maya Putri',
  );

  const trainer2User = new CloudSession(url, anonKey);
  const trainer2Uid = await trainer2User.ensureAuthenticated(
    'demo.trainer2@ritma.app',
    'Coach Dimas Pratama',
  );
  console.log('All 5 Cloud demo auth accounts ready.');

  // 1. Ensure showcase Organization & Branches
  let workspaces = await owner.rpc('get_my_workspaces');
  let orgWs = (workspaces || []).find(
    (w) => w.organization_name === ORG_NAME && w.role_code === 'org_owner',
  );

  if (!orgWs) {
    const created = await owner.rpc('create_organization_with_owner', {
      p_name: ORG_NAME,
      p_slug: ORG_SLUG,
      p_business_type: 'hybrid',
      p_timezone: 'Asia/Jakarta',
      p_currency_code: 'USD',
      p_first_branch_name: 'SCBD Flagship Gym',
      p_first_branch_code: 'SCBD',
    });
    console.log(`Created organization ${ORG_NAME} (${created.organization_id})`);
    workspaces = await owner.rpc('get_my_workspaces');
    orgWs = (workspaces || []).find(
      (w) => w.organization_id === created.organization_id && w.role_code === 'org_owner',
    );
  } else {
    console.log(`Reusing existing organization ${ORG_NAME} (${orgWs.organization_id})`);
  }

  const orgId = orgWs.organization_id;

  let branches = await owner.rest(
    'GET',
    `branches?organization_id=eq.${orgId}&order=code.asc`,
  );
  let scbdBranch = branches.find((b) => b.code === 'SCBD');
  let senopatiBranch = branches.find((b) => b.code === 'SNPT');

  if (!senopatiBranch) {
    const [created] = await owner.rest('POST', 'branches', {
      organization_id: orgId,
      name: 'Senopati Boutique Studio',
      code: 'SNPT',
      address: 'Jl. Senopati No. 48, Jakarta Selatan',
      timezone: 'Asia/Jakarta',
    });
    senopatiBranch = created;
  }
  const scbdId = scbdBranch.id;
  const snptId = senopatiBranch.id;

  // Ensure staff invites for Branch Manager & Trainers
  async function ensureStaffRole(targetSession, roleCode, branchId) {
    const ws = await targetSession.rpc('get_my_workspaces');
    const exists = (ws || []).some(
      (w) =>
        w.organization_id === orgId &&
        w.role_code === roleCode &&
        (branchId ? w.branch_id === branchId : w.branch_id == null),
    );
    if (exists) return;
    const inv = await owner.rpc('invite_user_to_organization', {
      p_org_id: orgId,
      p_invited_email: targetSession.email,
      p_role_code: roleCode,
      p_branch_id: branchId,
    });
    await targetSession.rpc('accept_organization_invitation', {
      p_token: inv.token,
    });
  }

  await ensureStaffRole(manager, 'branch_manager', snptId);
  await ensureStaffRole(trainer1User, 'personal_trainer', snptId);
  await ensureStaffRole(trainer2User, 'personal_trainer', scbdId);
  console.log('Staff roles verified across SCBD Flagship Gym & Senopati Boutique Studio.');

  // 2. Rooms (4)
  const desiredRooms = [
    { branch_id: scbdId, name: 'Athletic Conditioning Floor', room_type: 'gym_floor', default_capacity: 24 },
    { branch_id: scbdId, name: 'Cycle & Sweat Box', room_type: 'studio', default_capacity: 18 },
    { branch_id: snptId, name: 'Reformer Pilates Sanctuary', room_type: 'studio', default_capacity: 12 },
    { branch_id: snptId, name: 'Sunlight Yoga Loft', room_type: 'studio', default_capacity: 16 },
  ];
  let existingRooms = await owner.rest('GET', `rooms?organization_id=eq.${orgId}`);
  for (const r of desiredRooms) {
    if (!existingRooms.some((er) => er.branch_id === r.branch_id && er.name === r.name)) {
      const [created] = await owner.rest('POST', 'rooms', {
        organization_id: orgId,
        ...r,
      });
      existingRooms.push(created);
    }
  }
  const roomByName = Object.fromEntries(existingRooms.map((r) => [r.name, r]));

  // 3. Class Types (5)
  const desiredClassTypes = [
    { name: 'Reformer Pilates', color_token: 'lime' },
    { name: 'Vinyasa Yoga', color_token: 'sage' },
    { name: 'HIIT Conditioning', color_token: 'coral' },
    { name: 'Indoor Cycling', color_token: 'lime' },
    { name: 'Strength Lab', color_token: 'graphite' },
  ];
  let existingTypes = await owner.rest('GET', `class_types?organization_id=eq.${orgId}`);
  for (const ct of desiredClassTypes) {
    if (!existingTypes.some((et) => et.name === ct.name)) {
      const [created] = await owner.rest('POST', 'class_types', {
        organization_id: orgId,
        ...ct,
      });
      existingTypes.push(created);
    }
  }
  const typeByName = Object.fromEntries(existingTypes.map((ct) => [ct.name, ct]));

  // 4. Packages & Declarative Entitlement Rules (5)
  const desiredPackages = [
    {
      name: 'Flagship Gym Unlimited',
      description: 'Unlimited 30-day open gym floor entry across all RITMA branches.',
      package_type: 'gym_membership',
      price_minor: 8900,
      rules: [
        { entitlement_kind: 'facility_access', duration_days: 30, branch_access_scope: 'all_branches' },
      ],
    },
    {
      name: 'Boutique 10-Class Pack',
      description: '10 studio class credits valid across Reformer, Yoga, Cycling, and HIIT.',
      package_type: 'class_pack',
      price_minor: 16000,
      rules: [
        { entitlement_kind: 'class_credit', duration_days: 90, credit_quantity: 10, branch_access_scope: 'all_branches' },
      ],
    },
    {
      name: 'RITMA Hybrid All-Access VIP',
      description: '30-day unlimited multi-branch gym entry + 12 studio class credits + 2 PT credits.',
      package_type: 'hybrid',
      price_minor: 21900,
      rules: [
        { entitlement_kind: 'facility_access', duration_days: 30, branch_access_scope: 'all_branches' },
        { entitlement_kind: 'class_credit', duration_days: 60, credit_quantity: 12, branch_access_scope: 'all_branches' },
        { entitlement_kind: 'pt_credit', duration_days: 60, credit_quantity: 2, branch_access_scope: 'all_branches' },
      ],
    },
    {
      name: '5-Session PT Pack',
      description: 'Five 1-on-1 personal training coaching credits.',
      package_type: 'pt_pack',
      price_minor: 32500,
      rules: [
        { entitlement_kind: 'pt_credit', duration_days: 90, credit_quantity: 5, branch_access_scope: 'all_branches' },
      ],
    },
    {
      name: 'Studio Starter 5-Class Pack',
      description: 'Introductory 5-class studio pack valid for 45 days.',
      package_type: 'class_pack',
      price_minor: 9000,
      rules: [
        { entitlement_kind: 'class_credit', duration_days: 45, credit_quantity: 5, branch_access_scope: 'all_branches' },
      ],
    },
  ];
  let existingPackages = await owner.rest(
    'GET',
    `packages?organization_id=eq.${orgId}&select=*,package_entitlement_rules(*)`,
  );
  for (const pkgDef of desiredPackages) {
    if (!existingPackages.some((ep) => ep.name === pkgDef.name)) {
      const [createdPkg] = await owner.rest('POST', 'packages', {
        organization_id: orgId,
        name: pkgDef.name,
        description: pkgDef.description,
        package_type: pkgDef.package_type,
        price_minor: pkgDef.price_minor,
        currency_code: 'USD',
      });
      const rules = [];
      for (const r of pkgDef.rules) {
        const [createdRule] = await owner.rest('POST', 'package_entitlement_rules', {
          organization_id: orgId,
          package_id: createdPkg.id,
          ...r,
        });
        rules.push(createdRule);
      }
      existingPackages.push({ ...createdPkg, package_entitlement_rules: rules });
    }
  }
  const pkgByName = Object.fromEntries(existingPackages.map((p) => [p.name, p]));

  // 5. Members (10) + Claim Passes for demo.owner@ritma.app & demo.member@ritma.app
  const desiredMembers = [
    { member_code: 'RTM-1000', full_name: 'Nadia Kusuma', home_branch_id: scbdId, email: 'demo.owner@ritma.app', phone: '+62-811-9000-1000' },
    { member_code: 'RTM-1001', full_name: 'Alya Rahma', home_branch_id: scbdId, email: 'demo.member@ritma.app', phone: '+62-811-9000-1001' },
    { member_code: 'RTM-1002', full_name: 'Rafael Tanuwijaya', home_branch_id: scbdId, email: 'rafael.demo@ritma.local', phone: '+62-811-9000-1002' },
    { member_code: 'RTM-1003', full_name: 'Siti Wulandari', home_branch_id: snptId, email: 'siti.demo@ritma.local', phone: '+62-811-9000-1003' },
    { member_code: 'RTM-1004', full_name: 'Kevin Wijaya', home_branch_id: scbdId, email: 'kevin.demo@ritma.local', phone: '+62-811-9000-1004' },
    { member_code: 'RTM-1005', full_name: 'Clarissa Halim', home_branch_id: snptId, email: 'clarissa.demo@ritma.local', phone: '+62-811-9000-1005' },
    { member_code: 'RTM-1006', full_name: 'Bima Santoso', home_branch_id: scbdId, email: 'bima.demo@ritma.local', phone: '+62-811-9000-1006' },
    { member_code: 'RTM-1007', full_name: 'Tania Iskandar', home_branch_id: snptId, email: 'tania.demo@ritma.local', phone: '+62-811-9000-1007' },
    { member_code: 'RTM-1008', full_name: 'Farhan Aziz', home_branch_id: scbdId, email: 'farhan.demo@ritma.local', phone: '+62-811-9000-1008' },
    { member_code: 'RTM-1009', full_name: 'Mila Kartika', home_branch_id: snptId, email: 'mila.demo@ritma.local', phone: '+62-811-9000-1009' },
  ];
  let existingMembers = await owner.rest('GET', `members?organization_id=eq.${orgId}`);
  for (const m of desiredMembers) {
    if (!existingMembers.some((em) => em.member_code === m.member_code)) {
      const [created] = await owner.rest('POST', 'members', {
        organization_id: orgId,
        ...m,
      });
      existingMembers.push(created);
    }
  }
  const memberByCode = Object.fromEntries(existingMembers.map((m) => [m.member_code, m]));

  async function ensureMemberClaim(targetSession, memberObj) {
    if (memberObj.user_id === targetSession.userId) return;
    if (memberObj.user_id && memberObj.user_id !== targetSession.userId) return;
    const claimInv = await owner.rpc('invite_member_claim', {
      p_org_id: orgId,
      p_member_id: memberObj.id,
      p_email: targetSession.email,
    });
    await targetSession.rpc('claim_member_profile', { p_token: claimInv.token });
  }

  await ensureMemberClaim(owner, memberByCode['RTM-1000']);
  await ensureMemberClaim(memberUser, memberByCode['RTM-1001']);
  console.log('10 members registered & member passes claimed.');

  // 6. Idempotent Package Assignments & Payments + 1 Frozen Member
  const packageAssignments = [
    { key: 'seed-sub-rtm1000-vip', code: 'RTM-1000', pkg: 'RITMA Hybrid All-Access VIP', method: 'card_terminal' },
    { key: 'seed-sub-rtm1001-vip', code: 'RTM-1001', pkg: 'RITMA Hybrid All-Access VIP', method: 'card_terminal' },
    { key: 'seed-sub-rtm1001-pt', code: 'RTM-1001', pkg: '5-Session PT Pack', method: 'bank_transfer' },
    { key: 'seed-sub-rtm1002-gym', code: 'RTM-1002', pkg: 'Flagship Gym Unlimited', method: 'card_terminal' },
    { key: 'seed-sub-rtm1003-cls', code: 'RTM-1003', pkg: 'Boutique 10-Class Pack', method: 'bank_transfer' },
    { key: 'seed-sub-rtm1004-vip', code: 'RTM-1004', pkg: 'RITMA Hybrid All-Access VIP', method: 'cash' },
    { key: 'seed-sub-rtm1005-cls', code: 'RTM-1005', pkg: 'Boutique 10-Class Pack', method: 'card_terminal' },
    { key: 'seed-sub-rtm1006-gym', code: 'RTM-1006', pkg: 'Flagship Gym Unlimited', method: 'bank_transfer' },
    { key: 'seed-sub-rtm1007-pt', code: 'RTM-1007', pkg: '5-Session PT Pack', method: 'card_terminal' },
    { key: 'seed-sub-rtm1008-str', code: 'RTM-1008', pkg: 'Studio Starter 5-Class Pack', method: 'cash' },
    { key: 'seed-sub-rtm1009-cls', code: 'RTM-1009', pkg: 'Boutique 10-Class Pack', method: 'bank_transfer' },
  ];
  for (const a of packageAssignments) {
    const m = memberByCode[a.code];
    const p = pkgByName[a.pkg];
    await owner.rpc('assign_package_to_member', {
      p_org_id: orgId,
      p_branch_id: m.home_branch_id,
      p_member_id: m.id,
      p_package_id: p.id,
      p_starts_at: new Date().toISOString(),
      p_payment_method: a.method,
      p_idempotency_key: a.key,
    });
  }

  // Freeze RTM-1006 (`Bima Santoso`) subscription + status if still active
  const bima = memberByCode['RTM-1006'];
  if (bima.status === 'active') {
    const bimaSubs = await owner.rest(
      'GET',
      `member_subscriptions?organization_id=eq.${orgId}&member_id=eq.${bima.id}&status=eq.active`,
    );
    if (bimaSubs.length > 0) {
      await owner.rpc('freeze_member_subscription', {
        p_org_id: orgId,
        p_subscription_id: bimaSubs[0].id,
        p_reason: 'Out-of-town travel hold',
      });
    }
    await owner.rpc('set_member_status', {
      p_org_id: orgId,
      p_member_id: bima.id,
      p_status: 'frozen',
      p_reason: 'Travel hold demo state',
    });
  }
  console.log('Package assignments, separated entitlements, payments ledger, and frozen member ready.');

  // 7. Live Check-Ins Today (QR + Manual, leaving 3 active on floor & 2 checked out)
  const existingVisits = await owner.rest('GET', `facility_visits?organization_id=eq.${orgId}`);
  if (existingVisits.length === 0) {
    const alyaQr = await memberUser.rpc('issue_member_qr_token', {
      p_org_id: orgId,
      p_member_id: memberByCode['RTM-1001'].id,
    });
    const alyaCheckin = await owner.rpc('validate_and_check_in', {
      p_org_id: orgId,
      p_branch_id: scbdId,
      p_qr_token: alyaQr.token,
      p_idempotency_key: 'seed-visit-alya-qr-1',
    });
    const nadiaQr = await owner.rpc('issue_member_qr_token', {
      p_org_id: orgId,
      p_member_id: memberByCode['RTM-1000'].id,
    });
    await owner.rpc('validate_and_check_in', {
      p_org_id: orgId,
      p_branch_id: snptId,
      p_qr_token: nadiaQr.token,
      p_idempotency_key: 'seed-visit-nadia-qr-1',
    });
    const rafaelCheckin = await owner.rpc('manual_facility_check_in', {
      p_org_id: orgId,
      p_branch_id: scbdId,
      p_member_id: memberByCode['RTM-1002'].id,
      p_force_override: false,
      p_idempotency_key: 'seed-visit-rafael-1',
    });
    await owner.rpc('manual_facility_check_in', {
      p_org_id: orgId,
      p_branch_id: scbdId,
      p_member_id: memberByCode['RTM-1004'].id,
      p_force_override: false,
      p_idempotency_key: 'seed-visit-kevin-1',
    });
    await owner.rpc('manual_facility_check_in', {
      p_org_id: orgId,
      p_branch_id: snptId,
      p_member_id: memberByCode['RTM-1005'].id,
      p_force_override: false,
      p_idempotency_key: 'seed-visit-clarissa-1',
    });
    if (rafaelCheckin?.visit_id) {
      await owner.rpc('check_out_facility_visit', {
        p_org_id: orgId,
        p_visit_id: rafaelCheckin.visit_id,
      });
    }
    if (alyaCheckin?.visit_id) {
      // Keep Alya checked in on floor!
    }
  }
  console.log('Facility check-ins populated.');

  // 8. Scheduled Classes (8 upcoming) + Confirmed Bookings + Full Waitlisted Session
  const baseUtc = Date.now();
  function isoPlus(hours, minutes = 0) {
    return new Date(baseUtc + hours * 3600 * 1000 + minutes * 60 * 1000).toISOString();
  }

  const desiredSessions = [
    {
      title: 'Core & Mobility Restore',
      branch_id: snptId,
      room_id: roomByName['Reformer Pilates Sanctuary'].id,
      class_type_id: typeByName['Reformer Pilates'].id,
      instructor_display_name: 'Maya Putri',
      instructor_user_id: trainer1Uid,
      startH: 18,
      durMin: 60,
      capacity: 2,
      credit_cost: 1,
      waitlist_enabled: true,
    },
    {
      title: 'Sunrise Vinyasa Flow',
      branch_id: snptId,
      room_id: roomByName['Sunlight Yoga Loft'].id,
      class_type_id: typeByName['Vinyasa Yoga'].id,
      instructor_display_name: 'Maya Putri',
      instructor_user_id: trainer1Uid,
      startH: 20,
      durMin: 60,
      capacity: 14,
      credit_cost: 1,
      waitlist_enabled: true,
    },
    {
      title: 'Reformer Sculpt Precision',
      branch_id: snptId,
      room_id: roomByName['Reformer Pilates Sanctuary'].id,
      class_type_id: typeByName['Reformer Pilates'].id,
      instructor_display_name: 'Sora Lestari',
      instructor_user_id: null,
      startH: 24,
      durMin: 60,
      capacity: 12,
      credit_cost: 1,
      waitlist_enabled: true,
    },
    {
      title: 'Athletic Engine HIIT 45',
      branch_id: scbdId,
      room_id: roomByName['Athletic Conditioning Floor'].id,
      class_type_id: typeByName['HIIT Conditioning'].id,
      instructor_display_name: 'Dimas Pratama',
      instructor_user_id: trainer2Uid,
      startH: 27,
      durMin: 45,
      capacity: 20,
      credit_cost: 1,
      waitlist_enabled: true,
    },
    {
      title: 'Metabolic Spin Rhythm',
      branch_id: scbdId,
      room_id: roomByName['Cycle & Sweat Box'].id,
      class_type_id: typeByName['Indoor Cycling'].id,
      instructor_display_name: 'Andra Wijaya',
      instructor_user_id: null,
      startH: 30,
      durMin: 45,
      capacity: 18,
      credit_cost: 1,
      waitlist_enabled: true,
    },
    {
      title: 'Barbell Strength Lab',
      branch_id: scbdId,
      room_id: roomByName['Athletic Conditioning Floor'].id,
      class_type_id: typeByName['Strength Lab'].id,
      instructor_display_name: 'Dimas Pratama',
      instructor_user_id: trainer2Uid,
      startH: 44,
      durMin: 75,
      capacity: 16,
      credit_cost: 2,
      waitlist_enabled: true,
    },
    {
      title: 'Candlelight Yin Recovery',
      branch_id: snptId,
      room_id: roomByName['Sunlight Yoga Loft'].id,
      class_type_id: typeByName['Vinyasa Yoga'].id,
      instructor_display_name: 'Maya Putri',
      instructor_user_id: trainer1Uid,
      startH: 49,
      durMin: 60,
      capacity: 16,
      credit_cost: 1,
      waitlist_enabled: true,
    },
    {
      title: 'Saturday Endurance Sweat',
      branch_id: scbdId,
      room_id: roomByName['Cycle & Sweat Box'].id,
      class_type_id: typeByName['Indoor Cycling'].id,
      instructor_display_name: 'Andra Wijaya',
      instructor_user_id: null,
      startH: 72,
      durMin: 60,
      capacity: 18,
      credit_cost: 1,
      waitlist_enabled: true,
    },
  ];

  let existingSessions = await owner.rest('GET', `class_sessions?organization_id=eq.${orgId}`);
  for (const s of desiredSessions) {
    if (!existingSessions.some((es) => es.title === s.title && es.status !== 'cancelled')) {
      const startsAt = isoPlus(s.startH);
      const endsAt = isoPlus(s.startH, s.durMin);
      const cutoff = isoPlus(Math.max(1, s.startH - 2));
      const [created] = await owner.rest('POST', 'class_sessions', {
        organization_id: orgId,
        branch_id: s.branch_id,
        room_id: s.room_id,
        class_type_id: s.class_type_id,
        instructor_user_id: s.instructor_user_id,
        instructor_display_name: s.instructor_display_name,
        title: s.title,
        starts_at: startsAt,
        ends_at: endsAt,
        capacity: s.capacity,
        credit_cost: s.credit_cost,
        cancellation_cutoff_at: cutoff,
        waitlist_enabled: s.waitlist_enabled,
      });
      existingSessions.push(created);
    }
  }
  const sessionByTitle = Object.fromEntries(existingSessions.map((s) => [s.title, s]));

  const bookingPlan = [
    // Fill Core & Mobility Restore (capacity 2) -> Siti + Clarissa confirmed, Alya waitlisted #1!
    { key: 'seed-bk-core-siti', session: 'Core & Mobility Restore', code: 'RTM-1003' },
    { key: 'seed-bk-core-clarissa', session: 'Core & Mobility Restore', code: 'RTM-1005' },
    { key: 'seed-bk-core-alya-wl', session: 'Core & Mobility Restore', code: 'RTM-1001' },
    // Alya confirmed bookings across Sunrise Yoga & Athletic HIIT
    { key: 'seed-bk-yoga-alya', session: 'Sunrise Vinyasa Flow', code: 'RTM-1001' },
    { key: 'seed-bk-hiit-alya', session: 'Athletic Engine HIIT 45', code: 'RTM-1001' },
    // Nadia & other members
    { key: 'seed-bk-yoga-nadia', session: 'Sunrise Vinyasa Flow', code: 'RTM-1000' },
    { key: 'seed-bk-reformer-siti', session: 'Reformer Sculpt Precision', code: 'RTM-1003' },
    { key: 'seed-bk-reformer-mila', session: 'Reformer Sculpt Precision', code: 'RTM-1009' },
    { key: 'seed-bk-hiit-kevin', session: 'Athletic Engine HIIT 45', code: 'RTM-1004' },
    { key: 'seed-bk-spin-farhan', session: 'Metabolic Spin Rhythm', code: 'RTM-1008' },
    { key: 'seed-bk-strength-kevin', session: 'Barbell Strength Lab', code: 'RTM-1004' },
  ];
  for (const b of bookingPlan) {
    await owner.rpc('book_class_session', {
      p_org_id: orgId,
      p_session_id: sessionByTitle[b.session].id,
      p_member_id: memberByCode[b.code].id,
      p_idempotency_key: b.key,
    });
  }
  console.log('8 class sessions & confirmed/waitlisted bookings populated.');

  // 9. Personal Training Profiles, Availabilities & Sessions
  const desiredTrainers = [
    {
      user_id: trainer1Uid,
      home_branch_id: snptId,
      display_name: 'Coach Maya Putri',
      bio: 'STOTT Reformer Pilates specialist & post-rehab mobility coach.',
      specialties: ['Reformer Pilates', 'Mobility', 'Core Control'],
      default_credit_cost: 1,
    },
    {
      user_id: trainer2Uid,
      home_branch_id: scbdId,
      display_name: 'Coach Dimas Pratama',
      bio: 'CSCS strength & metabolic conditioning specialist for athletic performance.',
      specialties: ['Barbell Strength', 'Hyrox Conditioning', 'VO2 Max'],
      default_credit_cost: 1,
    },
  ];
  let existingTrainers = await owner.rest('GET', `trainer_profiles?organization_id=eq.${orgId}`);
  for (const tp of desiredTrainers) {
    if (!existingTrainers.some((et) => et.user_id === tp.user_id)) {
      const [created] = await owner.rest('POST', 'trainer_profiles', {
        organization_id: orgId,
        ...tp,
      });
      existingTrainers.push(created);
    } else {
      const existing = existingTrainers.find((et) => et.user_id === tp.user_id);
      if (!existing.display_name) {
        await owner.rest('PATCH', `trainer_profiles?id=eq.${existing.id}`, {
          display_name: tp.display_name,
        });
        existing.display_name = tp.display_name;
      }
    }
  }
  const trainerMaya = existingTrainers.find((t) => t.user_id === trainer1Uid);
  const trainerDimas = existingTrainers.find((t) => t.user_id === trainer2Uid);

  // Add full 7-day availability windows (07:00 - 21:00) so interactive PT booking works any day
  for (const tp of [trainerMaya, trainerDimas]) {
    const existingAvail = await owner.rest(
      'GET',
      `trainer_availabilities?organization_id=eq.${orgId}&trainer_id=eq.${tp.id}`,
    );
    const existingDays = new Set(existingAvail.map((a) => a.weekday));
    for (let weekday = 0; weekday <= 6; weekday += 1) {
      if (!existingDays.has(weekday)) {
        await owner.rest('POST', 'trainer_availabilities', {
          organization_id: orgId,
          branch_id: tp.home_branch_id,
          trainer_id: tp.id,
          weekday,
          start_time: '07:00:00',
          end_time: '21:00:00',
        });
      }
    }
  }

  // Build tomorrow 10:00 & 14:00 WIB (Asia/Jakarta UTC+7 -> minus 7 hours for UTC)
  const tomorrow = new Date(Date.now() + 24 * 3600 * 1000);
  const wibYear = tomorrow.getUTCFullYear();
  const wibMonth = tomorrow.getUTCMonth();
  const wibDay = tomorrow.getUTCDate();
  const ptSlot1Start = new Date(Date.UTC(wibYear, wibMonth, wibDay, 10 - 7, 0, 0));
  const ptSlot1End = new Date(ptSlot1Start.getTime() + 60 * 60 * 1000);
  const ptSlot2Start = new Date(Date.UTC(wibYear, wibMonth, wibDay, 14 - 7, 0, 0));
  const ptSlot2End = new Date(ptSlot2Start.getTime() + 60 * 60 * 1000);

  const pt1 = await owner.rpc('book_pt_session', {
    p_org_id: orgId,
    p_branch_id: snptId,
    p_trainer_id: trainerMaya.id,
    p_member_id: memberByCode['RTM-1007'].id,
    p_starts_at: ptSlot1Start.toISOString(),
    p_ends_at: ptSlot1End.toISOString(),
    p_credit_cost: 1,
    p_idempotency_key: 'seed-pt-session-maya-tania-1',
  });
  await owner.rpc('book_pt_session', {
    p_org_id: orgId,
    p_branch_id: scbdId,
    p_trainer_id: trainerDimas.id,
    p_member_id: memberByCode['RTM-1001'].id,
    p_starts_at: ptSlot2Start.toISOString(),
    p_ends_at: ptSlot2End.toISOString(),
    p_credit_cost: 1,
    p_idempotency_key: 'seed-pt-session-dimas-alya-1',
  });

  if (pt1?.pt_session_id && pt1.status === 'scheduled') {
    await owner.rpc('complete_pt_session', {
      p_org_id: orgId,
      p_pt_session_id: pt1.pt_session_id,
      p_notes: 'Completed thoracic mobility progression; ready for green spring upgrade.',
    });
  }
  console.log('Personal Training trainers, availabilities, and sessions ready.');

  // 10. Equipment Assets & Maintenance Tickets
  const desiredAssets = [
    { branch_id: snptId, asset_code: 'REF-01', name: 'Merrithew SPX Max Reformer #1', category: 'Pilates Reformer', status: 'needs_service' },
    { branch_id: snptId, asset_code: 'REF-02', name: 'Merrithew SPX Max Reformer #2', category: 'Pilates Reformer', status: 'operational' },
    { branch_id: scbdId, asset_code: 'SKR-01', name: 'Technogym Skillrun Unity #1', category: 'Cardio', status: 'needs_service' },
    { branch_id: scbdId, asset_code: 'SKR-02', name: 'Technogym Skillrun Unity #2', category: 'Cardio', status: 'operational' },
    { branch_id: scbdId, asset_code: 'CYC-01', name: 'Stages SC3 Indoor Bike #1', category: 'Cycling', status: 'operational' },
    { branch_id: scbdId, asset_code: 'RAC-01', name: 'Eleiko IPF Power Rack #1', category: 'Strength', status: 'operational' },
  ];
  let existingAssets = await owner.rest('GET', `equipment_assets?organization_id=eq.${orgId}`);
  for (const a of desiredAssets) {
    if (!existingAssets.some((ea) => ea.asset_code === a.asset_code)) {
      const [created] = await owner.rest('POST', 'equipment_assets', {
        organization_id: orgId,
        ...a,
      });
      existingAssets.push(created);
    }
  }
  const assetByCode = Object.fromEntries(existingAssets.map((a) => [a.asset_code, a]));

  const desiredTickets = [
    {
      asset_code: 'REF-01',
      branch_id: snptId,
      summary: 'Replace heavy blue spring carriage tension cable on Reformer #1',
      priority: 'high',
      status: 'open',
    },
    {
      asset_code: 'SKR-01',
      branch_id: scbdId,
      summary: 'Calibrate incline belt tension & sensor firmware on Skillrun #1',
      priority: 'normal',
      status: 'in_progress',
    },
  ];
  let existingTickets = await owner.rest('GET', `equipment_maintenance_tickets?organization_id=eq.${orgId}`);
  for (const t of desiredTickets) {
    if (!existingTickets.some((et) => et.summary === t.summary)) {
      const asset = assetByCode[t.asset_code];
      await owner.rest('POST', 'equipment_maintenance_tickets', {
        organization_id: orgId,
        branch_id: t.branch_id,
        asset_id: asset.id,
        summary: t.summary,
        priority: t.priority,
        status: t.status,
        reported_by: owner.userId,
      });
    }
  }

  // Print sanitized final Cloud metrics verification
  const kpis = await owner.rpc('get_operational_dashboard_metrics', {
    p_org_id: orgId,
    p_window_days: 30,
  });
  console.log('\n=== Cloud Showcase Seed Complete ===');
  console.log(`Organization: ${ORG_NAME} (${orgId})`);
  console.log(`Branches: SCBD (${scbdId}), SNPT (${snptId})`);
  console.log('KPIs (30d):', JSON.stringify(kpis));
  console.log('Demo accounts: demo.owner@ritma.app, demo.manager@ritma.app, demo.member@ritma.app, demo.trainer1@ritma.app, demo.trainer2@ritma.app');
}

main().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
