// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace_context.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkspaceContext {

@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'organization_name') String get organizationName;@JsonKey(name: 'branch_id') String? get branchId;@JsonKey(name: 'branch_name') String? get branchName;@JsonKey(name: 'role_code') String get roleCode;@JsonKey(name: 'role_display_name') String get roleDisplayName;@JsonKey(name: 'role_rank') int get roleRank;@JsonKey(name: 'member_id') String? get memberId; List<String> get permissions;
/// Create a copy of WorkspaceContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceContextCopyWith<WorkspaceContext> get copyWith => _$WorkspaceContextCopyWithImpl<WorkspaceContext>(this as WorkspaceContext, _$identity);

  /// Serializes this WorkspaceContext to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WorkspaceContext;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceContext&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.organizationName, _this.organizationName) || other.organizationName == _this.organizationName)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId)&&(identical(other.branchName, _this.branchName) || other.branchName == _this.branchName)&&(identical(other.roleCode, _this.roleCode) || other.roleCode == _this.roleCode)&&(identical(other.roleDisplayName, _this.roleDisplayName) || other.roleDisplayName == _this.roleDisplayName)&&(identical(other.roleRank, _this.roleRank) || other.roleRank == _this.roleRank)&&(identical(other.memberId, _this.memberId) || other.memberId == _this.memberId)&&const DeepCollectionEquality().equals(other.permissions, _this.permissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WorkspaceContext;
  return Object.hash(runtimeType,_this.organizationId,_this.organizationName,_this.branchId,_this.branchName,_this.roleCode,_this.roleDisplayName,_this.roleRank,_this.memberId,const DeepCollectionEquality().hash(_this.permissions));
}

@override
String toString() {
  final _this = this as WorkspaceContext;
  return 'WorkspaceContext(organizationId: ${_this.organizationId}, organizationName: ${_this.organizationName}, branchId: ${_this.branchId}, branchName: ${_this.branchName}, roleCode: ${_this.roleCode}, roleDisplayName: ${_this.roleDisplayName}, roleRank: ${_this.roleRank}, memberId: ${_this.memberId}, permissions: ${_this.permissions})';
}


}

