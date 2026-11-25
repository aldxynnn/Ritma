// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff_management_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StaffAssignmentModel {

@JsonKey(name: 'assignment_id') String get assignmentId;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'full_name') String get fullName; String get email;@JsonKey(name: 'role_code') String get roleCode;@JsonKey(name: 'role_display_name') String get roleDisplayName;@JsonKey(name: 'role_rank') int get roleRank;@JsonKey(name: 'branch_id') String? get branchId;@JsonKey(name: 'branch_name') String? get branchName; String get status;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'revoked_at') DateTime? get revokedAt;
/// Create a copy of StaffAssignmentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffAssignmentModelCopyWith<StaffAssignmentModel> get copyWith => _$StaffAssignmentModelCopyWithImpl<StaffAssignmentModel>(this as StaffAssignmentModel, _$identity);

  /// Serializes this StaffAssignmentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StaffAssignmentModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffAssignmentModel&&(identical(other.assignmentId, _this.assignmentId) || other.assignmentId == _this.assignmentId)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.roleCode, _this.roleCode) || other.roleCode == _this.roleCode)&&(identical(other.roleDisplayName, _this.roleDisplayName) || other.roleDisplayName == _this.roleDisplayName)&&(identical(other.roleRank, _this.roleRank) || other.roleRank == _this.roleRank)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId)&&(identical(other.branchName, _this.branchName) || other.branchName == _this.branchName)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.revokedAt, _this.revokedAt) || other.revokedAt == _this.revokedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StaffAssignmentModel;
  return Object.hash(runtimeType,_this.assignmentId,_this.userId,_this.fullName,_this.email,_this.roleCode,_this.roleDisplayName,_this.roleRank,_this.branchId,_this.branchName,_this.status,_this.createdAt,_this.revokedAt);
}

@override
String toString() {
  final _this = this as StaffAssignmentModel;
  return 'StaffAssignmentModel(assignmentId: ${_this.assignmentId}, userId: ${_this.userId}, fullName: ${_this.fullName}, email: ${_this.email}, roleCode: ${_this.roleCode}, roleDisplayName: ${_this.roleDisplayName}, roleRank: ${_this.roleRank}, branchId: ${_this.branchId}, branchName: ${_this.branchName}, status: ${_this.status}, createdAt: ${_this.createdAt}, revokedAt: ${_this.revokedAt})';
}


}

