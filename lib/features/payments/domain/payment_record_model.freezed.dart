// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_record_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentRecordModel {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'branch_id') String get branchId;@JsonKey(name: 'member_id') String get memberId;@JsonKey(name: 'subscription_id') String get subscriptionId;@JsonKey(name: 'amount_minor') int get amountMinor;@JsonKey(name: 'currency_code') String get currencyCode; PaymentMethod get method; PaymentStatus get status;@JsonKey(name: 'external_reference') String? get externalReference;@JsonKey(name: 'paid_at') DateTime get paidAt;@JsonKey(name: 'member_display_name') String get memberDisplayName;@JsonKey(name: 'refunded_amount_minor') int get refundedAmountMinor;@JsonKey(name: 'refund_reason') String? get refundReason;@JsonKey(name: 'refunded_at') DateTime? get refundedAt;
/// Create a copy of PaymentRecordModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentRecordModelCopyWith<PaymentRecordModel> get copyWith => _$PaymentRecordModelCopyWithImpl<PaymentRecordModel>(this as PaymentRecordModel, _$identity);

  /// Serializes this PaymentRecordModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PaymentRecordModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentRecordModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId)&&(identical(other.memberId, _this.memberId) || other.memberId == _this.memberId)&&(identical(other.subscriptionId, _this.subscriptionId) || other.subscriptionId == _this.subscriptionId)&&(identical(other.amountMinor, _this.amountMinor) || other.amountMinor == _this.amountMinor)&&(identical(other.currencyCode, _this.currencyCode) || other.currencyCode == _this.currencyCode)&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.externalReference, _this.externalReference) || other.externalReference == _this.externalReference)&&(identical(other.paidAt, _this.paidAt) || other.paidAt == _this.paidAt)&&(identical(other.memberDisplayName, _this.memberDisplayName) || other.memberDisplayName == _this.memberDisplayName)&&(identical(other.refundedAmountMinor, _this.refundedAmountMinor) || other.refundedAmountMinor == _this.refundedAmountMinor)&&(identical(other.refundReason, _this.refundReason) || other.refundReason == _this.refundReason)&&(identical(other.refundedAt, _this.refundedAt) || other.refundedAt == _this.refundedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PaymentRecordModel;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.branchId,_this.memberId,_this.subscriptionId,_this.amountMinor,_this.currencyCode,_this.method,_this.status,_this.externalReference,_this.paidAt,_this.memberDisplayName,_this.refundedAmountMinor,_this.refundReason,_this.refundedAt);
}

@override
String toString() {
  final _this = this as PaymentRecordModel;
  return 'PaymentRecordModel(id: ${_this.id}, organizationId: ${_this.organizationId}, branchId: ${_this.branchId}, memberId: ${_this.memberId}, subscriptionId: ${_this.subscriptionId}, amountMinor: ${_this.amountMinor}, currencyCode: ${_this.currencyCode}, method: ${_this.method}, status: ${_this.status}, externalReference: ${_this.externalReference}, paidAt: ${_this.paidAt}, memberDisplayName: ${_this.memberDisplayName}, refundedAmountMinor: ${_this.refundedAmountMinor}, refundReason: ${_this.refundReason}, refundedAt: ${_this.refundedAt})';
}


}