/// @nodoc
abstract mixin class $WorkspaceContextCopyWith<$Res>  {
  factory $WorkspaceContextCopyWith(WorkspaceContext value, $Res Function(WorkspaceContext) _then) = _$WorkspaceContextCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'organization_name') String organizationName,@JsonKey(name: 'branch_id') String? branchId,@JsonKey(name: 'branch_name') String? branchName,@JsonKey(name: 'role_code') String roleCode,@JsonKey(name: 'role_display_name') String roleDisplayName,@JsonKey(name: 'role_rank') int roleRank,@JsonKey(name: 'member_id') String? memberId, List<String> permissions
});




}
/// @nodoc
class _$WorkspaceContextCopyWithImpl<$Res>
    implements $WorkspaceContextCopyWith<$Res> {
  _$WorkspaceContextCopyWithImpl(this._self, this._then);

  final WorkspaceContext _self;
  final $Res Function(WorkspaceContext) _then;

/// Create a copy of WorkspaceContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? organizationId = null,Object? organizationName = null,Object? branchId = freezed,Object? branchName = freezed,Object? roleCode = null,Object? roleDisplayName = null,Object? roleRank = null,Object? memberId = freezed,Object? permissions = null,}) {
  return _then(WorkspaceContext(
organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,organizationName: null == organizationName ? _self.organizationName : organizationName // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,roleCode: null == roleCode ? _self.roleCode : roleCode // ignore: cast_nullable_to_non_nullable
as String,roleDisplayName: null == roleDisplayName ? _self.roleDisplayName : roleDisplayName // ignore: cast_nullable_to_non_nullable
as String,roleRank: null == roleRank ? _self.roleRank : roleRank // ignore: cast_nullable_to_non_nullable
as int,memberId: freezed == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String?,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkspaceContext].
extension WorkspaceContextPatterns on WorkspaceContext {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkspaceContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkspaceContext() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkspaceContext value)  $default,){
final _that = this;
switch (_that) {
case _WorkspaceContext():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkspaceContext value)?  $default,){
final _that = this;
switch (_that) {
case _WorkspaceContext() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'organization_name')  String organizationName, @JsonKey(name: 'branch_id')  String? branchId, @JsonKey(name: 'branch_name')  String? branchName, @JsonKey(name: 'role_code')  String roleCode, @JsonKey(name: 'role_display_name')  String roleDisplayName, @JsonKey(name: 'role_rank')  int roleRank, @JsonKey(name: 'member_id')  String? memberId,  List<String> permissions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceContext() when $default != null:
return $default(_that.organizationId,_that.organizationName,_that.branchId,_that.branchName,_that.roleCode,_that.roleDisplayName,_that.roleRank,_that.memberId,_that.permissions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'organization_name')  String organizationName, @JsonKey(name: 'branch_id')  String? branchId, @JsonKey(name: 'branch_name')  String? branchName, @JsonKey(name: 'role_code')  String roleCode, @JsonKey(name: 'role_display_name')  String roleDisplayName, @JsonKey(name: 'role_rank')  int roleRank, @JsonKey(name: 'member_id')  String? memberId,  List<String> permissions)  $default,) {final _that = this;
switch (_that) {
case _WorkspaceContext():
return $default(_that.organizationId,_that.organizationName,_that.branchId,_that.branchName,_that.roleCode,_that.roleDisplayName,_that.roleRank,_that.memberId,_that.permissions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'organization_name')  String organizationName, @JsonKey(name: 'branch_id')  String? branchId, @JsonKey(name: 'branch_name')  String? branchName, @JsonKey(name: 'role_code')  String roleCode, @JsonKey(name: 'role_display_name')  String roleDisplayName, @JsonKey(name: 'role_rank')  int roleRank, @JsonKey(name: 'member_id')  String? memberId,  List<String> permissions)?  $default,) {final _that = this;
switch (_that) {
case _WorkspaceContext() when $default != null:
return $default(_that.organizationId,_that.organizationName,_that.branchId,_that.branchName,_that.roleCode,_that.roleDisplayName,_that.roleRank,_that.memberId,_that.permissions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkspaceContext extends WorkspaceContext {
  const _WorkspaceContext({@JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'organization_name') required this.organizationName, @JsonKey(name: 'branch_id') this.branchId, @JsonKey(name: 'branch_name') this.branchName, @JsonKey(name: 'role_code') required this.roleCode, @JsonKey(name: 'role_display_name') required this.roleDisplayName, @JsonKey(name: 'role_rank') required this.roleRank, @JsonKey(name: 'member_id') this.memberId,  List<String> permissions = const <String>[]}): _permissions = permissions,super._();
  factory _WorkspaceContext.fromJson(Map<String, dynamic> json) => _$WorkspaceContextFromJson(json);

@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'organization_name') final  String organizationName;
@override@JsonKey(name: 'branch_id') final  String? branchId;
@override@JsonKey(name: 'branch_name') final  String? branchName;
@override@JsonKey(name: 'role_code') final  String roleCode;
@override@JsonKey(name: 'role_display_name') final  String roleDisplayName;
@override@JsonKey(name: 'role_rank') final  int roleRank;
@override@JsonKey(name: 'member_id') final  String? memberId;
 final  List<String> _permissions;
@override@JsonKey() List<String> get permissions {
  if (_permissions is EqualUnmodifiableListView) return _permissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_permissions);
}


/// Create a copy of WorkspaceContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceContextCopyWith<_WorkspaceContext> get copyWith => __$WorkspaceContextCopyWithImpl<_WorkspaceContext>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkspaceContextToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceContext&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.organizationName, organizationName) || other.organizationName == organizationName)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.roleCode, roleCode) || other.roleCode == roleCode)&&(identical(other.roleDisplayName, roleDisplayName) || other.roleDisplayName == roleDisplayName)&&(identical(other.roleRank, roleRank) || other.roleRank == roleRank)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&const DeepCollectionEquality().equals(other.permissions, _permissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,organizationId,organizationName,branchId,branchName,roleCode,roleDisplayName,roleRank,memberId,const DeepCollectionEquality().hash(_permissions));
}

@override
String toString() {
    return 'WorkspaceContext(organizationId: $organizationId, organizationName: $organizationName, branchId: $branchId, branchName: $branchName, roleCode: $roleCode, roleDisplayName: $roleDisplayName, roleRank: $roleRank, memberId: $memberId, permissions: $permissions)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceContextCopyWith<$Res> implements $WorkspaceContextCopyWith<$Res> {
  factory _$WorkspaceContextCopyWith(_WorkspaceContext value, $Res Function(_WorkspaceContext) _then) = __$WorkspaceContextCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'organization_name') String organizationName,@JsonKey(name: 'branch_id') String? branchId,@JsonKey(name: 'branch_name') String? branchName,@JsonKey(name: 'role_code') String roleCode,@JsonKey(name: 'role_display_name') String roleDisplayName,@JsonKey(name: 'role_rank') int roleRank,@JsonKey(name: 'member_id') String? memberId, List<String> permissions
});




}
/// @nodoc
class __$WorkspaceContextCopyWithImpl<$Res>
    implements _$WorkspaceContextCopyWith<$Res> {
  __$WorkspaceContextCopyWithImpl(this._self, this._then);

  final _WorkspaceContext _self;
  final $Res Function(_WorkspaceContext) _then;

/// Create a copy of WorkspaceContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? organizationId = null,Object? organizationName = null,Object? branchId = freezed,Object? branchName = freezed,Object? roleCode = null,Object? roleDisplayName = null,Object? roleRank = null,Object? memberId = freezed,Object? permissions = null,}) {
  return _then(_WorkspaceContext(
organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,organizationName: null == organizationName ? _self.organizationName : organizationName // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,roleCode: null == roleCode ? _self.roleCode : roleCode // ignore: cast_nullable_to_non_nullable
as String,roleDisplayName: null == roleDisplayName ? _self.roleDisplayName : roleDisplayName // ignore: cast_nullable_to_non_nullable
as String,roleRank: null == roleRank ? _self.roleRank : roleRank // ignore: cast_nullable_to_non_nullable
as int,memberId: freezed == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String?,permissions: null == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