/// @nodoc
abstract mixin class $StaffAssignmentModelCopyWith<$Res>  {
  factory $StaffAssignmentModelCopyWith(StaffAssignmentModel value, $Res Function(StaffAssignmentModel) _then) = _$StaffAssignmentModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'assignment_id') String assignmentId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'full_name') String fullName, String email,@JsonKey(name: 'role_code') String roleCode,@JsonKey(name: 'role_display_name') String roleDisplayName,@JsonKey(name: 'role_rank') int roleRank,@JsonKey(name: 'branch_id') String? branchId,@JsonKey(name: 'branch_name') String? branchName, String status,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'revoked_at') DateTime? revokedAt
});




}
/// @nodoc
class _$StaffAssignmentModelCopyWithImpl<$Res>
    implements $StaffAssignmentModelCopyWith<$Res> {
  _$StaffAssignmentModelCopyWithImpl(this._self, this._then);

  final StaffAssignmentModel _self;
  final $Res Function(StaffAssignmentModel) _then;

/// Create a copy of StaffAssignmentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? assignmentId = null,Object? userId = null,Object? fullName = null,Object? email = null,Object? roleCode = null,Object? roleDisplayName = null,Object? roleRank = null,Object? branchId = freezed,Object? branchName = freezed,Object? status = null,Object? createdAt = null,Object? revokedAt = freezed,}) {
  return _then(StaffAssignmentModel(
assignmentId: null == assignmentId ? _self.assignmentId : assignmentId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,roleCode: null == roleCode ? _self.roleCode : roleCode // ignore: cast_nullable_to_non_nullable
as String,roleDisplayName: null == roleDisplayName ? _self.roleDisplayName : roleDisplayName // ignore: cast_nullable_to_non_nullable
as String,roleRank: null == roleRank ? _self.roleRank : roleRank // ignore: cast_nullable_to_non_nullable
as int,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffAssignmentModel].
extension StaffAssignmentModelPatterns on StaffAssignmentModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffAssignmentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffAssignmentModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffAssignmentModel value)  $default,){
final _that = this;
switch (_that) {
case _StaffAssignmentModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffAssignmentModel value)?  $default,){
final _that = this;
switch (_that) {
case _StaffAssignmentModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'assignment_id')  String assignmentId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'full_name')  String fullName,  String email, @JsonKey(name: 'role_code')  String roleCode, @JsonKey(name: 'role_display_name')  String roleDisplayName, @JsonKey(name: 'role_rank')  int roleRank, @JsonKey(name: 'branch_id')  String? branchId, @JsonKey(name: 'branch_name')  String? branchName,  String status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'revoked_at')  DateTime? revokedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffAssignmentModel() when $default != null:
return $default(_that.assignmentId,_that.userId,_that.fullName,_that.email,_that.roleCode,_that.roleDisplayName,_that.roleRank,_that.branchId,_that.branchName,_that.status,_that.createdAt,_that.revokedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'assignment_id')  String assignmentId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'full_name')  String fullName,  String email, @JsonKey(name: 'role_code')  String roleCode, @JsonKey(name: 'role_display_name')  String roleDisplayName, @JsonKey(name: 'role_rank')  int roleRank, @JsonKey(name: 'branch_id')  String? branchId, @JsonKey(name: 'branch_name')  String? branchName,  String status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'revoked_at')  DateTime? revokedAt)  $default,) {final _that = this;
switch (_that) {
case _StaffAssignmentModel():
return $default(_that.assignmentId,_that.userId,_that.fullName,_that.email,_that.roleCode,_that.roleDisplayName,_that.roleRank,_that.branchId,_that.branchName,_that.status,_that.createdAt,_that.revokedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'assignment_id')  String assignmentId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'full_name')  String fullName,  String email, @JsonKey(name: 'role_code')  String roleCode, @JsonKey(name: 'role_display_name')  String roleDisplayName, @JsonKey(name: 'role_rank')  int roleRank, @JsonKey(name: 'branch_id')  String? branchId, @JsonKey(name: 'branch_name')  String? branchName,  String status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'revoked_at')  DateTime? revokedAt)?  $default,) {final _that = this;
switch (_that) {
case _StaffAssignmentModel() when $default != null:
return $default(_that.assignmentId,_that.userId,_that.fullName,_that.email,_that.roleCode,_that.roleDisplayName,_that.roleRank,_that.branchId,_that.branchName,_that.status,_that.createdAt,_that.revokedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StaffAssignmentModel implements StaffAssignmentModel {
  const _StaffAssignmentModel({@JsonKey(name: 'assignment_id') required this.assignmentId, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'full_name') this.fullName = '', this.email = '', @JsonKey(name: 'role_code') required this.roleCode, @JsonKey(name: 'role_display_name') this.roleDisplayName = '', @JsonKey(name: 'role_rank') this.roleRank = 0, @JsonKey(name: 'branch_id') this.branchId, @JsonKey(name: 'branch_name') this.branchName, this.status = 'active', @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'revoked_at') this.revokedAt});
  factory _StaffAssignmentModel.fromJson(Map<String, dynamic> json) => _$StaffAssignmentModelFromJson(json);

@override@JsonKey(name: 'assignment_id') final  String assignmentId;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'full_name') final  String fullName;
@override@JsonKey() final  String email;
@override@JsonKey(name: 'role_code') final  String roleCode;
@override@JsonKey(name: 'role_display_name') final  String roleDisplayName;
@override@JsonKey(name: 'role_rank') final  int roleRank;
@override@JsonKey(name: 'branch_id') final  String? branchId;
@override@JsonKey(name: 'branch_name') final  String? branchName;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'revoked_at') final  DateTime? revokedAt;

/// Create a copy of StaffAssignmentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffAssignmentModelCopyWith<_StaffAssignmentModel> get copyWith => __$StaffAssignmentModelCopyWithImpl<_StaffAssignmentModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StaffAssignmentModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffAssignmentModel&&(identical(other.assignmentId, assignmentId) || other.assignmentId == assignmentId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.roleCode, roleCode) || other.roleCode == roleCode)&&(identical(other.roleDisplayName, roleDisplayName) || other.roleDisplayName == roleDisplayName)&&(identical(other.roleRank, roleRank) || other.roleRank == roleRank)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,assignmentId,userId,fullName,email,roleCode,roleDisplayName,roleRank,branchId,branchName,status,createdAt,revokedAt);
}

