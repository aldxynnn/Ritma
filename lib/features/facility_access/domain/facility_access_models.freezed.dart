// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'facility_access_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QrPassToken {

 String get token;@JsonKey(name: 'issued_at') DateTime get issuedAt;@JsonKey(name: 'expires_at') DateTime get expiresAt;@JsonKey(name: 'ttl_seconds') int get ttlSeconds;
/// Create a copy of QrPassToken
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QrPassTokenCopyWith<QrPassToken> get copyWith => _$QrPassTokenCopyWithImpl<QrPassToken>(this as QrPassToken, _$identity);

  /// Serializes this QrPassToken to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as QrPassToken;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QrPassToken&&(identical(other.token, _this.token) || other.token == _this.token)&&(identical(other.issuedAt, _this.issuedAt) || other.issuedAt == _this.issuedAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.ttlSeconds, _this.ttlSeconds) || other.ttlSeconds == _this.ttlSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as QrPassToken;
  return Object.hash(runtimeType,_this.token,_this.issuedAt,_this.expiresAt,_this.ttlSeconds);
}

@override
String toString() {
  final _this = this as QrPassToken;
  return 'QrPassToken(token: ${_this.token}, issuedAt: ${_this.issuedAt}, expiresAt: ${_this.expiresAt}, ttlSeconds: ${_this.ttlSeconds})';
}


}

