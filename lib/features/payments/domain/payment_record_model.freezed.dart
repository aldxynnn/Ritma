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

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'branch_id') String get branchId;@JsonKey(name: 'member_id') String get memberId;@JsonKey(name: 'subscription_id') String get subscriptionId;@JsonKey(name: 'amount_minor') int get amountMinor;@JsonKey(name: 'currency_code') String get currencyCode; PaymentMethod get method; PaymentStatus get status;@JsonKey(name: 'external_reference') String? get externalReference;@JsonKey(name: 'paid_at') DateTime get paidAt;@JsonKey(name: 'member_display_name') String get memberDisplayName;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentRecordModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId)&&(identical(other.memberId, _this.memberId) || other.memberId == _this.memberId)&&(identical(other.subscriptionId, _this.subscriptionId) || other.subscriptionId == _this.subscriptionId)&&(identical(other.amountMinor, _this.amountMinor) || other.amountMinor == _this.amountMinor)&&(identical(other.currencyCode, _this.currencyCode) || other.currencyCode == _this.currencyCode)&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.externalReference, _this.externalReference) || other.externalReference == _this.externalReference)&&(identical(other.paidAt, _this.paidAt) || other.paidAt == _this.paidAt)&&(identical(other.memberDisplayName, _this.memberDisplayName) || other.memberDisplayName == _this.memberDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PaymentRecordModel;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.branchId,_this.memberId,_this.subscriptionId,_this.amountMinor,_this.currencyCode,_this.method,_this.status,_this.externalReference,_this.paidAt,_this.memberDisplayName);
}

@override
String toString() {
  final _this = this as PaymentRecordModel;
  return 'PaymentRecordModel(id: ${_this.id}, organizationId: ${_this.organizationId}, branchId: ${_this.branchId}, memberId: ${_this.memberId}, subscriptionId: ${_this.subscriptionId}, amountMinor: ${_this.amountMinor}, currencyCode: ${_this.currencyCode}, method: ${_this.method}, status: ${_this.status}, externalReference: ${_this.externalReference}, paidAt: ${_this.paidAt}, memberDisplayName: ${_this.memberDisplayName})';
}


}

/// @nodoc
abstract mixin class $PaymentRecordModelCopyWith<$Res>  {
  factory $PaymentRecordModelCopyWith(PaymentRecordModel value, $Res Function(PaymentRecordModel) _then) = _$PaymentRecordModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'branch_id') String branchId,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'subscription_id') String subscriptionId,@JsonKey(name: 'amount_minor') int amountMinor,@JsonKey(name: 'currency_code') String currencyCode, PaymentMethod method, PaymentStatus status,@JsonKey(name: 'external_reference') String? externalReference,@JsonKey(name: 'paid_at') DateTime paidAt,@JsonKey(name: 'member_display_name') String memberDisplayName
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? branchId = null,Object? memberId = null,Object? subscriptionId = null,Object? amountMinor = null,Object? currencyCode = null,Object? method = null,Object? status = null,Object? externalReference = freezed,Object? paidAt = null,Object? memberDisplayName = null,}) {
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
as String,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'subscription_id')  String subscriptionId, @JsonKey(name: 'amount_minor')  int amountMinor, @JsonKey(name: 'currency_code')  String currencyCode,  PaymentMethod method,  PaymentStatus status, @JsonKey(name: 'external_reference')  String? externalReference, @JsonKey(name: 'paid_at')  DateTime paidAt, @JsonKey(name: 'member_display_name')  String memberDisplayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentRecordModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.branchId,_that.memberId,_that.subscriptionId,_that.amountMinor,_that.currencyCode,_that.method,_that.status,_that.externalReference,_that.paidAt,_that.memberDisplayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'subscription_id')  String subscriptionId, @JsonKey(name: 'amount_minor')  int amountMinor, @JsonKey(name: 'currency_code')  String currencyCode,  PaymentMethod method,  PaymentStatus status, @JsonKey(name: 'external_reference')  String? externalReference, @JsonKey(name: 'paid_at')  DateTime paidAt, @JsonKey(name: 'member_display_name')  String memberDisplayName)  $default,) {final _that = this;
switch (_that) {
case _PaymentRecordModel():
return $default(_that.id,_that.organizationId,_that.branchId,_that.memberId,_that.subscriptionId,_that.amountMinor,_that.currencyCode,_that.method,_that.status,_that.externalReference,_that.paidAt,_that.memberDisplayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'subscription_id')  String subscriptionId, @JsonKey(name: 'amount_minor')  int amountMinor, @JsonKey(name: 'currency_code')  String currencyCode,  PaymentMethod method,  PaymentStatus status, @JsonKey(name: 'external_reference')  String? externalReference, @JsonKey(name: 'paid_at')  DateTime paidAt, @JsonKey(name: 'member_display_name')  String memberDisplayName)?  $default,) {final _that = this;
switch (_that) {
case _PaymentRecordModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.branchId,_that.memberId,_that.subscriptionId,_that.amountMinor,_that.currencyCode,_that.method,_that.status,_that.externalReference,_that.paidAt,_that.memberDisplayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentRecordModel implements PaymentRecordModel {
  const _PaymentRecordModel({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'branch_id') required this.branchId, @JsonKey(name: 'member_id') required this.memberId, @JsonKey(name: 'subscription_id') required this.subscriptionId, @JsonKey(name: 'amount_minor') required this.amountMinor, @JsonKey(name: 'currency_code') this.currencyCode = 'USD', required this.method, this.status = PaymentStatus.paid, @JsonKey(name: 'external_reference') this.externalReference, @JsonKey(name: 'paid_at') required this.paidAt, @JsonKey(name: 'member_display_name') this.memberDisplayName = ''});
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentRecordModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.method, method) || other.method == method)&&(identical(other.status, status) || other.status == status)&&(identical(other.externalReference, externalReference) || other.externalReference == externalReference)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.memberDisplayName, memberDisplayName) || other.memberDisplayName == memberDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,branchId,memberId,subscriptionId,amountMinor,currencyCode,method,status,externalReference,paidAt,memberDisplayName);
}

@override
String toString() {
    return 'PaymentRecordModel(id: $id, organizationId: $organizationId, branchId: $branchId, memberId: $memberId, subscriptionId: $subscriptionId, amountMinor: $amountMinor, currencyCode: $currencyCode, method: $method, status: $status, externalReference: $externalReference, paidAt: $paidAt, memberDisplayName: $memberDisplayName)';
}


}

/// @nodoc
abstract mixin class _$PaymentRecordModelCopyWith<$Res> implements $PaymentRecordModelCopyWith<$Res> {
  factory _$PaymentRecordModelCopyWith(_PaymentRecordModel value, $Res Function(_PaymentRecordModel) _then) = __$PaymentRecordModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'branch_id') String branchId,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'subscription_id') String subscriptionId,@JsonKey(name: 'amount_minor') int amountMinor,@JsonKey(name: 'currency_code') String currencyCode, PaymentMethod method, PaymentStatus status,@JsonKey(name: 'external_reference') String? externalReference,@JsonKey(name: 'paid_at') DateTime paidAt,@JsonKey(name: 'member_display_name') String memberDisplayName
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? branchId = null,Object? memberId = null,Object? subscriptionId = null,Object? amountMinor = null,Object? currencyCode = null,Object? method = null,Object? status = null,Object? externalReference = freezed,Object? paidAt = null,Object? memberDisplayName = null,}) {
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
as String,
  ));
}


}

// dart format on