@override
String toString() {
    return 'StaffAssignmentModel(assignmentId: $assignmentId, userId: $userId, fullName: $fullName, email: $email, roleCode: $roleCode, roleDisplayName: $roleDisplayName, roleRank: $roleRank, branchId: $branchId, branchName: $branchName, status: $status, createdAt: $createdAt, revokedAt: $revokedAt)';
}


}

/// @nodoc
abstract mixin class _$StaffAssignmentModelCopyWith<$Res> implements $StaffAssignmentModelCopyWith<$Res> {
  factory _$StaffAssignmentModelCopyWith(_StaffAssignmentModel value, $Res Function(_StaffAssignmentModel) _then) = __$StaffAssignmentModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'assignment_id') String assignmentId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'full_name') String fullName, String email,@JsonKey(name: 'role_code') String roleCode,@JsonKey(name: 'role_display_name') String roleDisplayName,@JsonKey(name: 'role_rank') int roleRank,@JsonKey(name: 'branch_id') String? branchId,@JsonKey(name: 'branch_name') String? branchName, String status,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'revoked_at') DateTime? revokedAt
});




}
/// @nodoc
class __$StaffAssignmentModelCopyWithImpl<$Res>
    implements _$StaffAssignmentModelCopyWith<$Res> {
  __$StaffAssignmentModelCopyWithImpl(this._self, this._then);

  final _StaffAssignmentModel _self;
  final $Res Function(_StaffAssignmentModel) _then;

/// Create a copy of StaffAssignmentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? assignmentId = null,Object? userId = null,Object? fullName = null,Object? email = null,Object? roleCode = null,Object? roleDisplayName = null,Object? roleRank = null,Object? branchId = freezed,Object? branchName = freezed,Object? status = null,Object? createdAt = null,Object? revokedAt = freezed,}) {
  return _then(_StaffAssignmentModel(
assignmentId: null == assignmentId ? _self.assignmentId : assignmentId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,roleCode: null == roleCode ? _self.roleCode : roleCode // ignore: cast_nullable_to_non_nullable
as String,roleDisplayName: null == roleDisplayName ? _self.roleDisplayName : roleDisplayName // ignore: cast_nullable_to_non_nullable
as String,roleRank: null == roleRank ? _self.roleRank : roleRank // ignore: cast_nullable_to_non_nullable
as int,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$OrganizationInvitationModel {

 String get id;@JsonKey(name: 'invited_email') String get invitedEmail;@JsonKey(name: 'role_code') String get roleCode;@JsonKey(name: 'role_display_name') String get roleDisplayName;@JsonKey(name: 'role_rank') int get roleRank;@JsonKey(name: 'branch_id') String? get branchId;@JsonKey(name: 'branch_name') String? get branchName; String get status;@JsonKey(name: 'expires_at') DateTime get expiresAt;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of OrganizationInvitationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganizationInvitationModelCopyWith<OrganizationInvitationModel> get copyWith => _$OrganizationInvitationModelCopyWithImpl<OrganizationInvitationModel>(this as OrganizationInvitationModel, _$identity);

  /// Serializes this OrganizationInvitationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OrganizationInvitationModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrganizationInvitationModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.invitedEmail, _this.invitedEmail) || other.invitedEmail == _this.invitedEmail)&&(identical(other.roleCode, _this.roleCode) || other.roleCode == _this.roleCode)&&(identical(other.roleDisplayName, _this.roleDisplayName) || other.roleDisplayName == _this.roleDisplayName)&&(identical(other.roleRank, _this.roleRank) || other.roleRank == _this.roleRank)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId)&&(identical(other.branchName, _this.branchName) || other.branchName == _this.branchName)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OrganizationInvitationModel;
  return Object.hash(runtimeType,_this.id,_this.invitedEmail,_this.roleCode,_this.roleDisplayName,_this.roleRank,_this.branchId,_this.branchName,_this.status,_this.expiresAt,_this.createdAt);
}

@override
String toString() {
  final _this = this as OrganizationInvitationModel;
  return 'OrganizationInvitationModel(id: ${_this.id}, invitedEmail: ${_this.invitedEmail}, roleCode: ${_this.roleCode}, roleDisplayName: ${_this.roleDisplayName}, roleRank: ${_this.roleRank}, branchId: ${_this.branchId}, branchName: ${_this.branchName}, status: ${_this.status}, expiresAt: ${_this.expiresAt}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $OrganizationInvitationModelCopyWith<$Res>  {
  factory $OrganizationInvitationModelCopyWith(OrganizationInvitationModel value, $Res Function(OrganizationInvitationModel) _then) = _$OrganizationInvitationModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'invited_email') String invitedEmail,@JsonKey(name: 'role_code') String roleCode,@JsonKey(name: 'role_display_name') String roleDisplayName,@JsonKey(name: 'role_rank') int roleRank,@JsonKey(name: 'branch_id') String? branchId,@JsonKey(name: 'branch_name') String? branchName, String status,@JsonKey(name: 'expires_at') DateTime expiresAt,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$OrganizationInvitationModelCopyWithImpl<$Res>
    implements $OrganizationInvitationModelCopyWith<$Res> {
  _$OrganizationInvitationModelCopyWithImpl(this._self, this._then);

  final OrganizationInvitationModel _self;
  final $Res Function(OrganizationInvitationModel) _then;

/// Create a copy of OrganizationInvitationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? invitedEmail = null,Object? roleCode = null,Object? roleDisplayName = null,Object? roleRank = null,Object? branchId = freezed,Object? branchName = freezed,Object? status = null,Object? expiresAt = null,Object? createdAt = null,}) {
  return _then(OrganizationInvitationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,invitedEmail: null == invitedEmail ? _self.invitedEmail : invitedEmail // ignore: cast_nullable_to_non_nullable
as String,roleCode: null == roleCode ? _self.roleCode : roleCode // ignore: cast_nullable_to_non_nullable
as String,roleDisplayName: null == roleDisplayName ? _self.roleDisplayName : roleDisplayName // ignore: cast_nullable_to_non_nullable
as String,roleRank: null == roleRank ? _self.roleRank : roleRank // ignore: cast_nullable_to_non_nullable
as int,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [OrganizationInvitationModel].
extension OrganizationInvitationModelPatterns on OrganizationInvitationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrganizationInvitationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrganizationInvitationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrganizationInvitationModel value)  $default,){
final _that = this;
switch (_that) {
case _OrganizationInvitationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrganizationInvitationModel value)?  $default,){
final _that = this;
switch (_that) {
case _OrganizationInvitationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'invited_email')  String invitedEmail, @JsonKey(name: 'role_code')  String roleCode, @JsonKey(name: 'role_display_name')  String roleDisplayName, @JsonKey(name: 'role_rank')  int roleRank, @JsonKey(name: 'branch_id')  String? branchId, @JsonKey(name: 'branch_name')  String? branchName,  String status, @JsonKey(name: 'expires_at')  DateTime expiresAt, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrganizationInvitationModel() when $default != null:
return $default(_that.id,_that.invitedEmail,_that.roleCode,_that.roleDisplayName,_that.roleRank,_that.branchId,_that.branchName,_that.status,_that.expiresAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'invited_email')  String invitedEmail, @JsonKey(name: 'role_code')  String roleCode, @JsonKey(name: 'role_display_name')  String roleDisplayName, @JsonKey(name: 'role_rank')  int roleRank, @JsonKey(name: 'branch_id')  String? branchId, @JsonKey(name: 'branch_name')  String? branchName,  String status, @JsonKey(name: 'expires_at')  DateTime expiresAt, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _OrganizationInvitationModel():
return $default(_that.id,_that.invitedEmail,_that.roleCode,_that.roleDisplayName,_that.roleRank,_that.branchId,_that.branchName,_that.status,_that.expiresAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'invited_email')  String invitedEmail, @JsonKey(name: 'role_code')  String roleCode, @JsonKey(name: 'role_display_name')  String roleDisplayName, @JsonKey(name: 'role_rank')  int roleRank, @JsonKey(name: 'branch_id')  String? branchId, @JsonKey(name: 'branch_name')  String? branchName,  String status, @JsonKey(name: 'expires_at')  DateTime expiresAt, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _OrganizationInvitationModel() when $default != null:
return $default(_that.id,_that.invitedEmail,_that.roleCode,_that.roleDisplayName,_that.roleRank,_that.branchId,_that.branchName,_that.status,_that.expiresAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrganizationInvitationModel implements OrganizationInvitationModel {
  const _OrganizationInvitationModel({required this.id, @JsonKey(name: 'invited_email') required this.invitedEmail, @JsonKey(name: 'role_code') required this.roleCode, @JsonKey(name: 'role_display_name') this.roleDisplayName = '', @JsonKey(name: 'role_rank') this.roleRank = 0, @JsonKey(name: 'branch_id') this.branchId, @JsonKey(name: 'branch_name') this.branchName, this.status = 'pending', @JsonKey(name: 'expires_at') required this.expiresAt, @JsonKey(name: 'created_at') required this.createdAt});
  factory _OrganizationInvitationModel.fromJson(Map<String, dynamic> json) => _$OrganizationInvitationModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'invited_email') final  String invitedEmail;
@override@JsonKey(name: 'role_code') final  String roleCode;
@override@JsonKey(name: 'role_display_name') final  String roleDisplayName;
@override@JsonKey(name: 'role_rank') final  int roleRank;
@override@JsonKey(name: 'branch_id') final  String? branchId;
@override@JsonKey(name: 'branch_name') final  String? branchName;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'expires_at') final  DateTime expiresAt;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of OrganizationInvitationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrganizationInvitationModelCopyWith<_OrganizationInvitationModel> get copyWith => __$OrganizationInvitationModelCopyWithImpl<_OrganizationInvitationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrganizationInvitationModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrganizationInvitationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.invitedEmail, invitedEmail) || other.invitedEmail == invitedEmail)&&(identical(other.roleCode, roleCode) || other.roleCode == roleCode)&&(identical(other.roleDisplayName, roleDisplayName) || other.roleDisplayName == roleDisplayName)&&(identical(other.roleRank, roleRank) || other.roleRank == roleRank)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,invitedEmail,roleCode,roleDisplayName,roleRank,branchId,branchName,status,expiresAt,createdAt);
}