/// @nodoc
abstract mixin class $PaymentRecordModelCopyWith<$Res>  {
  factory $PaymentRecordModelCopyWith(PaymentRecordModel value, $Res Function(PaymentRecordModel) _then) = _$PaymentRecordModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'branch_id') String branchId,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'subscription_id') String subscriptionId,@JsonKey(name: 'amount_minor') int amountMinor,@JsonKey(name: 'currency_code') String currencyCode, PaymentMethod method, PaymentStatus status,@JsonKey(name: 'external_reference') String? externalReference,@JsonKey(name: 'paid_at') DateTime paidAt,@JsonKey(name: 'member_display_name') String memberDisplayName,@JsonKey(name: 'refunded_amount_minor') int refundedAmountMinor,@JsonKey(name: 'refund_reason') String? refundReason,@JsonKey(name: 'refunded_at') DateTime? refundedAt
});




}
/// @nodoc
class _$PaymentRecordModelCopyWithImpl<$Res>
    implements $PaymentRecordModelCopyWith<$Res> {
  _$PaymentRecordModelCopyWithImpl(this._self, this._then);

  final PaymentRecordModel _self;
  final $Res Function(PaymentRecordModel) _then;

/// Create a copy of PaymentRecordModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? branchId = null,Object? memberId = null,Object? subscriptionId = null,Object? amountMinor = null,Object? currencyCode = null,Object? method = null,Object? status = null,Object? externalReference = freezed,Object? paidAt = null,Object? memberDisplayName = null,Object? refundedAmountMinor = null,Object? refundReason = freezed,Object? refundedAt = freezed,}) {
  return _then(PaymentRecordModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: null == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentStatus,externalReference: freezed == externalReference ? _self.externalReference : externalReference // ignore: cast_nullable_to_non_nullable
as String?,paidAt: null == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime,memberDisplayName: null == memberDisplayName ? _self.memberDisplayName : memberDisplayName // ignore: cast_nullable_to_non_nullable
as String,refundedAmountMinor: null == refundedAmountMinor ? _self.refundedAmountMinor : refundedAmountMinor // ignore: cast_nullable_to_non_nullable
as int,refundReason: freezed == refundReason ? _self.refundReason : refundReason // ignore: cast_nullable_to_non_nullable
as String?,refundedAt: freezed == refundedAt ? _self.refundedAt : refundedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentRecordModel].
extension PaymentRecordModelPatterns on PaymentRecordModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentRecordModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentRecordModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentRecordModel value)  $default,){
final _that = this;
switch (_that) {
case _PaymentRecordModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentRecordModel value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentRecordModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'subscription_id')  String subscriptionId, @JsonKey(name: 'amount_minor')  int amountMinor, @JsonKey(name: 'currency_code')  String currencyCode,  PaymentMethod method,  PaymentStatus status, @JsonKey(name: 'external_reference')  String? externalReference, @JsonKey(name: 'paid_at')  DateTime paidAt, @JsonKey(name: 'member_display_name')  String memberDisplayName, @JsonKey(name: 'refunded_amount_minor')  int refundedAmountMinor, @JsonKey(name: 'refund_reason')  String? refundReason, @JsonKey(name: 'refunded_at')  DateTime? refundedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentRecordModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.branchId,_that.memberId,_that.subscriptionId,_that.amountMinor,_that.currencyCode,_that.method,_that.status,_that.externalReference,_that.paidAt,_that.memberDisplayName,_that.refundedAmountMinor,_that.refundReason,_that.refundedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'subscription_id')  String subscriptionId, @JsonKey(name: 'amount_minor')  int amountMinor, @JsonKey(name: 'currency_code')  String currencyCode,  PaymentMethod method,  PaymentStatus status, @JsonKey(name: 'external_reference')  String? externalReference, @JsonKey(name: 'paid_at')  DateTime paidAt, @JsonKey(name: 'member_display_name')  String memberDisplayName, @JsonKey(name: 'refunded_amount_minor')  int refundedAmountMinor, @JsonKey(name: 'refund_reason')  String? refundReason, @JsonKey(name: 'refunded_at')  DateTime? refundedAt)  $default,) {final _that = this;
switch (_that) {
case _PaymentRecordModel():
return $default(_that.id,_that.organizationId,_that.branchId,_that.memberId,_that.subscriptionId,_that.amountMinor,_that.currencyCode,_that.method,_that.status,_that.externalReference,_that.paidAt,_that.memberDisplayName,_that.refundedAmountMinor,_that.refundReason,_that.refundedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'subscription_id')  String subscriptionId, @JsonKey(name: 'amount_minor')  int amountMinor, @JsonKey(name: 'currency_code')  String currencyCode,  PaymentMethod method,  PaymentStatus status, @JsonKey(name: 'external_reference')  String? externalReference, @JsonKey(name: 'paid_at')  DateTime paidAt, @JsonKey(name: 'member_display_name')  String memberDisplayName, @JsonKey(name: 'refunded_amount_minor')  int refundedAmountMinor, @JsonKey(name: 'refund_reason')  String? refundReason, @JsonKey(name: 'refunded_at')  DateTime? refundedAt)?  $default,) {final _that = this;
switch (_that) {
case _PaymentRecordModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.branchId,_that.memberId,_that.subscriptionId,_that.amountMinor,_that.currencyCode,_that.method,_that.status,_that.externalReference,_that.paidAt,_that.memberDisplayName,_that.refundedAmountMinor,_that.refundReason,_that.refundedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentRecordModel extends PaymentRecordModel {
  const _PaymentRecordModel({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'branch_id') required this.branchId, @JsonKey(name: 'member_id') required this.memberId, @JsonKey(name: 'subscription_id') required this.subscriptionId, @JsonKey(name: 'amount_minor') required this.amountMinor, @JsonKey(name: 'currency_code') this.currencyCode = 'USD', required this.method, this.status = PaymentStatus.paid, @JsonKey(name: 'external_reference') this.externalReference, @JsonKey(name: 'paid_at') required this.paidAt, @JsonKey(name: 'member_display_name') this.memberDisplayName = '', @JsonKey(name: 'refunded_amount_minor') this.refundedAmountMinor = 0, @JsonKey(name: 'refund_reason') this.refundReason, @JsonKey(name: 'refunded_at') this.refundedAt}): super._();
  factory _PaymentRecordModel.fromJson(Map<String, dynamic> json) => _$PaymentRecordModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'branch_id') final  String branchId;
@override@JsonKey(name: 'member_id') final  String memberId;
@override@JsonKey(name: 'subscription_id') final  String subscriptionId;
@override@JsonKey(name: 'amount_minor') final  int amountMinor;
@override@JsonKey(name: 'currency_code') final  String currencyCode;
@override final  PaymentMethod method;
@override@JsonKey() final  PaymentStatus status;
@override@JsonKey(name: 'external_reference') final  String? externalReference;
@override@JsonKey(name: 'paid_at') final  DateTime paidAt;
@override@JsonKey(name: 'member_display_name') final  String memberDisplayName;
@override@JsonKey(name: 'refunded_amount_minor') final  int refundedAmountMinor;
@override@JsonKey(name: 'refund_reason') final  String? refundReason;
@override@JsonKey(name: 'refunded_at') final  DateTime? refundedAt;

/// Create a copy of PaymentRecordModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentRecordModelCopyWith<_PaymentRecordModel> get copyWith => __$PaymentRecordModelCopyWithImpl<_PaymentRecordModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentRecordModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentRecordModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.method, method) || other.method == method)&&(identical(other.status, status) || other.status == status)&&(identical(other.externalReference, externalReference) || other.externalReference == externalReference)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.memberDisplayName, memberDisplayName) || other.memberDisplayName == memberDisplayName)&&(identical(other.refundedAmountMinor, refundedAmountMinor) || other.refundedAmountMinor == refundedAmountMinor)&&(identical(other.refundReason, refundReason) || other.refundReason == refundReason)&&(identical(other.refundedAt, refundedAt) || other.refundedAt == refundedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,branchId,memberId,subscriptionId,amountMinor,currencyCode,method,status,externalReference,paidAt,memberDisplayName,refundedAmountMinor,refundReason,refundedAt);
}