/// @nodoc
abstract mixin class $QrPassTokenCopyWith<$Res>  {
  factory $QrPassTokenCopyWith(QrPassToken value, $Res Function(QrPassToken) _then) = _$QrPassTokenCopyWithImpl;
@useResult
$Res call({
 String token,@JsonKey(name: 'issued_at') DateTime issuedAt,@JsonKey(name: 'expires_at') DateTime expiresAt,@JsonKey(name: 'ttl_seconds') int ttlSeconds
});




}
/// @nodoc
class _$QrPassTokenCopyWithImpl<$Res>
    implements $QrPassTokenCopyWith<$Res> {
  _$QrPassTokenCopyWithImpl(this._self, this._then);

  final QrPassToken _self;
  final $Res Function(QrPassToken) _then;

/// Create a copy of QrPassToken
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? issuedAt = null,Object? expiresAt = null,Object? ttlSeconds = null,}) {
  return _then(QrPassToken(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,issuedAt: null == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,ttlSeconds: null == ttlSeconds ? _self.ttlSeconds : ttlSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [QrPassToken].
extension QrPassTokenPatterns on QrPassToken {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QrPassToken value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QrPassToken() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QrPassToken value)  $default,){
final _that = this;
switch (_that) {
case _QrPassToken():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QrPassToken value)?  $default,){
final _that = this;
switch (_that) {
case _QrPassToken() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token, @JsonKey(name: 'issued_at')  DateTime issuedAt, @JsonKey(name: 'expires_at')  DateTime expiresAt, @JsonKey(name: 'ttl_seconds')  int ttlSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QrPassToken() when $default != null:
return $default(_that.token,_that.issuedAt,_that.expiresAt,_that.ttlSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token, @JsonKey(name: 'issued_at')  DateTime issuedAt, @JsonKey(name: 'expires_at')  DateTime expiresAt, @JsonKey(name: 'ttl_seconds')  int ttlSeconds)  $default,) {final _that = this;
switch (_that) {
case _QrPassToken():
return $default(_that.token,_that.issuedAt,_that.expiresAt,_that.ttlSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token, @JsonKey(name: 'issued_at')  DateTime issuedAt, @JsonKey(name: 'expires_at')  DateTime expiresAt, @JsonKey(name: 'ttl_seconds')  int ttlSeconds)?  $default,) {final _that = this;
switch (_that) {
case _QrPassToken() when $default != null:
return $default(_that.token,_that.issuedAt,_that.expiresAt,_that.ttlSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QrPassToken implements QrPassToken {
  const _QrPassToken({required this.token, @JsonKey(name: 'issued_at') required this.issuedAt, @JsonKey(name: 'expires_at') required this.expiresAt, @JsonKey(name: 'ttl_seconds') this.ttlSeconds = 60});
  factory _QrPassToken.fromJson(Map<String, dynamic> json) => _$QrPassTokenFromJson(json);

@override final  String token;
@override@JsonKey(name: 'issued_at') final  DateTime issuedAt;
@override@JsonKey(name: 'expires_at') final  DateTime expiresAt;
@override@JsonKey(name: 'ttl_seconds') final  int ttlSeconds;

/// Create a copy of QrPassToken
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QrPassTokenCopyWith<_QrPassToken> get copyWith => __$QrPassTokenCopyWithImpl<_QrPassToken>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QrPassTokenToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QrPassToken&&(identical(other.token, token) || other.token == token)&&(identical(other.issuedAt, issuedAt) || other.issuedAt == issuedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.ttlSeconds, ttlSeconds) || other.ttlSeconds == ttlSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,token,issuedAt,expiresAt,ttlSeconds);
}

@override
String toString() {
    return 'QrPassToken(token: $token, issuedAt: $issuedAt, expiresAt: $expiresAt, ttlSeconds: $ttlSeconds)';
}


}

/// @nodoc
abstract mixin class _$QrPassTokenCopyWith<$Res> implements $QrPassTokenCopyWith<$Res> {
  factory _$QrPassTokenCopyWith(_QrPassToken value, $Res Function(_QrPassToken) _then) = __$QrPassTokenCopyWithImpl;
@override @useResult
$Res call({
 String token,@JsonKey(name: 'issued_at') DateTime issuedAt,@JsonKey(name: 'expires_at') DateTime expiresAt,@JsonKey(name: 'ttl_seconds') int ttlSeconds
});




}
/// @nodoc
class __$QrPassTokenCopyWithImpl<$Res>
    implements _$QrPassTokenCopyWith<$Res> {
  __$QrPassTokenCopyWithImpl(this._self, this._then);

  final _QrPassToken _self;
  final $Res Function(_QrPassToken) _then;

/// Create a copy of QrPassToken
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? issuedAt = null,Object? expiresAt = null,Object? ttlSeconds = null,}) {
  return _then(_QrPassToken(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,issuedAt: null == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,ttlSeconds: null == ttlSeconds ? _self.ttlSeconds : ttlSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CheckInOutcome {

 bool get allowed;@JsonKey(name: 'reason_code') String get reasonCode;@JsonKey(name: 'visit_id') String? get visitId;@JsonKey(name: 'member_id') String? get memberId;@JsonKey(name: 'member_name') String? get memberName;@JsonKey(name: 'entitlement_valid_until') DateTime? get entitlementValidUntil;@JsonKey(name: 'idempotent_replay') bool get idempotentReplay;
/// Create a copy of CheckInOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckInOutcomeCopyWith<CheckInOutcome> get copyWith => _$CheckInOutcomeCopyWithImpl<CheckInOutcome>(this as CheckInOutcome, _$identity);

  /// Serializes this CheckInOutcome to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CheckInOutcome;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckInOutcome&&(identical(other.allowed, _this.allowed) || other.allowed == _this.allowed)&&(identical(other.reasonCode, _this.reasonCode) || other.reasonCode == _this.reasonCode)&&(identical(other.visitId, _this.visitId) || other.visitId == _this.visitId)&&(identical(other.memberId, _this.memberId) || other.memberId == _this.memberId)&&(identical(other.memberName, _this.memberName) || other.memberName == _this.memberName)&&(identical(other.entitlementValidUntil, _this.entitlementValidUntil) || other.entitlementValidUntil == _this.entitlementValidUntil)&&(identical(other.idempotentReplay, _this.idempotentReplay) || other.idempotentReplay == _this.idempotentReplay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CheckInOutcome;
  return Object.hash(runtimeType,_this.allowed,_this.reasonCode,_this.visitId,_this.memberId,_this.memberName,_this.entitlementValidUntil,_this.idempotentReplay);
}

@override
String toString() {
  final _this = this as CheckInOutcome;
  return 'CheckInOutcome(allowed: ${_this.allowed}, reasonCode: ${_this.reasonCode}, visitId: ${_this.visitId}, memberId: ${_this.memberId}, memberName: ${_this.memberName}, entitlementValidUntil: ${_this.entitlementValidUntil}, idempotentReplay: ${_this.idempotentReplay})';
}


}

/// @nodoc
abstract mixin class $CheckInOutcomeCopyWith<$Res>  {
  factory $CheckInOutcomeCopyWith(CheckInOutcome value, $Res Function(CheckInOutcome) _then) = _$CheckInOutcomeCopyWithImpl;
@useResult
$Res call({
 bool allowed,@JsonKey(name: 'reason_code') String reasonCode,@JsonKey(name: 'visit_id') String? visitId,@JsonKey(name: 'member_id') String? memberId,@JsonKey(name: 'member_name') String? memberName,@JsonKey(name: 'entitlement_valid_until') DateTime? entitlementValidUntil,@JsonKey(name: 'idempotent_replay') bool idempotentReplay
});




}
/// @nodoc
class _$CheckInOutcomeCopyWithImpl<$Res>
    implements $CheckInOutcomeCopyWith<$Res> {
  _$CheckInOutcomeCopyWithImpl(this._self, this._then);

  final CheckInOutcome _self;
  final $Res Function(CheckInOutcome) _then;

/// Create a copy of CheckInOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? allowed = null,Object? reasonCode = null,Object? visitId = freezed,Object? memberId = freezed,Object? memberName = freezed,Object? entitlementValidUntil = freezed,Object? idempotentReplay = null,}) {
  return _then(CheckInOutcome(
allowed: null == allowed ? _self.allowed : allowed // ignore: cast_nullable_to_non_nullable
as bool,reasonCode: null == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as String,visitId: freezed == visitId ? _self.visitId : visitId // ignore: cast_nullable_to_non_nullable
as String?,memberId: freezed == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String?,memberName: freezed == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String?,entitlementValidUntil: freezed == entitlementValidUntil ? _self.entitlementValidUntil : entitlementValidUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,idempotentReplay: null == idempotentReplay ? _self.idempotentReplay : idempotentReplay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckInOutcome].
extension CheckInOutcomePatterns on CheckInOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckInOutcome value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckInOutcome() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckInOutcome value)  $default,){
final _that = this;
switch (_that) {
case _CheckInOutcome():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckInOutcome value)?  $default,){
final _that = this;
switch (_that) {
case _CheckInOutcome() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool allowed, @JsonKey(name: 'reason_code')  String reasonCode, @JsonKey(name: 'visit_id')  String? visitId, @JsonKey(name: 'member_id')  String? memberId, @JsonKey(name: 'member_name')  String? memberName, @JsonKey(name: 'entitlement_valid_until')  DateTime? entitlementValidUntil, @JsonKey(name: 'idempotent_replay')  bool idempotentReplay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckInOutcome() when $default != null:
return $default(_that.allowed,_that.reasonCode,_that.visitId,_that.memberId,_that.memberName,_that.entitlementValidUntil,_that.idempotentReplay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool allowed, @JsonKey(name: 'reason_code')  String reasonCode, @JsonKey(name: 'visit_id')  String? visitId, @JsonKey(name: 'member_id')  String? memberId, @JsonKey(name: 'member_name')  String? memberName, @JsonKey(name: 'entitlement_valid_until')  DateTime? entitlementValidUntil, @JsonKey(name: 'idempotent_replay')  bool idempotentReplay)  $default,) {final _that = this;
switch (_that) {
case _CheckInOutcome():
return $default(_that.allowed,_that.reasonCode,_that.visitId,_that.memberId,_that.memberName,_that.entitlementValidUntil,_that.idempotentReplay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool allowed, @JsonKey(name: 'reason_code')  String reasonCode, @JsonKey(name: 'visit_id')  String? visitId, @JsonKey(name: 'member_id')  String? memberId, @JsonKey(name: 'member_name')  String? memberName, @JsonKey(name: 'entitlement_valid_until')  DateTime? entitlementValidUntil, @JsonKey(name: 'idempotent_replay')  bool idempotentReplay)?  $default,) {final _that = this;
switch (_that) {
case _CheckInOutcome() when $default != null:
return $default(_that.allowed,_that.reasonCode,_that.visitId,_that.memberId,_that.memberName,_that.entitlementValidUntil,_that.idempotentReplay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckInOutcome implements CheckInOutcome {
  const _CheckInOutcome({required this.allowed, @JsonKey(name: 'reason_code') this.reasonCode = 'OK', @JsonKey(name: 'visit_id') this.visitId, @JsonKey(name: 'member_id') this.memberId, @JsonKey(name: 'member_name') this.memberName, @JsonKey(name: 'entitlement_valid_until') this.entitlementValidUntil, @JsonKey(name: 'idempotent_replay') this.idempotentReplay = false});
  factory _CheckInOutcome.fromJson(Map<String, dynamic> json) => _$CheckInOutcomeFromJson(json);

@override final  bool allowed;
@override@JsonKey(name: 'reason_code') final  String reasonCode;
@override@JsonKey(name: 'visit_id') final  String? visitId;
@override@JsonKey(name: 'member_id') final  String? memberId;
@override@JsonKey(name: 'member_name') final  String? memberName;
@override@JsonKey(name: 'entitlement_valid_until') final  DateTime? entitlementValidUntil;
@override@JsonKey(name: 'idempotent_replay') final  bool idempotentReplay;

/// Create a copy of CheckInOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckInOutcomeCopyWith<_CheckInOutcome> get copyWith => __$CheckInOutcomeCopyWithImpl<_CheckInOutcome>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckInOutcomeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckInOutcome&&(identical(other.allowed, allowed) || other.allowed == allowed)&&(identical(other.reasonCode, reasonCode) || other.reasonCode == reasonCode)&&(identical(other.visitId, visitId) || other.visitId == visitId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.entitlementValidUntil, entitlementValidUntil) || other.entitlementValidUntil == entitlementValidUntil)&&(identical(other.idempotentReplay, idempotentReplay) || other.idempotentReplay == idempotentReplay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,allowed,reasonCode,visitId,memberId,memberName,entitlementValidUntil,idempotentReplay);
}

@override
String toString() {
    return 'CheckInOutcome(allowed: $allowed, reasonCode: $reasonCode, visitId: $visitId, memberId: $memberId, memberName: $memberName, entitlementValidUntil: $entitlementValidUntil, idempotentReplay: $idempotentReplay)';
}


}

/// @nodoc
abstract mixin class _$CheckInOutcomeCopyWith<$Res> implements $CheckInOutcomeCopyWith<$Res> {
  factory _$CheckInOutcomeCopyWith(_CheckInOutcome value, $Res Function(_CheckInOutcome) _then) = __$CheckInOutcomeCopyWithImpl;
@override @useResult
$Res call({
 bool allowed,@JsonKey(name: 'reason_code') String reasonCode,@JsonKey(name: 'visit_id') String? visitId,@JsonKey(name: 'member_id') String? memberId,@JsonKey(name: 'member_name') String? memberName,@JsonKey(name: 'entitlement_valid_until') DateTime? entitlementValidUntil,@JsonKey(name: 'idempotent_replay') bool idempotentReplay
});




}
/// @nodoc
class __$CheckInOutcomeCopyWithImpl<$Res>
    implements _$CheckInOutcomeCopyWith<$Res> {
  __$CheckInOutcomeCopyWithImpl(this._self, this._then);

  final _CheckInOutcome _self;
  final $Res Function(_CheckInOutcome) _then;

/// Create a copy of CheckInOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? allowed = null,Object? reasonCode = null,Object? visitId = freezed,Object? memberId = freezed,Object? memberName = freezed,Object? entitlementValidUntil = freezed,Object? idempotentReplay = null,}) {
  return _then(_CheckInOutcome(
allowed: null == allowed ? _self.allowed : allowed // ignore: cast_nullable_to_non_nullable
as bool,reasonCode: null == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as String,visitId: freezed == visitId ? _self.visitId : visitId // ignore: cast_nullable_to_non_nullable
as String?,memberId: freezed == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String?,memberName: freezed == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String?,entitlementValidUntil: freezed == entitlementValidUntil ? _self.entitlementValidUntil : entitlementValidUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,idempotentReplay: null == idempotentReplay ? _self.idempotentReplay : idempotentReplay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$FacilityVisitModel {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'branch_id') String get branchId;@JsonKey(name: 'member_id') String get memberId;@JsonKey(name: 'member_name') String? get memberName;@JsonKey(name: 'entitlement_id') String? get entitlementId;@JsonKey(name: 'check_in_method') String get checkInMethod;@JsonKey(name: 'override_reason') String? get overrideReason;@JsonKey(name: 'checked_in_at') DateTime get checkedInAt;@JsonKey(name: 'checked_out_at') DateTime? get checkedOutAt;
/// Create a copy of FacilityVisitModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FacilityVisitModelCopyWith<FacilityVisitModel> get copyWith => _$FacilityVisitModelCopyWithImpl<FacilityVisitModel>(this as FacilityVisitModel, _$identity);

  /// Serializes this FacilityVisitModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FacilityVisitModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FacilityVisitModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId)&&(identical(other.memberId, _this.memberId) || other.memberId == _this.memberId)&&(identical(other.memberName, _this.memberName) || other.memberName == _this.memberName)&&(identical(other.entitlementId, _this.entitlementId) || other.entitlementId == _this.entitlementId)&&(identical(other.checkInMethod, _this.checkInMethod) || other.checkInMethod == _this.checkInMethod)&&(identical(other.overrideReason, _this.overrideReason) || other.overrideReason == _this.overrideReason)&&(identical(other.checkedInAt, _this.checkedInAt) || other.checkedInAt == _this.checkedInAt)&&(identical(other.checkedOutAt, _this.checkedOutAt) || other.checkedOutAt == _this.checkedOutAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FacilityVisitModel;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.branchId,_this.memberId,_this.memberName,_this.entitlementId,_this.checkInMethod,_this.overrideReason,_this.checkedInAt,_this.checkedOutAt);
}

@override
String toString() {
  final _this = this as FacilityVisitModel;
  return 'FacilityVisitModel(id: ${_this.id}, organizationId: ${_this.organizationId}, branchId: ${_this.branchId}, memberId: ${_this.memberId}, memberName: ${_this.memberName}, entitlementId: ${_this.entitlementId}, checkInMethod: ${_this.checkInMethod}, overrideReason: ${_this.overrideReason}, checkedInAt: ${_this.checkedInAt}, checkedOutAt: ${_this.checkedOutAt})';
}


}

/// @nodoc
abstract mixin class $FacilityVisitModelCopyWith<$Res>  {
  factory $FacilityVisitModelCopyWith(FacilityVisitModel value, $Res Function(FacilityVisitModel) _then) = _$FacilityVisitModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'branch_id') String branchId,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'member_name') String? memberName,@JsonKey(name: 'entitlement_id') String? entitlementId,@JsonKey(name: 'check_in_method') String checkInMethod,@JsonKey(name: 'override_reason') String? overrideReason,@JsonKey(name: 'checked_in_at') DateTime checkedInAt,@JsonKey(name: 'checked_out_at') DateTime? checkedOutAt
});




}
/// @nodoc
class _$FacilityVisitModelCopyWithImpl<$Res>
    implements $FacilityVisitModelCopyWith<$Res> {
  _$FacilityVisitModelCopyWithImpl(this._self, this._then);

  final FacilityVisitModel _self;
  final $Res Function(FacilityVisitModel) _then;

/// Create a copy of FacilityVisitModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? branchId = null,Object? memberId = null,Object? memberName = freezed,Object? entitlementId = freezed,Object? checkInMethod = null,Object? overrideReason = freezed,Object? checkedInAt = null,Object? checkedOutAt = freezed,}) {
  return _then(FacilityVisitModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: freezed == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String?,entitlementId: freezed == entitlementId ? _self.entitlementId : entitlementId // ignore: cast_nullable_to_non_nullable
as String?,checkInMethod: null == checkInMethod ? _self.checkInMethod : checkInMethod // ignore: cast_nullable_to_non_nullable
as String,overrideReason: freezed == overrideReason ? _self.overrideReason : overrideReason // ignore: cast_nullable_to_non_nullable
as String?,checkedInAt: null == checkedInAt ? _self.checkedInAt : checkedInAt // ignore: cast_nullable_to_non_nullable
as DateTime,checkedOutAt: freezed == checkedOutAt ? _self.checkedOutAt : checkedOutAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [FacilityVisitModel].
extension FacilityVisitModelPatterns on FacilityVisitModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FacilityVisitModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FacilityVisitModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FacilityVisitModel value)  $default,){
final _that = this;
switch (_that) {
case _FacilityVisitModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FacilityVisitModel value)?  $default,){
final _that = this;
switch (_that) {
case _FacilityVisitModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'member_name')  String? memberName, @JsonKey(name: 'entitlement_id')  String? entitlementId, @JsonKey(name: 'check_in_method')  String checkInMethod, @JsonKey(name: 'override_reason')  String? overrideReason, @JsonKey(name: 'checked_in_at')  DateTime checkedInAt, @JsonKey(name: 'checked_out_at')  DateTime? checkedOutAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FacilityVisitModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.branchId,_that.memberId,_that.memberName,_that.entitlementId,_that.checkInMethod,_that.overrideReason,_that.checkedInAt,_that.checkedOutAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'member_name')  String? memberName, @JsonKey(name: 'entitlement_id')  String? entitlementId, @JsonKey(name: 'check_in_method')  String checkInMethod, @JsonKey(name: 'override_reason')  String? overrideReason, @JsonKey(name: 'checked_in_at')  DateTime checkedInAt, @JsonKey(name: 'checked_out_at')  DateTime? checkedOutAt)  $default,) {final _that = this;
switch (_that) {
case _FacilityVisitModel():
return $default(_that.id,_that.organizationId,_that.branchId,_that.memberId,_that.memberName,_that.entitlementId,_that.checkInMethod,_that.overrideReason,_that.checkedInAt,_that.checkedOutAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'member_name')  String? memberName, @JsonKey(name: 'entitlement_id')  String? entitlementId, @JsonKey(name: 'check_in_method')  String checkInMethod, @JsonKey(name: 'override_reason')  String? overrideReason, @JsonKey(name: 'checked_in_at')  DateTime checkedInAt, @JsonKey(name: 'checked_out_at')  DateTime? checkedOutAt)?  $default,) {final _that = this;
switch (_that) {
case _FacilityVisitModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.branchId,_that.memberId,_that.memberName,_that.entitlementId,_that.checkInMethod,_that.overrideReason,_that.checkedInAt,_that.checkedOutAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FacilityVisitModel implements FacilityVisitModel {
  const _FacilityVisitModel({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'branch_id') required this.branchId, @JsonKey(name: 'member_id') required this.memberId, @JsonKey(name: 'member_name') this.memberName, @JsonKey(name: 'entitlement_id') this.entitlementId, @JsonKey(name: 'check_in_method') required this.checkInMethod, @JsonKey(name: 'override_reason') this.overrideReason, @JsonKey(name: 'checked_in_at') required this.checkedInAt, @JsonKey(name: 'checked_out_at') this.checkedOutAt});
  factory _FacilityVisitModel.fromJson(Map<String, dynamic> json) => _$FacilityVisitModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'branch_id') final  String branchId;
@override@JsonKey(name: 'member_id') final  String memberId;
@override@JsonKey(name: 'member_name') final  String? memberName;
@override@JsonKey(name: 'entitlement_id') final  String? entitlementId;
@override@JsonKey(name: 'check_in_method') final  String checkInMethod;
@override@JsonKey(name: 'override_reason') final  String? overrideReason;
@override@JsonKey(name: 'checked_in_at') final  DateTime checkedInAt;
@override@JsonKey(name: 'checked_out_at') final  DateTime? checkedOutAt;

/// Create a copy of FacilityVisitModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FacilityVisitModelCopyWith<_FacilityVisitModel> get copyWith => __$FacilityVisitModelCopyWithImpl<_FacilityVisitModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FacilityVisitModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FacilityVisitModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.entitlementId, entitlementId) || other.entitlementId == entitlementId)&&(identical(other.checkInMethod, checkInMethod) || other.checkInMethod == checkInMethod)&&(identical(other.overrideReason, overrideReason) || other.overrideReason == overrideReason)&&(identical(other.checkedInAt, checkedInAt) || other.checkedInAt == checkedInAt)&&(identical(other.checkedOutAt, checkedOutAt) || other.checkedOutAt == checkedOutAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,branchId,memberId,memberName,entitlementId,checkInMethod,overrideReason,checkedInAt,checkedOutAt);
}

@override
String toString() {
    return 'FacilityVisitModel(id: $id, organizationId: $organizationId, branchId: $branchId, memberId: $memberId, memberName: $memberName, entitlementId: $entitlementId, checkInMethod: $checkInMethod, overrideReason: $overrideReason, checkedInAt: $checkedInAt, checkedOutAt: $checkedOutAt)';
}


}

/// @nodoc
abstract mixin class _$FacilityVisitModelCopyWith<$Res> implements $FacilityVisitModelCopyWith<$Res> {
  factory _$FacilityVisitModelCopyWith(_FacilityVisitModel value, $Res Function(_FacilityVisitModel) _then) = __$FacilityVisitModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'branch_id') String branchId,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'member_name') String? memberName,@JsonKey(name: 'entitlement_id') String? entitlementId,@JsonKey(name: 'check_in_method') String checkInMethod,@JsonKey(name: 'override_reason') String? overrideReason,@JsonKey(name: 'checked_in_at') DateTime checkedInAt,@JsonKey(name: 'checked_out_at') DateTime? checkedOutAt
});




}
/// @nodoc
class __$FacilityVisitModelCopyWithImpl<$Res>
    implements _$FacilityVisitModelCopyWith<$Res> {
  __$FacilityVisitModelCopyWithImpl(this._self, this._then);

  final _FacilityVisitModel _self;
  final $Res Function(_FacilityVisitModel) _then;

/// Create a copy of FacilityVisitModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? branchId = null,Object? memberId = null,Object? memberName = freezed,Object? entitlementId = freezed,Object? checkInMethod = null,Object? overrideReason = freezed,Object? checkedInAt = null,Object? checkedOutAt = freezed,}) {
  return _then(_FacilityVisitModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: freezed == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String?,entitlementId: freezed == entitlementId ? _self.entitlementId : entitlementId // ignore: cast_nullable_to_non_nullable
as String?,checkInMethod: null == checkInMethod ? _self.checkInMethod : checkInMethod // ignore: cast_nullable_to_non_nullable
as String,overrideReason: freezed == overrideReason ? _self.overrideReason : overrideReason // ignore: cast_nullable_to_non_nullable
as String?,checkedInAt: null == checkedInAt ? _self.checkedInAt : checkedInAt // ignore: cast_nullable_to_non_nullable
as DateTime,checkedOutAt: freezed == checkedOutAt ? _self.checkedOutAt : checkedOutAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$CheckInMemberLookup {

 String get id;@JsonKey(name: 'member_code') String get memberCode;@JsonKey(name: 'full_name') String get fullName;@JsonKey(name: 'home_branch_id') String get homeBranchId; String get status;
/// Create a copy of CheckInMemberLookup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckInMemberLookupCopyWith<CheckInMemberLookup> get copyWith => _$CheckInMemberLookupCopyWithImpl<CheckInMemberLookup>(this as CheckInMemberLookup, _$identity);

  /// Serializes this CheckInMemberLookup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CheckInMemberLookup;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckInMemberLookup&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.memberCode, _this.memberCode) || other.memberCode == _this.memberCode)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.homeBranchId, _this.homeBranchId) || other.homeBranchId == _this.homeBranchId)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CheckInMemberLookup;
  return Object.hash(runtimeType,_this.id,_this.memberCode,_this.fullName,_this.homeBranchId,_this.status);
}

@override
String toString() {
  final _this = this as CheckInMemberLookup;
  return 'CheckInMemberLookup(id: ${_this.id}, memberCode: ${_this.memberCode}, fullName: ${_this.fullName}, homeBranchId: ${_this.homeBranchId}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $CheckInMemberLookupCopyWith<$Res>  {
  factory $CheckInMemberLookupCopyWith(CheckInMemberLookup value, $Res Function(CheckInMemberLookup) _then) = _$CheckInMemberLookupCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'member_code') String memberCode,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'home_branch_id') String homeBranchId, String status
});




}
/// @nodoc
class _$CheckInMemberLookupCopyWithImpl<$Res>
    implements $CheckInMemberLookupCopyWith<$Res> {
  _$CheckInMemberLookupCopyWithImpl(this._self, this._then);

  final CheckInMemberLookup _self;
  final $Res Function(CheckInMemberLookup) _then;

/// Create a copy of CheckInMemberLookup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberCode = null,Object? fullName = null,Object? homeBranchId = null,Object? status = null,}) {
  return _then(CheckInMemberLookup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberCode: null == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,homeBranchId: null == homeBranchId ? _self.homeBranchId : homeBranchId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckInMemberLookup].
extension CheckInMemberLookupPatterns on CheckInMemberLookup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckInMemberLookup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckInMemberLookup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckInMemberLookup value)  $default,){
final _that = this;
switch (_that) {
case _CheckInMemberLookup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckInMemberLookup value)?  $default,){
final _that = this;
switch (_that) {
case _CheckInMemberLookup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'member_code')  String memberCode, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'home_branch_id')  String homeBranchId,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckInMemberLookup() when $default != null:
return $default(_that.id,_that.memberCode,_that.fullName,_that.homeBranchId,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'member_code')  String memberCode, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'home_branch_id')  String homeBranchId,  String status)  $default,) {final _that = this;
switch (_that) {
case _CheckInMemberLookup():
return $default(_that.id,_that.memberCode,_that.fullName,_that.homeBranchId,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'member_code')  String memberCode, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'home_branch_id')  String homeBranchId,  String status)?  $default,) {final _that = this;
switch (_that) {
case _CheckInMemberLookup() when $default != null:
return $default(_that.id,_that.memberCode,_that.fullName,_that.homeBranchId,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckInMemberLookup implements CheckInMemberLookup {
  const _CheckInMemberLookup({required this.id, @JsonKey(name: 'member_code') required this.memberCode, @JsonKey(name: 'full_name') required this.fullName, @JsonKey(name: 'home_branch_id') required this.homeBranchId, required this.status});
  factory _CheckInMemberLookup.fromJson(Map<String, dynamic> json) => _$CheckInMemberLookupFromJson(json);

@override final  String id;
@override@JsonKey(name: 'member_code') final  String memberCode;
@override@JsonKey(name: 'full_name') final  String fullName;
@override@JsonKey(name: 'home_branch_id') final  String homeBranchId;
@override final  String status;

/// Create a copy of CheckInMemberLookup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckInMemberLookupCopyWith<_CheckInMemberLookup> get copyWith => __$CheckInMemberLookupCopyWithImpl<_CheckInMemberLookup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckInMemberLookupToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckInMemberLookup&&(identical(other.id, id) || other.id == id)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.homeBranchId, homeBranchId) || other.homeBranchId == homeBranchId)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,memberCode,fullName,homeBranchId,status);
}

@override
String toString() {
    return 'CheckInMemberLookup(id: $id, memberCode: $memberCode, fullName: $fullName, homeBranchId: $homeBranchId, status: $status)';
}


}

/// @nodoc
abstract mixin class _$CheckInMemberLookupCopyWith<$Res> implements $CheckInMemberLookupCopyWith<$Res> {
  factory _$CheckInMemberLookupCopyWith(_CheckInMemberLookup value, $Res Function(_CheckInMemberLookup) _then) = __$CheckInMemberLookupCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'member_code') String memberCode,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'home_branch_id') String homeBranchId, String status
});




}
/// @nodoc
class __$CheckInMemberLookupCopyWithImpl<$Res>
    implements _$CheckInMemberLookupCopyWith<$Res> {
  __$CheckInMemberLookupCopyWithImpl(this._self, this._then);

  final _CheckInMemberLookup _self;
  final $Res Function(_CheckInMemberLookup) _then;

/// Create a copy of CheckInMemberLookup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberCode = null,Object? fullName = null,Object? homeBranchId = null,Object? status = null,}) {
  return _then(_CheckInMemberLookup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberCode: null == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,homeBranchId: null == homeBranchId ? _self.homeBranchId : homeBranchId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
