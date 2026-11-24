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
