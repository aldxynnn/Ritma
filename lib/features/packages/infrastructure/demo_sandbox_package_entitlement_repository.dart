import 'package:uuid/uuid.dart';

import '../../../core/demo/demo_sandbox_engine.dart';
import '../../../core/repository/base_repository.dart';
import '../../../core/result/result.dart';
import '../domain/package_entitlement_repository.dart';
import '../domain/package_models.dart';

class DemoSandboxPackageEntitlementRepository extends BaseRepository
    implements PackageEntitlementRepository {
  DemoSandboxPackageEntitlementRepository(this._engine)
    : super(loggerName: 'demo_package_repo');

  final DemoSandboxEngine _engine;
  static const _uuid = Uuid();

  @override
  Future<Result<List<ClassTypeModel>>> fetchClassTypes(String orgId) {
    return guard(() async {
      final list =
          _engine.classTypes.values
              .where((c) => c.organizationId == orgId && c.isActive)
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
      return list;
    }, operation: 'demo.fetchClassTypes');
  }

  @override
  Future<Result<ClassTypeModel>> createClassType({
    required String orgId,
    required String name,
    String colorToken = 'sage',
  }) {
    return guard(() async {
      _engine.requireCurrentUser();
      final created = ClassTypeModel(
        id: _uuid.v4(),
        organizationId: orgId,
        name: name.trim(),
        colorToken: colorToken,
      );
      _engine.classTypes[created.id] = created;
      return created;
    }, operation: 'demo.createClassType');
  }

  @override
  Future<Result<List<PackageModel>>> fetchPackages(String orgId) {
    return guard(() async {
      final list =
          _engine.packages.values
              .where((p) => p.organizationId == orgId && p.isActive)
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
      return list;
    }, operation: 'demo.fetchPackages');
  }

  @override
  Future<Result<PackageModel>> createPackage({
    required String orgId,
    required String name,
    required String description,
    required PackageType packageType,
    required int priceMinor,
    required String currencyCode,
    required List<CreatePackageRuleInput> rules,
  }) {
    return guard(
      () async => _engine.createPackage(
        orgId: orgId,
        name: name,
        description: description,
        packageType: packageType,
        priceMinor: priceMinor,
        currencyCode: currencyCode,
        rules: rules,
      ),
      operation: 'demo.createPackage',
    );
  }

  @override
  Future<Result<MemberWalletSnapshot>> fetchMemberWallet({
    required String orgId,
    required String memberId,
  }) {
    return guard(() async {
      final subs =
          _engine.subscriptions
              .where((s) => s.organizationId == orgId && s.memberId == memberId)
              .toList()
            ..sort((a, b) => b.startsAt.compareTo(a.startsAt));
      final ents =
          _engine.entitlements
              .where((e) => e.organizationId == orgId && e.memberId == memberId)
              .toList()
            ..sort((a, b) => b.validUntil.compareTo(a.validUntil));
      final grants = _engine.creditGrants
          .where((g) => g.organizationId == orgId && g.memberId == memberId)
          .toList();
      final ledger =
          _engine.ledgerEntries
              .where((l) => l.organizationId == orgId && l.memberId == memberId)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return MemberWalletSnapshot(
        subscriptions: subs,
        entitlements: ents,
        creditGrants: grants,
        ledgerEntries: ledger,
      );
    }, operation: 'demo.fetchMemberWallet');
  }

  @override
  Future<Result<String>> assignPackageToMember({
    required String orgId,
    required String branchId,
    required String memberId,
    required String packageId,
    required PaymentMethod paymentMethod,
    required String idempotencyKey,
    DateTime? startsAt,
  }) {
    return guard(
      () async => _engine.assignPackageToMember(
        orgId: orgId,
        branchId: branchId,
        memberId: memberId,
        packageId: packageId,
        paymentMethod: paymentMethod,
        idempotencyKey: idempotencyKey,
        startsAt: startsAt,
      ),
      operation: 'demo.assignPackageToMember',
    );
  }

  @override
  Future<Result<void>> freezeSubscription({
    required String orgId,
    required String subscriptionId,
    String? reason,
  }) {
    return guard(
      () async => _engine.freezeSubscription(
        orgId: orgId,
        subscriptionId: subscriptionId,
      ),
      operation: 'demo.freezeSubscription',
    );
  }

  @override
  Future<Result<void>> unfreezeSubscription({
    required String orgId,
    required String subscriptionId,
  }) {
    return guard(
      () async => _engine.unfreezeSubscription(
        orgId: orgId,
        subscriptionId: subscriptionId,
      ),
      operation: 'demo.unfreezeSubscription',
    );
  }

  @override
  Future<Result<void>> adjustMemberCredits({
    required String orgId,
    required String memberId,
    required CreditType creditType,
    required int delta,
    required String reason,
    required String idempotencyKey,
    DateTime? expiresAt,
  }) {
    return guard(
      () async => _engine.adjustMemberCredits(
        orgId: orgId,
        memberId: memberId,
        creditType: creditType,
        delta: delta,
        reason: reason,
        idempotencyKey: idempotencyKey,
        expiresAt: expiresAt,
      ),
      operation: 'demo.adjustMemberCredits',
    );
  }
}
