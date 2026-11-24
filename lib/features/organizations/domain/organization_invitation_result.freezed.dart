// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization_invitation_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OrganizationInvitationResult {

 String get invitationId; String get token; String get invitedEmail; String get roleCode; String? get branchId;
/// Create a copy of OrganizationInvitationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganizationInvitationResultCopyWith<OrganizationInvitationResult> get copyWith => _$OrganizationInvitationResultCopyWithImpl<OrganizationInvitationResult>(this as OrganizationInvitationResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OrganizationInvitationResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrganizationInvitationResult&&(identical(other.invitationId, _this.invitationId) || other.invitationId == _this.invitationId)&&(identical(other.token, _this.token) || other.token == _this.token)&&(identical(other.invitedEmail, _this.invitedEmail) || other.invitedEmail == _this.invitedEmail)&&(identical(other.roleCode, _this.roleCode) || other.roleCode == _this.roleCode)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId));
}


@override
int get hashCode {
  final _this = this as OrganizationInvitationResult;
  return Object.hash(runtimeType,_this.invitationId,_this.token,_this.invitedEmail,_this.roleCode,_this.branchId);
}

@override
String toString() {
  final _this = this as OrganizationInvitationResult;
  return 'OrganizationInvitationResult(invitationId: ${_this.invitationId}, token: ${_this.token}, invitedEmail: ${_this.invitedEmail}, roleCode: ${_this.roleCode}, branchId: ${_this.branchId})';
}


}

/// @nodoc
abstract mixin class $OrganizationInvitationResultCopyWith<$Res>  {
  factory $OrganizationInvitationResultCopyWith(OrganizationInvitationResult value, $Res Function(OrganizationInvitationResult) _then) = _$OrganizationInvitationResultCopyWithImpl;
@useResult
$Res call({
 String invitationId, String token, String invitedEmail, String roleCode, String? branchId
});




}
/// @nodoc
class _$OrganizationInvitationResultCopyWithImpl<$Res>
    implements $OrganizationInvitationResultCopyWith<$Res> {
  _$OrganizationInvitationResultCopyWithImpl(this._self, this._then);

  final OrganizationInvitationResult _self;
  final $Res Function(OrganizationInvitationResult) _then;

/// Create a copy of OrganizationInvitationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? invitationId = null,Object? token = null,Object? invitedEmail = null,Object? roleCode = null,Object? branchId = freezed,}) {
  return _then(OrganizationInvitationResult(
invitationId: null == invitationId ? _self.invitationId : invitationId // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,invitedEmail: null == invitedEmail ? _self.invitedEmail : invitedEmail // ignore: cast_nullable_to_non_nullable
as String,roleCode: null == roleCode ? _self.roleCode : roleCode // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrganizationInvitationResult].
extension OrganizationInvitationResultPatterns on OrganizationInvitationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrganizationInvitationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrganizationInvitationResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrganizationInvitationResult value)  $default,){
final _that = this;
switch (_that) {
case _OrganizationInvitationResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrganizationInvitationResult value)?  $default,){
final _that = this;
switch (_that) {
case _OrganizationInvitationResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String invitationId,  String token,  String invitedEmail,  String roleCode,  String? branchId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrganizationInvitationResult() when $default != null:
return $default(_that.invitationId,_that.token,_that.invitedEmail,_that.roleCode,_that.branchId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String invitationId,  String token,  String invitedEmail,  String roleCode,  String? branchId)  $default,) {final _that = this;
switch (_that) {
case _OrganizationInvitationResult():
return $default(_that.invitationId,_that.token,_that.invitedEmail,_that.roleCode,_that.branchId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String invitationId,  String token,  String invitedEmail,  String roleCode,  String? branchId)?  $default,) {final _that = this;
switch (_that) {
case _OrganizationInvitationResult() when $default != null:
return $default(_that.invitationId,_that.token,_that.invitedEmail,_that.roleCode,_that.branchId);case _:
  return null;

}
}

}

/// @nodoc


class _OrganizationInvitationResult implements OrganizationInvitationResult {
  const _OrganizationInvitationResult({required this.invitationId, required this.token, required this.invitedEmail, required this.roleCode, this.branchId});
  

@override final  String invitationId;
@override final  String token;
@override final  String invitedEmail;
@override final  String roleCode;
@override final  String? branchId;

/// Create a copy of OrganizationInvitationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrganizationInvitationResultCopyWith<_OrganizationInvitationResult> get copyWith => __$OrganizationInvitationResultCopyWithImpl<_OrganizationInvitationResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrganizationInvitationResult&&(identical(other.invitationId, invitationId) || other.invitationId == invitationId)&&(identical(other.token, token) || other.token == token)&&(identical(other.invitedEmail, invitedEmail) || other.invitedEmail == invitedEmail)&&(identical(other.roleCode, roleCode) || other.roleCode == roleCode)&&(identical(other.branchId, branchId) || other.branchId == branchId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,invitationId,token,invitedEmail,roleCode,branchId);
}

@override
String toString() {
    return 'OrganizationInvitationResult(invitationId: $invitationId, token: $token, invitedEmail: $invitedEmail, roleCode: $roleCode, branchId: $branchId)';
}


}

/// @nodoc
abstract mixin class _$OrganizationInvitationResultCopyWith<$Res> implements $OrganizationInvitationResultCopyWith<$Res> {
  factory _$OrganizationInvitationResultCopyWith(_OrganizationInvitationResult value, $Res Function(_OrganizationInvitationResult) _then) = __$OrganizationInvitationResultCopyWithImpl;
@override @useResult
$Res call({
 String invitationId, String token, String invitedEmail, String roleCode, String? branchId
});




}
/// @nodoc
class __$OrganizationInvitationResultCopyWithImpl<$Res>
    implements _$OrganizationInvitationResultCopyWith<$Res> {
  __$OrganizationInvitationResultCopyWithImpl(this._self, this._then);

  final _OrganizationInvitationResult _self;
  final $Res Function(_OrganizationInvitationResult) _then;

/// Create a copy of OrganizationInvitationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? invitationId = null,Object? token = null,Object? invitedEmail = null,Object? roleCode = null,Object? branchId = freezed,}) {
  return _then(_OrganizationInvitationResult(
invitationId: null == invitationId ? _self.invitationId : invitationId // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,invitedEmail: null == invitedEmail ? _self.invitedEmail : invitedEmail // ignore: cast_nullable_to_non_nullable
as String,roleCode: null == roleCode ? _self.roleCode : roleCode // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
