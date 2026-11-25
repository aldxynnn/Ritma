// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentRecordModel _$PaymentRecordModelFromJson(Map<String, dynamic> json) =>
    _PaymentRecordModel(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      branchId: json['branch_id'] as String,
      memberId: json['member_id'] as String,
      subscriptionId: json['subscription_id'] as String,
      amountMinor: (json['amount_minor'] as num).toInt(),
      currencyCode: json['currency_code'] as String? ?? 'USD',
      method: $enumDecode(_$PaymentMethodEnumMap, json['method']),
      status:
          $enumDecodeNullable(_$PaymentStatusEnumMap, json['status']) ??
          PaymentStatus.paid,
      externalReference: json['external_reference'] as String?,
      paidAt: DateTime.parse(json['paid_at'] as String),
      memberDisplayName: json['member_display_name'] as String? ?? '',
      refundedAmountMinor:
          (json['refunded_amount_minor'] as num?)?.toInt() ?? 0,
      refundReason: json['refund_reason'] as String?,
      refundedAt: json['refunded_at'] == null
          ? null
          : DateTime.parse(json['refunded_at'] as String),
    );

Map<String, dynamic> _$PaymentRecordModelToJson(_PaymentRecordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'branch_id': instance.branchId,
      'member_id': instance.memberId,
      'subscription_id': instance.subscriptionId,
      'amount_minor': instance.amountMinor,
      'currency_code': instance.currencyCode,
      'method': _$PaymentMethodEnumMap[instance.method]!,
      'status': _$PaymentStatusEnumMap[instance.status]!,
      'external_reference': instance.externalReference,
      'paid_at': instance.paidAt.toIso8601String(),
      'member_display_name': instance.memberDisplayName,
      'refunded_amount_minor': instance.refundedAmountMinor,
      'refund_reason': instance.refundReason,
      'refunded_at': instance.refundedAt?.toIso8601String(),
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.bankTransfer: 'bank_transfer',
  PaymentMethod.cardTerminal: 'card_terminal',
  PaymentMethod.gateway: 'gateway',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.paid: 'paid',
  PaymentStatus.refunded: 'refunded',
  PaymentStatus.voided: 'void',
};

_PaymentRefundModel _$PaymentRefundModelFromJson(Map<String, dynamic> json) =>
    _PaymentRefundModel(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      branchId: json['branch_id'] as String,
      paymentId: json['payment_id'] as String,
      memberId: json['member_id'] as String,
      amountMinor: (json['amount_minor'] as num).toInt(),
      currencyCode: json['currency_code'] as String? ?? 'USD',
      refundChannel: json['refund_channel'] as String? ?? 'manual_recorded',
      reason: json['reason'] as String?,
      externalReference: json['external_reference'] as String?,
      recordedBy: json['refunded_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PaymentRefundModelToJson(_PaymentRefundModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'branch_id': instance.branchId,
      'payment_id': instance.paymentId,
      'member_id': instance.memberId,
      'amount_minor': instance.amountMinor,
      'currency_code': instance.currencyCode,
      'refund_channel': instance.refundChannel,
      'reason': instance.reason,
      'external_reference': instance.externalReference,
      'refunded_by': instance.recordedBy,
      'created_at': instance.createdAt.toIso8601String(),
    };

_RefundOutcome _$RefundOutcomeFromJson(Map<String, dynamic> json) =>
    _RefundOutcome(
      refundId: json['refund_id'] as String,
      paymentId: json['payment_id'] as String,
      paymentStatus: $enumDecode(
        _$PaymentStatusEnumMap,
        json['payment_status'],
      ),
      amountMinor: (json['amount_minor'] as num).toInt(),
      totalRefundedMinor: (json['total_refunded_minor'] as num).toInt(),
      refundChannel: json['refund_channel'] as String? ?? 'manual_recorded',
      idempotentReplay: json['idempotent_replay'] as bool? ?? false,
    );

Map<String, dynamic> _$RefundOutcomeToJson(_RefundOutcome instance) =>
    <String, dynamic>{
      'refund_id': instance.refundId,
      'payment_id': instance.paymentId,
      'payment_status': _$PaymentStatusEnumMap[instance.paymentStatus]!,
      'amount_minor': instance.amountMinor,
      'total_refunded_minor': instance.totalRefundedMinor,
      'refund_channel': instance.refundChannel,
      'idempotent_replay': instance.idempotentReplay,
    };