@override
String toString() {
    return 'OrganizationInvitationModel(id: $id, invitedEmail: $invitedEmail, roleCode: $roleCode, roleDisplayName: $roleDisplayName, roleRank: $roleRank, branchId: $branchId, branchName: $branchName, status: $status, expiresAt: $expiresAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$OrganizationInvitationModelCopyWith<$Res> implements $OrganizationInvitationModelCopyWith<$Res> {
  factory _$OrganizationInvitationModelCopyWith(_OrganizationInvitationModel value, $Res Function(_OrganizationInvitationModel) _then) = __$OrganizationInvitationModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'invited_email') String invitedEmail,@JsonKey(name: 'role_code') String roleCode,@JsonKey(name: 'role_display_name') String roleDisplayName,@JsonKey(name: 'role_rank') int roleRank,@JsonKey(name: 'branch_id') String? branchId,@JsonKey(name: 'branch_name') String? branchName, String status,@JsonKey(name: 'expires_at') DateTime expiresAt,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$OrganizationInvitationModelCopyWithImpl<$Res>
    implements _$OrganizationInvitationModelCopyWith<$Res> {
  __$OrganizationInvitationModelCopyWithImpl(this._self, this._then);

  final _OrganizationInvitationModel _self;
  final $Res Function(_OrganizationInvitationModel) _then;

/// Create a copy of OrganizationInvitationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? invitedEmail = null,Object? roleCode = null,Object? roleDisplayName = null,Object? roleRank = null,Object? branchId = freezed,Object? branchName = freezed,Object? status = null,Object? expiresAt = null,Object? createdAt = null,}) {
  return _then(_OrganizationInvitationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,invitedEmail: null == invitedEmail ? _self.invitedEmail : invitedEmail // ignore: cast_nullable_to_non_nullable
as String,roleCode: null == roleCode ? _self.roleCode : roleCode // ignore: cast_nullable_to_non_nullable
as String,roleDisplayName: null == roleDisplayName ? _self.roleDisplayName : roleDisplayName // ignore: cast_nullable_to_non_nullable
as String,roleRank: null == roleRank ? _self.roleRank : roleRank // ignore: cast_nullable_to_non_nullable
as int,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