@override
String toString() {
    return 'PaymentRecordModel(id: $id, organizationId: $organizationId, branchId: $branchId, memberId: $memberId, subscriptionId: $subscriptionId, amountMinor: $amountMinor, currencyCode: $currencyCode, method: $method, status: $status, externalReference: $externalReference, paidAt: $paidAt, memberDisplayName: $memberDisplayName, refundedAmountMinor: $refundedAmountMinor, refundReason: $refundReason, refundedAt: $refundedAt)';
}


}

/// @nodoc
abstract mixin class _$PaymentRecordModelCopyWith<$Res> implements $PaymentRecordModelCopyWith<$Res> {
  factory _$PaymentRecordModelCopyWith(_PaymentRecordModel value, $Res Function(_PaymentRecordModel) _then) = __$PaymentRecordModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'branch_id') String branchId,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'subscription_id') String subscriptionId,@JsonKey(name: 'amount_minor') int amountMinor,@JsonKey(name: 'currency_code') String currencyCode, PaymentMethod method, PaymentStatus status,@JsonKey(name: 'external_reference') String? externalReference,@JsonKey(name: 'paid_at') DateTime paidAt,@JsonKey(name: 'member_display_name') String memberDisplayName,@JsonKey(name: 'refunded_amount_minor') int refundedAmountMinor,@JsonKey(name: 'refund_reason') String? refundReason,@JsonKey(name: 'refunded_at') DateTime? refundedAt
});




}
/// @nodoc
class __$PaymentRecordModelCopyWithImpl<$Res>
    implements _$PaymentRecordModelCopyWith<$Res> {
  __$PaymentRecordModelCopyWithImpl(this._self, this._then);

  final _PaymentRecordModel _self;
  final $Res Function(_PaymentRecordModel) _then;

/// Create a copy of PaymentRecordModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? branchId = null,Object? memberId = null,Object? subscriptionId = null,Object? amountMinor = null,Object? currencyCode = null,Object? method = null,Object? status = null,Object? externalReference = freezed,Object? paidAt = null,Object? memberDisplayName = null,Object? refundedAmountMinor = null,Object? refundReason = freezed,Object? refundedAt = freezed,}) {
  return _then(_PaymentRecordModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: null == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentStatus,externalReference: freezed == externalReference ? _self.externalReference : externalReference // ignore: cast_nullable_to_non_nullable
as String?,paidAt: null == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime,memberDisplayName: null == memberDisplayName ? _self.memberDisplayName : memberDisplayName // ignore: cast_nullable_to_non_nullable
as String,refundedAmountMinor: null == refundedAmountMinor ? _self.refundedAmountMinor : refundedAmountMinor // ignore: cast_nullable_to_non_nullable
as int,refundReason: freezed == refundReason ? _self.refundReason : refundReason // ignore: cast_nullable_to_non_nullable
as String?,refundedAt: freezed == refundedAt ? _self.refundedAt : refundedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$PaymentRefundModel {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'branch_id') String get branchId;@JsonKey(name: 'payment_id') String get paymentId;@JsonKey(name: 'member_id') String get memberId;@JsonKey(name: 'amount_minor') int get amountMinor;@JsonKey(name: 'currency_code') String get currencyCode;@JsonKey(name: 'refund_channel') String get refundChannel; String? get reason;@JsonKey(name: 'external_reference') String? get externalReference;@JsonKey(name: 'refunded_by') String? get recordedBy;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of PaymentRefundModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentRefundModelCopyWith<PaymentRefundModel> get copyWith => _$PaymentRefundModelCopyWithImpl<PaymentRefundModel>(this as PaymentRefundModel, _$identity);

  /// Serializes this PaymentRefundModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PaymentRefundModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentRefundModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId)&&(identical(other.paymentId, _this.paymentId) || other.paymentId == _this.paymentId)&&(identical(other.memberId, _this.memberId) || other.memberId == _this.memberId)&&(identical(other.amountMinor, _this.amountMinor) || other.amountMinor == _this.amountMinor)&&(identical(other.currencyCode, _this.currencyCode) || other.currencyCode == _this.currencyCode)&&(identical(other.refundChannel, _this.refundChannel) || other.refundChannel == _this.refundChannel)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.externalReference, _this.externalReference) || other.externalReference == _this.externalReference)&&(identical(other.recordedBy, _this.recordedBy) || other.recordedBy == _this.recordedBy)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PaymentRefundModel;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.branchId,_this.paymentId,_this.memberId,_this.amountMinor,_this.currencyCode,_this.refundChannel,_this.reason,_this.externalReference,_this.recordedBy,_this.createdAt);
}

@override
String toString() {
  final _this = this as PaymentRefundModel;
  return 'PaymentRefundModel(id: ${_this.id}, organizationId: ${_this.organizationId}, branchId: ${_this.branchId}, paymentId: ${_this.paymentId}, memberId: ${_this.memberId}, amountMinor: ${_this.amountMinor}, currencyCode: ${_this.currencyCode}, refundChannel: ${_this.refundChannel}, reason: ${_this.reason}, externalReference: ${_this.externalReference}, recordedBy: ${_this.recordedBy}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $PaymentRefundModelCopyWith<$Res>  {
  factory $PaymentRefundModelCopyWith(PaymentRefundModel value, $Res Function(PaymentRefundModel) _then) = _$PaymentRefundModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'branch_id') String branchId,@JsonKey(name: 'payment_id') String paymentId,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'amount_minor') int amountMinor,@JsonKey(name: 'currency_code') String currencyCode,@JsonKey(name: 'refund_channel') String refundChannel, String? reason,@JsonKey(name: 'external_reference') String? externalReference,@JsonKey(name: 'refunded_by') String? recordedBy,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$PaymentRefundModelCopyWithImpl<$Res>
    implements $PaymentRefundModelCopyWith<$Res> {
  _$PaymentRefundModelCopyWithImpl(this._self, this._then);

  final PaymentRefundModel _self;
  final $Res Function(PaymentRefundModel) _then;

/// Create a copy of PaymentRefundModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? branchId = null,Object? paymentId = null,Object? memberId = null,Object? amountMinor = null,Object? currencyCode = null,Object? refundChannel = null,Object? reason = freezed,Object? externalReference = freezed,Object? recordedBy = freezed,Object? createdAt = null,}) {
  return _then(PaymentRefundModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,refundChannel: null == refundChannel ? _self.refundChannel : refundChannel // ignore: cast_nullable_to_non_nullable
as String,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,externalReference: freezed == externalReference ? _self.externalReference : externalReference // ignore: cast_nullable_to_non_nullable
as String?,recordedBy: freezed == recordedBy ? _self.recordedBy : recordedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentRefundModel].
extension PaymentRefundModelPatterns on PaymentRefundModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentRefundModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentRefundModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentRefundModel value)  $default,){
final _that = this;
switch (_that) {
case _PaymentRefundModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentRefundModel value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentRefundModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'payment_id')  String paymentId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'amount_minor')  int amountMinor, @JsonKey(name: 'currency_code')  String currencyCode, @JsonKey(name: 'refund_channel')  String refundChannel,  String? reason, @JsonKey(name: 'external_reference')  String? externalReference, @JsonKey(name: 'refunded_by')  String? recordedBy, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentRefundModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.branchId,_that.paymentId,_that.memberId,_that.amountMinor,_that.currencyCode,_that.refundChannel,_that.reason,_that.externalReference,_that.recordedBy,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'payment_id')  String paymentId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'amount_minor')  int amountMinor, @JsonKey(name: 'currency_code')  String currencyCode, @JsonKey(name: 'refund_channel')  String refundChannel,  String? reason, @JsonKey(name: 'external_reference')  String? externalReference, @JsonKey(name: 'refunded_by')  String? recordedBy, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PaymentRefundModel():
return $default(_that.id,_that.organizationId,_that.branchId,_that.paymentId,_that.memberId,_that.amountMinor,_that.currencyCode,_that.refundChannel,_that.reason,_that.externalReference,_that.recordedBy,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'payment_id')  String paymentId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'amount_minor')  int amountMinor, @JsonKey(name: 'currency_code')  String currencyCode, @JsonKey(name: 'refund_channel')  String refundChannel,  String? reason, @JsonKey(name: 'external_reference')  String? externalReference, @JsonKey(name: 'refunded_by')  String? recordedBy, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PaymentRefundModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.branchId,_that.paymentId,_that.memberId,_that.amountMinor,_that.currencyCode,_that.refundChannel,_that.reason,_that.externalReference,_that.recordedBy,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentRefundModel implements PaymentRefundModel {
  const _PaymentRefundModel({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'branch_id') required this.branchId, @JsonKey(name: 'payment_id') required this.paymentId, @JsonKey(name: 'member_id') required this.memberId, @JsonKey(name: 'amount_minor') required this.amountMinor, @JsonKey(name: 'currency_code') this.currencyCode = 'USD', @JsonKey(name: 'refund_channel') this.refundChannel = 'manual_recorded', this.reason, @JsonKey(name: 'external_reference') this.externalReference, @JsonKey(name: 'refunded_by') this.recordedBy, @JsonKey(name: 'created_at') required this.createdAt});
  factory _PaymentRefundModel.fromJson(Map<String, dynamic> json) => _$PaymentRefundModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'branch_id') final  String branchId;
