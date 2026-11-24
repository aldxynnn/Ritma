import 'package:freezed_annotation/freezed_annotation.dart';

import '../../packages/domain/package_models.dart';

part 'payment_record_model.freezed.dart';
part 'payment_record_model.g.dart';

enum PaymentStatus {
  pending,
  paid,
  refunded,
  @JsonValue('void')
  voided;

  String get displayLabel => switch (this) {
    PaymentStatus.pending => 'Pending',
    PaymentStatus.paid => 'Paid',
    PaymentStatus.refunded => 'Refunded',
    PaymentStatus.voided => 'Void',
  };
}

@freezed
abstract class PaymentRecordModel with _$PaymentRecordModel {
  const factory PaymentRecordModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'branch_id') required String branchId,
    @JsonKey(name: 'member_id') required String memberId,
    @JsonKey(name: 'subscription_id') required String subscriptionId,
    @JsonKey(name: 'amount_minor') required int amountMinor,
    @JsonKey(name: 'currency_code') @Default('USD') String currencyCode,
    required PaymentMethod method,
    @Default(PaymentStatus.paid) PaymentStatus status,
    @JsonKey(name: 'external_reference') String? externalReference,
    @JsonKey(name: 'paid_at') required DateTime paidAt,
    @JsonKey(name: 'member_display_name') @Default('') String memberDisplayName,
  }) = _PaymentRecordModel;

  factory PaymentRecordModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentRecordModelFromJson(json);
}
