import '../../../core/result/result.dart';
import 'package_models.dart';

abstract interface class PackageEntitlementRepository {
  Future<Result<List<ClassTypeModel>>> fetchClassTypes(String orgId);

  Future<Result<ClassTypeModel>> createClassType({
    required String orgId,
    required String name,
    String colorToken = 'sage',
  });

  Future<Result<List<PackageModel>>> fetchPackages(String orgId);

  Future<Result<PackageModel>> createPackage({
    required String orgId,
    required String name,
    required String description,
    required PackageType packageType,
    required int priceMinor,
    required String currencyCode,
    required List<CreatePackageRuleInput> rules,
  });

  Future<Result<MemberWalletSnapshot>> fetchMemberWallet({
    required String orgId,
    required String memberId,
  });

  Future<Result<String>> assignPackageToMember({
    required String orgId,
    required String branchId,
    required String memberId,
    required String packageId,
    required PaymentMethod paymentMethod,
    required String idempotencyKey,
    DateTime? startsAt,
  });

  Future<Result<void>> freezeSubscription({
    required String orgId,
    required String subscriptionId,
    String? reason,
  });

  Future<Result<void>> unfreezeSubscription({
    required String orgId,
    required String subscriptionId,
  });

  Future<Result<void>> adjustMemberCredits({
    required String orgId,
    required String memberId,
    required CreditType creditType,
    required int delta,
    required String reason,
    required String idempotencyKey,
    DateTime? expiresAt,
  });
}