@override@JsonKey(name: 'payment_id') final  String paymentId;
@override@JsonKey(name: 'member_id') final  String memberId;
@override@JsonKey(name: 'amount_minor') final  int amountMinor;
@override@JsonKey(name: 'currency_code') final  String currencyCode;
@override@JsonKey(name: 'refund_channel') final  String refundChannel;
@override final  String? reason;
@override@JsonKey(name: 'external_reference') final  String? externalReference;
@override@JsonKey(name: 'refunded_by') final  String? recordedBy;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of PaymentRefundModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentRefundModelCopyWith<_PaymentRefundModel> get copyWith => __$PaymentRefundModelCopyWithImpl<_PaymentRefundModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentRefundModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentRefundModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.refundChannel, refundChannel) || other.refundChannel == refundChannel)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.externalReference, externalReference) || other.externalReference == externalReference)&&(identical(other.recordedBy, recordedBy) || other.recordedBy == recordedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,branchId,paymentId,memberId,amountMinor,currencyCode,refundChannel,reason,externalReference,recordedBy,createdAt);
}

@override
String toString() {
    return 'PaymentRefundModel(id: $id, organizationId: $organizationId, branchId: $branchId, paymentId: $paymentId, memberId: $memberId, amountMinor: $amountMinor, currencyCode: $currencyCode, refundChannel: $refundChannel, reason: $reason, externalReference: $externalReference, recordedBy: $recordedBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PaymentRefundModelCopyWith<$Res> implements $PaymentRefundModelCopyWith<$Res> {
  factory _$PaymentRefundModelCopyWith(_PaymentRefundModel value, $Res Function(_PaymentRefundModel) _then) = __$PaymentRefundModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'branch_id') String branchId,@JsonKey(name: 'payment_id') String paymentId,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'amount_minor') int amountMinor,@JsonKey(name: 'currency_code') String currencyCode,@JsonKey(name: 'refund_channel') String refundChannel, String? reason,@JsonKey(name: 'external_reference') String? externalReference,@JsonKey(name: 'refunded_by') String? recordedBy,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$PaymentRefundModelCopyWithImpl<$Res>
    implements _$PaymentRefundModelCopyWith<$Res> {
  __$PaymentRefundModelCopyWithImpl(this._self, this._then);

  final _PaymentRefundModel _self;
  final $Res Function(_PaymentRefundModel) _then;

/// Create a copy of PaymentRefundModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? branchId = null,Object? paymentId = null,Object? memberId = null,Object? amountMinor = null,Object? currencyCode = null,Object? refundChannel = null,Object? reason = freezed,Object? externalReference = freezed,Object? recordedBy = freezed,Object? createdAt = null,}) {
  return _then(_PaymentRefundModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,refundChannel: null == refundChannel ? _self.refundChannel : refundChannel // ignore: cast_nullable_to_non_nullable
as String,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,externalReference: freezed == externalReference ? _self.externalReference : externalReference // ignore: cast_nullable_to_non_nullable
as String?,recordedBy: freezed == recordedBy ? _self.recordedBy : recordedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$RefundOutcome {

@JsonKey(name: 'refund_id') String get refundId;@JsonKey(name: 'payment_id') String get paymentId;@JsonKey(name: 'payment_status') PaymentStatus get paymentStatus;@JsonKey(name: 'amount_minor') int get amountMinor;@JsonKey(name: 'total_refunded_minor') int get totalRefundedMinor;@JsonKey(name: 'refund_channel') String get refundChannel;@JsonKey(name: 'idempotent_replay') bool get idempotentReplay;
/// Create a copy of RefundOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefundOutcomeCopyWith<RefundOutcome> get copyWith => _$RefundOutcomeCopyWithImpl<RefundOutcome>(this as RefundOutcome, _$identity);

  /// Serializes this RefundOutcome to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RefundOutcome;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefundOutcome&&(identical(other.refundId, _this.refundId) || other.refundId == _this.refundId)&&(identical(other.paymentId, _this.paymentId) || other.paymentId == _this.paymentId)&&(identical(other.paymentStatus, _this.paymentStatus) || other.paymentStatus == _this.paymentStatus)&&(identical(other.amountMinor, _this.amountMinor) || other.amountMinor == _this.amountMinor)&&(identical(other.totalRefundedMinor, _this.totalRefundedMinor) || other.totalRefundedMinor == _this.totalRefundedMinor)&&(identical(other.refundChannel, _this.refundChannel) || other.refundChannel == _this.refundChannel)&&(identical(other.idempotentReplay, _this.idempotentReplay) || other.idempotentReplay == _this.idempotentReplay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RefundOutcome;
  return Object.hash(runtimeType,_this.refundId,_this.paymentId,_this.paymentStatus,_this.amountMinor,_this.totalRefundedMinor,_this.refundChannel,_this.idempotentReplay);
}

@override
String toString() {
  final _this = this as RefundOutcome;
  return 'RefundOutcome(refundId: ${_this.refundId}, paymentId: ${_this.paymentId}, paymentStatus: ${_this.paymentStatus}, amountMinor: ${_this.amountMinor}, totalRefundedMinor: ${_this.totalRefundedMinor}, refundChannel: ${_this.refundChannel}, idempotentReplay: ${_this.idempotentReplay})';
}


}

/// @nodoc
abstract mixin class $RefundOutcomeCopyWith<$Res>  {
  factory $RefundOutcomeCopyWith(RefundOutcome value, $Res Function(RefundOutcome) _then) = _$RefundOutcomeCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'refund_id') String refundId,@JsonKey(name: 'payment_id') String paymentId,@JsonKey(name: 'payment_status') PaymentStatus paymentStatus,@JsonKey(name: 'amount_minor') int amountMinor,@JsonKey(name: 'total_refunded_minor') int totalRefundedMinor,@JsonKey(name: 'refund_channel') String refundChannel,@JsonKey(name: 'idempotent_replay') bool idempotentReplay
});




}
/// @nodoc
class _$RefundOutcomeCopyWithImpl<$Res>
    implements $RefundOutcomeCopyWith<$Res> {
  _$RefundOutcomeCopyWithImpl(this._self, this._then);

  final RefundOutcome _self;
  final $Res Function(RefundOutcome) _then;

/// Create a copy of RefundOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? refundId = null,Object? paymentId = null,Object? paymentStatus = null,Object? amountMinor = null,Object? totalRefundedMinor = null,Object? refundChannel = null,Object? idempotentReplay = null,}) {
  return _then(RefundOutcome(
refundId: null == refundId ? _self.refundId : refundId // ignore: cast_nullable_to_non_nullable
as String,paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,totalRefundedMinor: null == totalRefundedMinor ? _self.totalRefundedMinor : totalRefundedMinor // ignore: cast_nullable_to_non_nullable
as int,refundChannel: null == refundChannel ? _self.refundChannel : refundChannel // ignore: cast_nullable_to_non_nullable
as String,idempotentReplay: null == idempotentReplay ? _self.idempotentReplay : idempotentReplay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RefundOutcome].
extension RefundOutcomePatterns on RefundOutcome {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RefundOutcome value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RefundOutcome() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RefundOutcome value)  $default,){
final _that = this;
switch (_that) {
case _RefundOutcome():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RefundOutcome value)?  $default,){
final _that = this;
switch (_that) {
case _RefundOutcome() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'refund_id')  String refundId, @JsonKey(name: 'payment_id')  String paymentId, @JsonKey(name: 'payment_status')  PaymentStatus paymentStatus, @JsonKey(name: 'amount_minor')  int amountMinor, @JsonKey(name: 'total_refunded_minor')  int totalRefundedMinor, @JsonKey(name: 'refund_channel')  String refundChannel, @JsonKey(name: 'idempotent_replay')  bool idempotentReplay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RefundOutcome() when $default != null:
return $default(_that.refundId,_that.paymentId,_that.paymentStatus,_that.amountMinor,_that.totalRefundedMinor,_that.refundChannel,_that.idempotentReplay);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'refund_id')  String refundId, @JsonKey(name: 'payment_id')  String paymentId, @JsonKey(name: 'payment_status')  PaymentStatus paymentStatus, @JsonKey(name: 'amount_minor')  int amountMinor, @JsonKey(name: 'total_refunded_minor')  int totalRefundedMinor, @JsonKey(name: 'refund_channel')  String refundChannel, @JsonKey(name: 'idempotent_replay')  bool idempotentReplay)  $default,) {final _that = this;
switch (_that) {
case _RefundOutcome():
return $default(_that.refundId,_that.paymentId,_that.paymentStatus,_that.amountMinor,_that.totalRefundedMinor,_that.refundChannel,_that.idempotentReplay);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'refund_id')  String refundId, @JsonKey(name: 'payment_id')  String paymentId, @JsonKey(name: 'payment_status')  PaymentStatus paymentStatus, @JsonKey(name: 'amount_minor')  int amountMinor, @JsonKey(name: 'total_refunded_minor')  int totalRefundedMinor, @JsonKey(name: 'refund_channel')  String refundChannel, @JsonKey(name: 'idempotent_replay')  bool idempotentReplay)?  $default,) {final _that = this;
switch (_that) {
case _RefundOutcome() when $default != null:
return $default(_that.refundId,_that.paymentId,_that.paymentStatus,_that.amountMinor,_that.totalRefundedMinor,_that.refundChannel,_that.idempotentReplay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RefundOutcome implements RefundOutcome {
  const _RefundOutcome({@JsonKey(name: 'refund_id') required this.refundId, @JsonKey(name: 'payment_id') required this.paymentId, @JsonKey(name: 'payment_status') required this.paymentStatus, @JsonKey(name: 'amount_minor') required this.amountMinor, @JsonKey(name: 'total_refunded_minor') required this.totalRefundedMinor, @JsonKey(name: 'refund_channel') this.refundChannel = 'manual_recorded', @JsonKey(name: 'idempotent_replay') this.idempotentReplay = false});
  factory _RefundOutcome.fromJson(Map<String, dynamic> json) => _$RefundOutcomeFromJson(json);

@override@JsonKey(name: 'refund_id') final  String refundId;
@override@JsonKey(name: 'payment_id') final  String paymentId;
@override@JsonKey(name: 'payment_status') final  PaymentStatus paymentStatus;
@override@JsonKey(name: 'amount_minor') final  int amountMinor;
@override@JsonKey(name: 'total_refunded_minor') final  int totalRefundedMinor;
@override@JsonKey(name: 'refund_channel') final  String refundChannel;
@override@JsonKey(name: 'idempotent_replay') final  bool idempotentReplay;

/// Create a copy of RefundOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefundOutcomeCopyWith<_RefundOutcome> get copyWith => __$RefundOutcomeCopyWithImpl<_RefundOutcome>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RefundOutcomeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefundOutcome&&(identical(other.refundId, refundId) || other.refundId == refundId)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.totalRefundedMinor, totalRefundedMinor) || other.totalRefundedMinor == totalRefundedMinor)&&(identical(other.refundChannel, refundChannel) || other.refundChannel == refundChannel)&&(identical(other.idempotentReplay, idempotentReplay) || other.idempotentReplay == idempotentReplay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,refundId,paymentId,paymentStatus,amountMinor,totalRefundedMinor,refundChannel,idempotentReplay);
}

@override
String toString() {
    return 'RefundOutcome(refundId: $refundId, paymentId: $paymentId, paymentStatus: $paymentStatus, amountMinor: $amountMinor, totalRefundedMinor: $totalRefundedMinor, refundChannel: $refundChannel, idempotentReplay: $idempotentReplay)';
}


}

/// @nodoc
abstract mixin class _$RefundOutcomeCopyWith<$Res> implements $RefundOutcomeCopyWith<$Res> {
  factory _$RefundOutcomeCopyWith(_RefundOutcome value, $Res Function(_RefundOutcome) _then) = __$RefundOutcomeCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'refund_id') String refundId,@JsonKey(name: 'payment_id') String paymentId,@JsonKey(name: 'payment_status') PaymentStatus paymentStatus,@JsonKey(name: 'amount_minor') int amountMinor,@JsonKey(name: 'total_refunded_minor') int totalRefundedMinor,@JsonKey(name: 'refund_channel') String refundChannel,@JsonKey(name: 'idempotent_replay') bool idempotentReplay
});




}
/// @nodoc
class __$RefundOutcomeCopyWithImpl<$Res>
    implements _$RefundOutcomeCopyWith<$Res> {
  __$RefundOutcomeCopyWithImpl(this._self, this._then);

  final _RefundOutcome _self;
  final $Res Function(_RefundOutcome) _then;

/// Create a copy of RefundOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? refundId = null,Object? paymentId = null,Object? paymentStatus = null,Object? amountMinor = null,Object? totalRefundedMinor = null,Object? refundChannel = null,Object? idempotentReplay = null,}) {
  return _then(_RefundOutcome(
refundId: null == refundId ? _self.refundId : refundId // ignore: cast_nullable_to_non_nullable
as String,paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,totalRefundedMinor: null == totalRefundedMinor ? _self.totalRefundedMinor : totalRefundedMinor // ignore: cast_nullable_to_non_nullable
as int,refundChannel: null == refundChannel ? _self.refundChannel : refundChannel // ignore: cast_nullable_to_non_nullable
as String,idempotentReplay: null == idempotentReplay ? _self.idempotentReplay : idempotentReplay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
