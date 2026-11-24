/// Canonical RITMA system roles matching `public.roles` in PostgreSQL.
enum RitmaRole {
  orgOwner('org_owner', 'Organization Owner', 100, true),
  orgAdmin('org_admin', 'Organization Admin', 80, true),
  branchManager('branch_manager', 'Branch Manager', 60, true),
  receptionist('receptionist', 'Receptionist', 40, true),
  gymStaff('gym_staff', 'Gym Staff', 30, true),
  instructor('instructor', 'Fitness Instructor', 30, true),
  personalTrainer('personal_trainer', 'Personal Trainer', 30, true),
  member('member', 'Fitness Member', 10, false);

  const RitmaRole(
    this.code,
    this.displayName,
    this.rank,
    this.isOperationsSurface,
  );

  final String code;
  final String displayName;
  final int rank;
  final bool isOperationsSurface;

  static RitmaRole fromCode(String code) {
    for (final role in RitmaRole.values) {
      if (role.code == code) {
        return role;
      }
    }
    return RitmaRole.member;
  }
}
