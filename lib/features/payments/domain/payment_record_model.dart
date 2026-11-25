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
  const PaymentRecordModel._();

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
    @JsonKey(name: 'refunded_amount_minor') @Default(0) int refundedAmountMinor,
    @JsonKey(name: 'refund_reason') String? refundReason,
    @JsonKey(name: 'refunded_at') DateTime? refundedAt,
  }) = _PaymentRecordModel;

  factory PaymentRecordModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentRecordModelFromJson(json);

  int get remainingRefundableMinor =>
      (amountMinor - refundedAmountMinor).clamp(0, amountMinor);

  int get netAmountMinor =>
      (amountMinor - refundedAmountMinor).clamp(0, amountMinor);

  bool get isPartiallyRefunded =>
      status == PaymentStatus.paid && refundedAmountMinor > 0;
}

@freezed
abstract class PaymentRefundModel with _$PaymentRefundModel {
  const factory PaymentRefundModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'branch_id') required String branchId,
    @JsonKey(name: 'payment_id') required String paymentId,
    @JsonKey(name: 'member_id') required String memberId,
    @JsonKey(name: 'amount_minor') required int amountMinor,
    @JsonKey(name: 'currency_code') @Default('USD') String currencyCode,
    @JsonKey(name: 'refund_channel')
    @Default('manual_recorded')
    String refundChannel,
    String? reason,
    @JsonKey(name: 'external_reference') String? externalReference,
    @JsonKey(name: 'refunded_by') String? recordedBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _PaymentRefundModel;

  factory PaymentRefundModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentRefundModelFromJson(json);
}

@freezed
abstract class RefundOutcome with _$RefundOutcome {
  const factory RefundOutcome({
    @JsonKey(name: 'refund_id') required String refundId,
    @JsonKey(name: 'payment_id') required String paymentId,
    @JsonKey(name: 'payment_status') required PaymentStatus paymentStatus,
    @JsonKey(name: 'amount_minor') required int amountMinor,
    @JsonKey(name: 'total_refunded_minor') required int totalRefundedMinor,
    @JsonKey(name: 'refund_channel')
    @Default('manual_recorded')
    String refundChannel,
    @JsonKey(name: 'idempotent_replay') @Default(false) bool idempotentReplay,
  }) = _RefundOutcome;

  factory RefundOutcome.fromJson(Map<String, dynamic> json) =>
      _$RefundOutcomeFromJson(json);
}
