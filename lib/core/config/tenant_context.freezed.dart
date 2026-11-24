// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tenant_context.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TenantContext {

 String get organizationId; String? get branchId;
/// Create a copy of TenantContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TenantContextCopyWith<TenantContext> get copyWith => _$TenantContextCopyWithImpl<TenantContext>(this as TenantContext, _$identity);

  /// Serializes this TenantContext to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TenantContext;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TenantContext&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TenantContext;
  return Object.hash(runtimeType,_this.organizationId,_this.branchId);
}

@override
String toString() {
  final _this = this as TenantContext;
  return 'TenantContext(organizationId: ${_this.organizationId}, branchId: ${_this.branchId})';
}


}

/// @nodoc
abstract mixin class $TenantContextCopyWith<$Res>  {
  factory $TenantContextCopyWith(TenantContext value, $Res Function(TenantContext) _then) = _$TenantContextCopyWithImpl;
@useResult
$Res call({
 String organizationId, String? branchId
});




}
/// @nodoc
class _$TenantContextCopyWithImpl<$Res>
    implements $TenantContextCopyWith<$Res> {
  _$TenantContextCopyWithImpl(this._self, this._then);

  final TenantContext _self;
  final $Res Function(TenantContext) _then;

/// Create a copy of TenantContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? organizationId = null,Object? branchId = freezed,}) {
  return _then(TenantContext(
organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TenantContext].
extension TenantContextPatterns on TenantContext {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TenantContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TenantContext() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TenantContext value)  $default,){
final _that = this;
switch (_that) {
case _TenantContext():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TenantContext value)?  $default,){
final _that = this;
switch (_that) {
case _TenantContext() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String organizationId,  String? branchId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TenantContext() when $default != null:
return $default(_that.organizationId,_that.branchId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String organizationId,  String? branchId)  $default,) {final _that = this;
switch (_that) {
case _TenantContext():
return $default(_that.organizationId,_that.branchId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String organizationId,  String? branchId)?  $default,) {final _that = this;
switch (_that) {
case _TenantContext() when $default != null:
return $default(_that.organizationId,_that.branchId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TenantContext implements TenantContext {
  const _TenantContext({required this.organizationId, this.branchId});
  factory _TenantContext.fromJson(Map<String, dynamic> json) => _$TenantContextFromJson(json);

@override final  String organizationId;
@override final  String? branchId;

/// Create a copy of TenantContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TenantContextCopyWith<_TenantContext> get copyWith => __$TenantContextCopyWithImpl<_TenantContext>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TenantContextToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TenantContext&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.branchId, branchId) || other.branchId == branchId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,organizationId,branchId);
}

@override
String toString() {
    return 'TenantContext(organizationId: $organizationId, branchId: $branchId)';
}


}

/// @nodoc
abstract mixin class _$TenantContextCopyWith<$Res> implements $TenantContextCopyWith<$Res> {
  factory _$TenantContextCopyWith(_TenantContext value, $Res Function(_TenantContext) _then) = __$TenantContextCopyWithImpl;
@override @useResult
$Res call({
 String organizationId, String? branchId
});




}
/// @nodoc
class __$TenantContextCopyWithImpl<$Res>
    implements _$TenantContextCopyWith<$Res> {
  __$TenantContextCopyWithImpl(this._self, this._then);

  final _TenantContext _self;
  final $Res Function(_TenantContext) _then;

/// Create a copy of TenantContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? organizationId = null,Object? branchId = freezed,}) {
  return _then(_TenantContext(
organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
