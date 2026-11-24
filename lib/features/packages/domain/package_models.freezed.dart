// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'package_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClassTypeModel {

 String get id;@JsonKey(name: 'organization_id') String get organizationId; String get name;@JsonKey(name: 'color_token') String get colorToken;@JsonKey(name: 'is_active') bool get isActive;
/// Create a copy of ClassTypeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClassTypeModelCopyWith<ClassTypeModel> get copyWith => _$ClassTypeModelCopyWithImpl<ClassTypeModel>(this as ClassTypeModel, _$identity);

  /// Serializes this ClassTypeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ClassTypeModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClassTypeModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.colorToken, _this.colorToken) || other.colorToken == _this.colorToken)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ClassTypeModel;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.name,_this.colorToken,_this.isActive);
}

@override
String toString() {
  final _this = this as ClassTypeModel;
  return 'ClassTypeModel(id: ${_this.id}, organizationId: ${_this.organizationId}, name: ${_this.name}, colorToken: ${_this.colorToken}, isActive: ${_this.isActive})';
}


}

/// @nodoc
abstract mixin class $ClassTypeModelCopyWith<$Res>  {
  factory $ClassTypeModelCopyWith(ClassTypeModel value, $Res Function(ClassTypeModel) _then) = _$ClassTypeModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId, String name,@JsonKey(name: 'color_token') String colorToken,@JsonKey(name: 'is_active') bool isActive
});




}
/// @nodoc
class _$ClassTypeModelCopyWithImpl<$Res>
    implements $ClassTypeModelCopyWith<$Res> {
  _$ClassTypeModelCopyWithImpl(this._self, this._then);

  final ClassTypeModel _self;
  final $Res Function(ClassTypeModel) _then;

/// Create a copy of ClassTypeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? colorToken = null,Object? isActive = null,}) {
  return _then(ClassTypeModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,colorToken: null == colorToken ? _self.colorToken : colorToken // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ClassTypeModel].
extension ClassTypeModelPatterns on ClassTypeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClassTypeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClassTypeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClassTypeModel value)  $default,){
final _that = this;
switch (_that) {
case _ClassTypeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClassTypeModel value)?  $default,){
final _that = this;
switch (_that) {
case _ClassTypeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId,  String name, @JsonKey(name: 'color_token')  String colorToken, @JsonKey(name: 'is_active')  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClassTypeModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.colorToken,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId,  String name, @JsonKey(name: 'color_token')  String colorToken, @JsonKey(name: 'is_active')  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _ClassTypeModel():
return $default(_that.id,_that.organizationId,_that.name,_that.colorToken,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId,  String name, @JsonKey(name: 'color_token')  String colorToken, @JsonKey(name: 'is_active')  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _ClassTypeModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.colorToken,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClassTypeModel implements ClassTypeModel {
  const _ClassTypeModel({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, required this.name, @JsonKey(name: 'color_token') this.colorToken = 'sage', @JsonKey(name: 'is_active') this.isActive = true});
  factory _ClassTypeModel.fromJson(Map<String, dynamic> json) => _$ClassTypeModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override final  String name;
@override@JsonKey(name: 'color_token') final  String colorToken;
@override@JsonKey(name: 'is_active') final  bool isActive;

/// Create a copy of ClassTypeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClassTypeModelCopyWith<_ClassTypeModel> get copyWith => __$ClassTypeModelCopyWithImpl<_ClassTypeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClassTypeModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClassTypeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.colorToken, colorToken) || other.colorToken == colorToken)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,name,colorToken,isActive);
}

@override
String toString() {
    return 'ClassTypeModel(id: $id, organizationId: $organizationId, name: $name, colorToken: $colorToken, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$ClassTypeModelCopyWith<$Res> implements $ClassTypeModelCopyWith<$Res> {
  factory _$ClassTypeModelCopyWith(_ClassTypeModel value, $Res Function(_ClassTypeModel) _then) = __$ClassTypeModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId, String name,@JsonKey(name: 'color_token') String colorToken,@JsonKey(name: 'is_active') bool isActive
});




}
/// @nodoc
class __$ClassTypeModelCopyWithImpl<$Res>
    implements _$ClassTypeModelCopyWith<$Res> {
  __$ClassTypeModelCopyWithImpl(this._self, this._then);

  final _ClassTypeModel _self;
  final $Res Function(_ClassTypeModel) _then;

/// Create a copy of ClassTypeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? colorToken = null,Object? isActive = null,}) {
  return _then(_ClassTypeModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,colorToken: null == colorToken ? _self.colorToken : colorToken // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PackageEntitlementRuleModel {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'package_id') String get packageId;@JsonKey(name: 'entitlement_kind') EntitlementKind get entitlementKind;@JsonKey(name: 'duration_days') int? get durationDays;@JsonKey(name: 'credit_quantity') int? get creditQuantity;@JsonKey(name: 'branch_access_scope') BranchAccessScope get branchAccessScope;@JsonKey(name: 'class_scope') ClassScope get classScope; List<String> get allowedBranchIds; List<String> get allowedClassTypeIds;
/// Create a copy of PackageEntitlementRuleModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackageEntitlementRuleModelCopyWith<PackageEntitlementRuleModel> get copyWith => _$PackageEntitlementRuleModelCopyWithImpl<PackageEntitlementRuleModel>(this as PackageEntitlementRuleModel, _$identity);

  /// Serializes this PackageEntitlementRuleModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PackageEntitlementRuleModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackageEntitlementRuleModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.packageId, _this.packageId) || other.packageId == _this.packageId)&&(identical(other.entitlementKind, _this.entitlementKind) || other.entitlementKind == _this.entitlementKind)&&(identical(other.durationDays, _this.durationDays) || other.durationDays == _this.durationDays)&&(identical(other.creditQuantity, _this.creditQuantity) || other.creditQuantity == _this.creditQuantity)&&(identical(other.branchAccessScope, _this.branchAccessScope) || other.branchAccessScope == _this.branchAccessScope)&&(identical(other.classScope, _this.classScope) || other.classScope == _this.classScope)&&const DeepCollectionEquality().equals(other.allowedBranchIds, _this.allowedBranchIds)&&const DeepCollectionEquality().equals(other.allowedClassTypeIds, _this.allowedClassTypeIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PackageEntitlementRuleModel;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.packageId,_this.entitlementKind,_this.durationDays,_this.creditQuantity,_this.branchAccessScope,_this.classScope,const DeepCollectionEquality().hash(_this.allowedBranchIds),const DeepCollectionEquality().hash(_this.allowedClassTypeIds));
}

@override
String toString() {
  final _this = this as PackageEntitlementRuleModel;
  return 'PackageEntitlementRuleModel(id: ${_this.id}, organizationId: ${_this.organizationId}, packageId: ${_this.packageId}, entitlementKind: ${_this.entitlementKind}, durationDays: ${_this.durationDays}, creditQuantity: ${_this.creditQuantity}, branchAccessScope: ${_this.branchAccessScope}, classScope: ${_this.classScope}, allowedBranchIds: ${_this.allowedBranchIds}, allowedClassTypeIds: ${_this.allowedClassTypeIds})';
}


}

/// @nodoc
abstract mixin class $PackageEntitlementRuleModelCopyWith<$Res>  {
  factory $PackageEntitlementRuleModelCopyWith(PackageEntitlementRuleModel value, $Res Function(PackageEntitlementRuleModel) _then) = _$PackageEntitlementRuleModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'package_id') String packageId,@JsonKey(name: 'entitlement_kind') EntitlementKind entitlementKind,@JsonKey(name: 'duration_days') int? durationDays,@JsonKey(name: 'credit_quantity') int? creditQuantity,@JsonKey(name: 'branch_access_scope') BranchAccessScope branchAccessScope,@JsonKey(name: 'class_scope') ClassScope classScope, List<String> allowedBranchIds, List<String> allowedClassTypeIds
});




}
/// @nodoc
class _$PackageEntitlementRuleModelCopyWithImpl<$Res>
    implements $PackageEntitlementRuleModelCopyWith<$Res> {
  _$PackageEntitlementRuleModelCopyWithImpl(this._self, this._then);

  final PackageEntitlementRuleModel _self;
  final $Res Function(PackageEntitlementRuleModel) _then;

/// Create a copy of PackageEntitlementRuleModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? packageId = null,Object? entitlementKind = null,Object? durationDays = freezed,Object? creditQuantity = freezed,Object? branchAccessScope = null,Object? classScope = null,Object? allowedBranchIds = null,Object? allowedClassTypeIds = null,}) {
  return _then(PackageEntitlementRuleModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,packageId: null == packageId ? _self.packageId : packageId // ignore: cast_nullable_to_non_nullable
as String,entitlementKind: null == entitlementKind ? _self.entitlementKind : entitlementKind // ignore: cast_nullable_to_non_nullable
as EntitlementKind,durationDays: freezed == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as int?,creditQuantity: freezed == creditQuantity ? _self.creditQuantity : creditQuantity // ignore: cast_nullable_to_non_nullable
as int?,branchAccessScope: null == branchAccessScope ? _self.branchAccessScope : branchAccessScope // ignore: cast_nullable_to_non_nullable
as BranchAccessScope,classScope: null == classScope ? _self.classScope : classScope // ignore: cast_nullable_to_non_nullable
as ClassScope,allowedBranchIds: null == allowedBranchIds ? _self.allowedBranchIds : allowedBranchIds // ignore: cast_nullable_to_non_nullable
as List<String>,allowedClassTypeIds: null == allowedClassTypeIds ? _self.allowedClassTypeIds : allowedClassTypeIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [PackageEntitlementRuleModel].
extension PackageEntitlementRuleModelPatterns on PackageEntitlementRuleModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackageEntitlementRuleModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackageEntitlementRuleModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackageEntitlementRuleModel value)  $default,){
final _that = this;
switch (_that) {
case _PackageEntitlementRuleModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackageEntitlementRuleModel value)?  $default,){
final _that = this;
switch (_that) {
case _PackageEntitlementRuleModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'package_id')  String packageId, @JsonKey(name: 'entitlement_kind')  EntitlementKind entitlementKind, @JsonKey(name: 'duration_days')  int? durationDays, @JsonKey(name: 'credit_quantity')  int? creditQuantity, @JsonKey(name: 'branch_access_scope')  BranchAccessScope branchAccessScope, @JsonKey(name: 'class_scope')  ClassScope classScope,  List<String> allowedBranchIds,  List<String> allowedClassTypeIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackageEntitlementRuleModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.packageId,_that.entitlementKind,_that.durationDays,_that.creditQuantity,_that.branchAccessScope,_that.classScope,_that.allowedBranchIds,_that.allowedClassTypeIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'package_id')  String packageId, @JsonKey(name: 'entitlement_kind')  EntitlementKind entitlementKind, @JsonKey(name: 'duration_days')  int? durationDays, @JsonKey(name: 'credit_quantity')  int? creditQuantity, @JsonKey(name: 'branch_access_scope')  BranchAccessScope branchAccessScope, @JsonKey(name: 'class_scope')  ClassScope classScope,  List<String> allowedBranchIds,  List<String> allowedClassTypeIds)  $default,) {final _that = this;
switch (_that) {
case _PackageEntitlementRuleModel():
return $default(_that.id,_that.organizationId,_that.packageId,_that.entitlementKind,_that.durationDays,_that.creditQuantity,_that.branchAccessScope,_that.classScope,_that.allowedBranchIds,_that.allowedClassTypeIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'package_id')  String packageId, @JsonKey(name: 'entitlement_kind')  EntitlementKind entitlementKind, @JsonKey(name: 'duration_days')  int? durationDays, @JsonKey(name: 'credit_quantity')  int? creditQuantity, @JsonKey(name: 'branch_access_scope')  BranchAccessScope branchAccessScope, @JsonKey(name: 'class_scope')  ClassScope classScope,  List<String> allowedBranchIds,  List<String> allowedClassTypeIds)?  $default,) {final _that = this;
switch (_that) {
case _PackageEntitlementRuleModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.packageId,_that.entitlementKind,_that.durationDays,_that.creditQuantity,_that.branchAccessScope,_that.classScope,_that.allowedBranchIds,_that.allowedClassTypeIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackageEntitlementRuleModel implements PackageEntitlementRuleModel {
  const _PackageEntitlementRuleModel({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'package_id') required this.packageId, @JsonKey(name: 'entitlement_kind') required this.entitlementKind, @JsonKey(name: 'duration_days') this.durationDays, @JsonKey(name: 'credit_quantity') this.creditQuantity, @JsonKey(name: 'branch_access_scope') this.branchAccessScope = BranchAccessScope.singleBranch, @JsonKey(name: 'class_scope') this.classScope = ClassScope.allClasses,  List<String> allowedBranchIds = const <String>[],  List<String> allowedClassTypeIds = const <String>[]}): _allowedBranchIds = allowedBranchIds,_allowedClassTypeIds = allowedClassTypeIds;
  factory _PackageEntitlementRuleModel.fromJson(Map<String, dynamic> json) => _$PackageEntitlementRuleModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'package_id') final  String packageId;
@override@JsonKey(name: 'entitlement_kind') final  EntitlementKind entitlementKind;
@override@JsonKey(name: 'duration_days') final  int? durationDays;
@override@JsonKey(name: 'credit_quantity') final  int? creditQuantity;
@override@JsonKey(name: 'branch_access_scope') final  BranchAccessScope branchAccessScope;
@override@JsonKey(name: 'class_scope') final  ClassScope classScope;
 final  List<String> _allowedBranchIds;
@override@JsonKey() List<String> get allowedBranchIds {
  if (_allowedBranchIds is EqualUnmodifiableListView) return _allowedBranchIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedBranchIds);
}

 final  List<String> _allowedClassTypeIds;
@override@JsonKey() List<String> get allowedClassTypeIds {
  if (_allowedClassTypeIds is EqualUnmodifiableListView) return _allowedClassTypeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedClassTypeIds);
}


/// Create a copy of PackageEntitlementRuleModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackageEntitlementRuleModelCopyWith<_PackageEntitlementRuleModel> get copyWith => __$PackageEntitlementRuleModelCopyWithImpl<_PackageEntitlementRuleModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackageEntitlementRuleModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackageEntitlementRuleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.packageId, packageId) || other.packageId == packageId)&&(identical(other.entitlementKind, entitlementKind) || other.entitlementKind == entitlementKind)&&(identical(other.durationDays, durationDays) || other.durationDays == durationDays)&&(identical(other.creditQuantity, creditQuantity) || other.creditQuantity == creditQuantity)&&(identical(other.branchAccessScope, branchAccessScope) || other.branchAccessScope == branchAccessScope)&&(identical(other.classScope, classScope) || other.classScope == classScope)&&const DeepCollectionEquality().equals(other.allowedBranchIds, _allowedBranchIds)&&const DeepCollectionEquality().equals(other.allowedClassTypeIds, _allowedClassTypeIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,packageId,entitlementKind,durationDays,creditQuantity,branchAccessScope,classScope,const DeepCollectionEquality().hash(_allowedBranchIds),const DeepCollectionEquality().hash(_allowedClassTypeIds));
}

@override
String toString() {
    return 'PackageEntitlementRuleModel(id: $id, organizationId: $organizationId, packageId: $packageId, entitlementKind: $entitlementKind, durationDays: $durationDays, creditQuantity: $creditQuantity, branchAccessScope: $branchAccessScope, classScope: $classScope, allowedBranchIds: $allowedBranchIds, allowedClassTypeIds: $allowedClassTypeIds)';
}


}

/// @nodoc
abstract mixin class _$PackageEntitlementRuleModelCopyWith<$Res> implements $PackageEntitlementRuleModelCopyWith<$Res> {
  factory _$PackageEntitlementRuleModelCopyWith(_PackageEntitlementRuleModel value, $Res Function(_PackageEntitlementRuleModel) _then) = __$PackageEntitlementRuleModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'package_id') String packageId,@JsonKey(name: 'entitlement_kind') EntitlementKind entitlementKind,@JsonKey(name: 'duration_days') int? durationDays,@JsonKey(name: 'credit_quantity') int? creditQuantity,@JsonKey(name: 'branch_access_scope') BranchAccessScope branchAccessScope,@JsonKey(name: 'class_scope') ClassScope classScope, List<String> allowedBranchIds, List<String> allowedClassTypeIds
});




}
/// @nodoc
class __$PackageEntitlementRuleModelCopyWithImpl<$Res>
    implements _$PackageEntitlementRuleModelCopyWith<$Res> {
  __$PackageEntitlementRuleModelCopyWithImpl(this._self, this._then);

  final _PackageEntitlementRuleModel _self;
  final $Res Function(_PackageEntitlementRuleModel) _then;

/// Create a copy of PackageEntitlementRuleModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? packageId = null,Object? entitlementKind = null,Object? durationDays = freezed,Object? creditQuantity = freezed,Object? branchAccessScope = null,Object? classScope = null,Object? allowedBranchIds = null,Object? allowedClassTypeIds = null,}) {
  return _then(_PackageEntitlementRuleModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,packageId: null == packageId ? _self.packageId : packageId // ignore: cast_nullable_to_non_nullable
as String,entitlementKind: null == entitlementKind ? _self.entitlementKind : entitlementKind // ignore: cast_nullable_to_non_nullable
as EntitlementKind,durationDays: freezed == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as int?,creditQuantity: freezed == creditQuantity ? _self.creditQuantity : creditQuantity // ignore: cast_nullable_to_non_nullable
as int?,branchAccessScope: null == branchAccessScope ? _self.branchAccessScope : branchAccessScope // ignore: cast_nullable_to_non_nullable
as BranchAccessScope,classScope: null == classScope ? _self.classScope : classScope // ignore: cast_nullable_to_non_nullable
as ClassScope,allowedBranchIds: null == allowedBranchIds ? _self._allowedBranchIds : allowedBranchIds // ignore: cast_nullable_to_non_nullable
as List<String>,allowedClassTypeIds: null == allowedClassTypeIds ? _self._allowedClassTypeIds : allowedClassTypeIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$PackageModel {

 String get id;@JsonKey(name: 'organization_id') String get organizationId; String get name; String get description;@JsonKey(name: 'package_type') PackageType get packageType;@JsonKey(name: 'price_minor') int get priceMinor;@JsonKey(name: 'currency_code') String get currencyCode;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'package_entitlement_rules') List<PackageEntitlementRuleModel> get rules;
/// Create a copy of PackageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackageModelCopyWith<PackageModel> get copyWith => _$PackageModelCopyWithImpl<PackageModel>(this as PackageModel, _$identity);

  /// Serializes this PackageModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PackageModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackageModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.packageType, _this.packageType) || other.packageType == _this.packageType)&&(identical(other.priceMinor, _this.priceMinor) || other.priceMinor == _this.priceMinor)&&(identical(other.currencyCode, _this.currencyCode) || other.currencyCode == _this.currencyCode)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&const DeepCollectionEquality().equals(other.rules, _this.rules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PackageModel;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.name,_this.description,_this.packageType,_this.priceMinor,_this.currencyCode,_this.isActive,const DeepCollectionEquality().hash(_this.rules));
}

@override
String toString() {
  final _this = this as PackageModel;
  return 'PackageModel(id: ${_this.id}, organizationId: ${_this.organizationId}, name: ${_this.name}, description: ${_this.description}, packageType: ${_this.packageType}, priceMinor: ${_this.priceMinor}, currencyCode: ${_this.currencyCode}, isActive: ${_this.isActive}, rules: ${_this.rules})';
}


}

/// @nodoc
abstract mixin class $PackageModelCopyWith<$Res>  {
  factory $PackageModelCopyWith(PackageModel value, $Res Function(PackageModel) _then) = _$PackageModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId, String name, String description,@JsonKey(name: 'package_type') PackageType packageType,@JsonKey(name: 'price_minor') int priceMinor,@JsonKey(name: 'currency_code') String currencyCode,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'package_entitlement_rules') List<PackageEntitlementRuleModel> rules
});




}
/// @nodoc
class _$PackageModelCopyWithImpl<$Res>
    implements $PackageModelCopyWith<$Res> {
  _$PackageModelCopyWithImpl(this._self, this._then);

  final PackageModel _self;
  final $Res Function(PackageModel) _then;

/// Create a copy of PackageModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? description = null,Object? packageType = null,Object? priceMinor = null,Object? currencyCode = null,Object? isActive = null,Object? rules = null,}) {
  return _then(PackageModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,packageType: null == packageType ? _self.packageType : packageType // ignore: cast_nullable_to_non_nullable
as PackageType,priceMinor: null == priceMinor ? _self.priceMinor : priceMinor // ignore: cast_nullable_to_non_nullable
as int,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as List<PackageEntitlementRuleModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [PackageModel].
extension PackageModelPatterns on PackageModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackageModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackageModel value)  $default,){
final _that = this;
switch (_that) {
case _PackageModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackageModel value)?  $default,){
final _that = this;
switch (_that) {
case _PackageModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId,  String name,  String description, @JsonKey(name: 'package_type')  PackageType packageType, @JsonKey(name: 'price_minor')  int priceMinor, @JsonKey(name: 'currency_code')  String currencyCode, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'package_entitlement_rules')  List<PackageEntitlementRuleModel> rules)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackageModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.description,_that.packageType,_that.priceMinor,_that.currencyCode,_that.isActive,_that.rules);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId,  String name,  String description, @JsonKey(name: 'package_type')  PackageType packageType, @JsonKey(name: 'price_minor')  int priceMinor, @JsonKey(name: 'currency_code')  String currencyCode, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'package_entitlement_rules')  List<PackageEntitlementRuleModel> rules)  $default,) {final _that = this;
switch (_that) {
case _PackageModel():
return $default(_that.id,_that.organizationId,_that.name,_that.description,_that.packageType,_that.priceMinor,_that.currencyCode,_that.isActive,_that.rules);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId,  String name,  String description, @JsonKey(name: 'package_type')  PackageType packageType, @JsonKey(name: 'price_minor')  int priceMinor, @JsonKey(name: 'currency_code')  String currencyCode, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'package_entitlement_rules')  List<PackageEntitlementRuleModel> rules)?  $default,) {final _that = this;
switch (_that) {
case _PackageModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.description,_that.packageType,_that.priceMinor,_that.currencyCode,_that.isActive,_that.rules);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackageModel implements PackageModel {
  const _PackageModel({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, required this.name, this.description = '', @JsonKey(name: 'package_type') required this.packageType, @JsonKey(name: 'price_minor') this.priceMinor = 0, @JsonKey(name: 'currency_code') this.currencyCode = 'USD', @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'package_entitlement_rules')  List<PackageEntitlementRuleModel> rules = const <PackageEntitlementRuleModel>[]}): _rules = rules;
  factory _PackageModel.fromJson(Map<String, dynamic> json) => _$PackageModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override final  String name;
@override@JsonKey() final  String description;
@override@JsonKey(name: 'package_type') final  PackageType packageType;
@override@JsonKey(name: 'price_minor') final  int priceMinor;
@override@JsonKey(name: 'currency_code') final  String currencyCode;
@override@JsonKey(name: 'is_active') final  bool isActive;
 final  List<PackageEntitlementRuleModel> _rules;
@override@JsonKey(name: 'package_entitlement_rules') List<PackageEntitlementRuleModel> get rules {
  if (_rules is EqualUnmodifiableListView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rules);
}


/// Create a copy of PackageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackageModelCopyWith<_PackageModel> get copyWith => __$PackageModelCopyWithImpl<_PackageModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackageModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.packageType, packageType) || other.packageType == packageType)&&(identical(other.priceMinor, priceMinor) || other.priceMinor == priceMinor)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other.rules, _rules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,name,description,packageType,priceMinor,currencyCode,isActive,const DeepCollectionEquality().hash(_rules));
}

@override
String toString() {
    return 'PackageModel(id: $id, organizationId: $organizationId, name: $name, description: $description, packageType: $packageType, priceMinor: $priceMinor, currencyCode: $currencyCode, isActive: $isActive, rules: $rules)';
}


}

/// @nodoc
abstract mixin class _$PackageModelCopyWith<$Res> implements $PackageModelCopyWith<$Res> {
  factory _$PackageModelCopyWith(_PackageModel value, $Res Function(_PackageModel) _then) = __$PackageModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId, String name, String description,@JsonKey(name: 'package_type') PackageType packageType,@JsonKey(name: 'price_minor') int priceMinor,@JsonKey(name: 'currency_code') String currencyCode,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'package_entitlement_rules') List<PackageEntitlementRuleModel> rules
});




}
/// @nodoc
class __$PackageModelCopyWithImpl<$Res>
    implements _$PackageModelCopyWith<$Res> {
  __$PackageModelCopyWithImpl(this._self, this._then);

  final _PackageModel _self;
  final $Res Function(_PackageModel) _then;

/// Create a copy of PackageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? description = null,Object? packageType = null,Object? priceMinor = null,Object? currencyCode = null,Object? isActive = null,Object? rules = null,}) {
  return _then(_PackageModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,packageType: null == packageType ? _self.packageType : packageType // ignore: cast_nullable_to_non_nullable
as PackageType,priceMinor: null == priceMinor ? _self.priceMinor : priceMinor // ignore: cast_nullable_to_non_nullable
as int,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as List<PackageEntitlementRuleModel>,
  ));
}


}


/// @nodoc
mixin _$MemberSubscriptionModel {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'member_id') String get memberId;@JsonKey(name: 'package_id') String get packageId;@JsonKey(name: 'assigned_branch_id') String get assignedBranchId; SubscriptionStatus get status;@JsonKey(name: 'starts_at') DateTime get startsAt;@JsonKey(name: 'ends_at') DateTime? get endsAt;@JsonKey(name: 'frozen_at') DateTime? get frozenAt;@JsonKey(name: 'total_frozen_seconds') int get totalFrozenSeconds;
/// Create a copy of MemberSubscriptionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberSubscriptionModelCopyWith<MemberSubscriptionModel> get copyWith => _$MemberSubscriptionModelCopyWithImpl<MemberSubscriptionModel>(this as MemberSubscriptionModel, _$identity);

  /// Serializes this MemberSubscriptionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MemberSubscriptionModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberSubscriptionModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.memberId, _this.memberId) || other.memberId == _this.memberId)&&(identical(other.packageId, _this.packageId) || other.packageId == _this.packageId)&&(identical(other.assignedBranchId, _this.assignedBranchId) || other.assignedBranchId == _this.assignedBranchId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.startsAt, _this.startsAt) || other.startsAt == _this.startsAt)&&(identical(other.endsAt, _this.endsAt) || other.endsAt == _this.endsAt)&&(identical(other.frozenAt, _this.frozenAt) || other.frozenAt == _this.frozenAt)&&(identical(other.totalFrozenSeconds, _this.totalFrozenSeconds) || other.totalFrozenSeconds == _this.totalFrozenSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MemberSubscriptionModel;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.memberId,_this.packageId,_this.assignedBranchId,_this.status,_this.startsAt,_this.endsAt,_this.frozenAt,_this.totalFrozenSeconds);
}

@override
String toString() {
  final _this = this as MemberSubscriptionModel;
  return 'MemberSubscriptionModel(id: ${_this.id}, organizationId: ${_this.organizationId}, memberId: ${_this.memberId}, packageId: ${_this.packageId}, assignedBranchId: ${_this.assignedBranchId}, status: ${_this.status}, startsAt: ${_this.startsAt}, endsAt: ${_this.endsAt}, frozenAt: ${_this.frozenAt}, totalFrozenSeconds: ${_this.totalFrozenSeconds})';
}


}

/// @nodoc
abstract mixin class $MemberSubscriptionModelCopyWith<$Res>  {
  factory $MemberSubscriptionModelCopyWith(MemberSubscriptionModel value, $Res Function(MemberSubscriptionModel) _then) = _$MemberSubscriptionModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'package_id') String packageId,@JsonKey(name: 'assigned_branch_id') String assignedBranchId, SubscriptionStatus status,@JsonKey(name: 'starts_at') DateTime startsAt,@JsonKey(name: 'ends_at') DateTime? endsAt,@JsonKey(name: 'frozen_at') DateTime? frozenAt,@JsonKey(name: 'total_frozen_seconds') int totalFrozenSeconds
});




}
/// @nodoc
class _$MemberSubscriptionModelCopyWithImpl<$Res>
    implements $MemberSubscriptionModelCopyWith<$Res> {
  _$MemberSubscriptionModelCopyWithImpl(this._self, this._then);

  final MemberSubscriptionModel _self;
  final $Res Function(MemberSubscriptionModel) _then;

/// Create a copy of MemberSubscriptionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? memberId = null,Object? packageId = null,Object? assignedBranchId = null,Object? status = null,Object? startsAt = null,Object? endsAt = freezed,Object? frozenAt = freezed,Object? totalFrozenSeconds = null,}) {
  return _then(MemberSubscriptionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,packageId: null == packageId ? _self.packageId : packageId // ignore: cast_nullable_to_non_nullable
as String,assignedBranchId: null == assignedBranchId ? _self.assignedBranchId : assignedBranchId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SubscriptionStatus,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,frozenAt: freezed == frozenAt ? _self.frozenAt : frozenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,totalFrozenSeconds: null == totalFrozenSeconds ? _self.totalFrozenSeconds : totalFrozenSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberSubscriptionModel].
extension MemberSubscriptionModelPatterns on MemberSubscriptionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberSubscriptionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberSubscriptionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberSubscriptionModel value)  $default,){
final _that = this;
switch (_that) {
case _MemberSubscriptionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberSubscriptionModel value)?  $default,){
final _that = this;
switch (_that) {
case _MemberSubscriptionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'package_id')  String packageId, @JsonKey(name: 'assigned_branch_id')  String assignedBranchId,  SubscriptionStatus status, @JsonKey(name: 'starts_at')  DateTime startsAt, @JsonKey(name: 'ends_at')  DateTime? endsAt, @JsonKey(name: 'frozen_at')  DateTime? frozenAt, @JsonKey(name: 'total_frozen_seconds')  int totalFrozenSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberSubscriptionModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.memberId,_that.packageId,_that.assignedBranchId,_that.status,_that.startsAt,_that.endsAt,_that.frozenAt,_that.totalFrozenSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'package_id')  String packageId, @JsonKey(name: 'assigned_branch_id')  String assignedBranchId,  SubscriptionStatus status, @JsonKey(name: 'starts_at')  DateTime startsAt, @JsonKey(name: 'ends_at')  DateTime? endsAt, @JsonKey(name: 'frozen_at')  DateTime? frozenAt, @JsonKey(name: 'total_frozen_seconds')  int totalFrozenSeconds)  $default,) {final _that = this;
switch (_that) {
case _MemberSubscriptionModel():
return $default(_that.id,_that.organizationId,_that.memberId,_that.packageId,_that.assignedBranchId,_that.status,_that.startsAt,_that.endsAt,_that.frozenAt,_that.totalFrozenSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'package_id')  String packageId, @JsonKey(name: 'assigned_branch_id')  String assignedBranchId,  SubscriptionStatus status, @JsonKey(name: 'starts_at')  DateTime startsAt, @JsonKey(name: 'ends_at')  DateTime? endsAt, @JsonKey(name: 'frozen_at')  DateTime? frozenAt, @JsonKey(name: 'total_frozen_seconds')  int totalFrozenSeconds)?  $default,) {final _that = this;
switch (_that) {
case _MemberSubscriptionModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.memberId,_that.packageId,_that.assignedBranchId,_that.status,_that.startsAt,_that.endsAt,_that.frozenAt,_that.totalFrozenSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemberSubscriptionModel implements MemberSubscriptionModel {
  const _MemberSubscriptionModel({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'member_id') required this.memberId, @JsonKey(name: 'package_id') required this.packageId, @JsonKey(name: 'assigned_branch_id') required this.assignedBranchId, required this.status, @JsonKey(name: 'starts_at') required this.startsAt, @JsonKey(name: 'ends_at') this.endsAt, @JsonKey(name: 'frozen_at') this.frozenAt, @JsonKey(name: 'total_frozen_seconds') this.totalFrozenSeconds = 0});
  factory _MemberSubscriptionModel.fromJson(Map<String, dynamic> json) => _$MemberSubscriptionModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'member_id') final  String memberId;
@override@JsonKey(name: 'package_id') final  String packageId;
@override@JsonKey(name: 'assigned_branch_id') final  String assignedBranchId;
@override final  SubscriptionStatus status;
@override@JsonKey(name: 'starts_at') final  DateTime startsAt;
@override@JsonKey(name: 'ends_at') final  DateTime? endsAt;
@override@JsonKey(name: 'frozen_at') final  DateTime? frozenAt;
@override@JsonKey(name: 'total_frozen_seconds') final  int totalFrozenSeconds;

/// Create a copy of MemberSubscriptionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberSubscriptionModelCopyWith<_MemberSubscriptionModel> get copyWith => __$MemberSubscriptionModelCopyWithImpl<_MemberSubscriptionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberSubscriptionModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberSubscriptionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.packageId, packageId) || other.packageId == packageId)&&(identical(other.assignedBranchId, assignedBranchId) || other.assignedBranchId == assignedBranchId)&&(identical(other.status, status) || other.status == status)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.frozenAt, frozenAt) || other.frozenAt == frozenAt)&&(identical(other.totalFrozenSeconds, totalFrozenSeconds) || other.totalFrozenSeconds == totalFrozenSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,memberId,packageId,assignedBranchId,status,startsAt,endsAt,frozenAt,totalFrozenSeconds);
}

@override
String toString() {
    return 'MemberSubscriptionModel(id: $id, organizationId: $organizationId, memberId: $memberId, packageId: $packageId, assignedBranchId: $assignedBranchId, status: $status, startsAt: $startsAt, endsAt: $endsAt, frozenAt: $frozenAt, totalFrozenSeconds: $totalFrozenSeconds)';
}


}

/// @nodoc
abstract mixin class _$MemberSubscriptionModelCopyWith<$Res> implements $MemberSubscriptionModelCopyWith<$Res> {
  factory _$MemberSubscriptionModelCopyWith(_MemberSubscriptionModel value, $Res Function(_MemberSubscriptionModel) _then) = __$MemberSubscriptionModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'package_id') String packageId,@JsonKey(name: 'assigned_branch_id') String assignedBranchId, SubscriptionStatus status,@JsonKey(name: 'starts_at') DateTime startsAt,@JsonKey(name: 'ends_at') DateTime? endsAt,@JsonKey(name: 'frozen_at') DateTime? frozenAt,@JsonKey(name: 'total_frozen_seconds') int totalFrozenSeconds
});




}
/// @nodoc
class __$MemberSubscriptionModelCopyWithImpl<$Res>
    implements _$MemberSubscriptionModelCopyWith<$Res> {
  __$MemberSubscriptionModelCopyWithImpl(this._self, this._then);

  final _MemberSubscriptionModel _self;
  final $Res Function(_MemberSubscriptionModel) _then;

/// Create a copy of MemberSubscriptionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? memberId = null,Object? packageId = null,Object? assignedBranchId = null,Object? status = null,Object? startsAt = null,Object? endsAt = freezed,Object? frozenAt = freezed,Object? totalFrozenSeconds = null,}) {
  return _then(_MemberSubscriptionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,packageId: null == packageId ? _self.packageId : packageId // ignore: cast_nullable_to_non_nullable
as String,assignedBranchId: null == assignedBranchId ? _self.assignedBranchId : assignedBranchId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SubscriptionStatus,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,frozenAt: freezed == frozenAt ? _self.frozenAt : frozenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,totalFrozenSeconds: null == totalFrozenSeconds ? _self.totalFrozenSeconds : totalFrozenSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$MemberEntitlementModel {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'member_id') String get memberId;@JsonKey(name: 'subscription_id') String get subscriptionId;@JsonKey(name: 'entitlement_kind') EntitlementKind get entitlementKind;@JsonKey(name: 'branch_access_scope') BranchAccessScope get branchAccessScope;@JsonKey(name: 'class_scope') ClassScope get classScope;@JsonKey(name: 'valid_from') DateTime get validFrom;@JsonKey(name: 'valid_until') DateTime get validUntil; EntitlementStatus get status; List<String> get allowedBranchIds;
/// Create a copy of MemberEntitlementModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberEntitlementModelCopyWith<MemberEntitlementModel> get copyWith => _$MemberEntitlementModelCopyWithImpl<MemberEntitlementModel>(this as MemberEntitlementModel, _$identity);

  /// Serializes this MemberEntitlementModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MemberEntitlementModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberEntitlementModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.memberId, _this.memberId) || other.memberId == _this.memberId)&&(identical(other.subscriptionId, _this.subscriptionId) || other.subscriptionId == _this.subscriptionId)&&(identical(other.entitlementKind, _this.entitlementKind) || other.entitlementKind == _this.entitlementKind)&&(identical(other.branchAccessScope, _this.branchAccessScope) || other.branchAccessScope == _this.branchAccessScope)&&(identical(other.classScope, _this.classScope) || other.classScope == _this.classScope)&&(identical(other.validFrom, _this.validFrom) || other.validFrom == _this.validFrom)&&(identical(other.validUntil, _this.validUntil) || other.validUntil == _this.validUntil)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.allowedBranchIds, _this.allowedBranchIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MemberEntitlementModel;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.memberId,_this.subscriptionId,_this.entitlementKind,_this.branchAccessScope,_this.classScope,_this.validFrom,_this.validUntil,_this.status,const DeepCollectionEquality().hash(_this.allowedBranchIds));
}

@override
String toString() {
  final _this = this as MemberEntitlementModel;
  return 'MemberEntitlementModel(id: ${_this.id}, organizationId: ${_this.organizationId}, memberId: ${_this.memberId}, subscriptionId: ${_this.subscriptionId}, entitlementKind: ${_this.entitlementKind}, branchAccessScope: ${_this.branchAccessScope}, classScope: ${_this.classScope}, validFrom: ${_this.validFrom}, validUntil: ${_this.validUntil}, status: ${_this.status}, allowedBranchIds: ${_this.allowedBranchIds})';
}


}

/// @nodoc
abstract mixin class $MemberEntitlementModelCopyWith<$Res>  {
  factory $MemberEntitlementModelCopyWith(MemberEntitlementModel value, $Res Function(MemberEntitlementModel) _then) = _$MemberEntitlementModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'subscription_id') String subscriptionId,@JsonKey(name: 'entitlement_kind') EntitlementKind entitlementKind,@JsonKey(name: 'branch_access_scope') BranchAccessScope branchAccessScope,@JsonKey(name: 'class_scope') ClassScope classScope,@JsonKey(name: 'valid_from') DateTime validFrom,@JsonKey(name: 'valid_until') DateTime validUntil, EntitlementStatus status, List<String> allowedBranchIds
});




}
/// @nodoc
class _$MemberEntitlementModelCopyWithImpl<$Res>
    implements $MemberEntitlementModelCopyWith<$Res> {
  _$MemberEntitlementModelCopyWithImpl(this._self, this._then);

  final MemberEntitlementModel _self;
  final $Res Function(MemberEntitlementModel) _then;

/// Create a copy of MemberEntitlementModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? memberId = null,Object? subscriptionId = null,Object? entitlementKind = null,Object? branchAccessScope = null,Object? classScope = null,Object? validFrom = null,Object? validUntil = null,Object? status = null,Object? allowedBranchIds = null,}) {
  return _then(MemberEntitlementModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: null == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String,entitlementKind: null == entitlementKind ? _self.entitlementKind : entitlementKind // ignore: cast_nullable_to_non_nullable
as EntitlementKind,branchAccessScope: null == branchAccessScope ? _self.branchAccessScope : branchAccessScope // ignore: cast_nullable_to_non_nullable
as BranchAccessScope,classScope: null == classScope ? _self.classScope : classScope // ignore: cast_nullable_to_non_nullable
as ClassScope,validFrom: null == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as DateTime,validUntil: null == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntitlementStatus,allowedBranchIds: null == allowedBranchIds ? _self.allowedBranchIds : allowedBranchIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberEntitlementModel].
extension MemberEntitlementModelPatterns on MemberEntitlementModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberEntitlementModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberEntitlementModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberEntitlementModel value)  $default,){
final _that = this;
switch (_that) {
case _MemberEntitlementModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberEntitlementModel value)?  $default,){
final _that = this;
switch (_that) {
case _MemberEntitlementModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'subscription_id')  String subscriptionId, @JsonKey(name: 'entitlement_kind')  EntitlementKind entitlementKind, @JsonKey(name: 'branch_access_scope')  BranchAccessScope branchAccessScope, @JsonKey(name: 'class_scope')  ClassScope classScope, @JsonKey(name: 'valid_from')  DateTime validFrom, @JsonKey(name: 'valid_until')  DateTime validUntil,  EntitlementStatus status,  List<String> allowedBranchIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberEntitlementModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.memberId,_that.subscriptionId,_that.entitlementKind,_that.branchAccessScope,_that.classScope,_that.validFrom,_that.validUntil,_that.status,_that.allowedBranchIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'subscription_id')  String subscriptionId, @JsonKey(name: 'entitlement_kind')  EntitlementKind entitlementKind, @JsonKey(name: 'branch_access_scope')  BranchAccessScope branchAccessScope, @JsonKey(name: 'class_scope')  ClassScope classScope, @JsonKey(name: 'valid_from')  DateTime validFrom, @JsonKey(name: 'valid_until')  DateTime validUntil,  EntitlementStatus status,  List<String> allowedBranchIds)  $default,) {final _that = this;
switch (_that) {
case _MemberEntitlementModel():
return $default(_that.id,_that.organizationId,_that.memberId,_that.subscriptionId,_that.entitlementKind,_that.branchAccessScope,_that.classScope,_that.validFrom,_that.validUntil,_that.status,_that.allowedBranchIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'subscription_id')  String subscriptionId, @JsonKey(name: 'entitlement_kind')  EntitlementKind entitlementKind, @JsonKey(name: 'branch_access_scope')  BranchAccessScope branchAccessScope, @JsonKey(name: 'class_scope')  ClassScope classScope, @JsonKey(name: 'valid_from')  DateTime validFrom, @JsonKey(name: 'valid_until')  DateTime validUntil,  EntitlementStatus status,  List<String> allowedBranchIds)?  $default,) {final _that = this;
switch (_that) {
case _MemberEntitlementModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.memberId,_that.subscriptionId,_that.entitlementKind,_that.branchAccessScope,_that.classScope,_that.validFrom,_that.validUntil,_that.status,_that.allowedBranchIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemberEntitlementModel implements MemberEntitlementModel {
  const _MemberEntitlementModel({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'member_id') required this.memberId, @JsonKey(name: 'subscription_id') required this.subscriptionId, @JsonKey(name: 'entitlement_kind') required this.entitlementKind, @JsonKey(name: 'branch_access_scope') required this.branchAccessScope, @JsonKey(name: 'class_scope') required this.classScope, @JsonKey(name: 'valid_from') required this.validFrom, @JsonKey(name: 'valid_until') required this.validUntil, required this.status,  List<String> allowedBranchIds = const <String>[]}): _allowedBranchIds = allowedBranchIds;
  factory _MemberEntitlementModel.fromJson(Map<String, dynamic> json) => _$MemberEntitlementModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'member_id') final  String memberId;
@override@JsonKey(name: 'subscription_id') final  String subscriptionId;
@override@JsonKey(name: 'entitlement_kind') final  EntitlementKind entitlementKind;
@override@JsonKey(name: 'branch_access_scope') final  BranchAccessScope branchAccessScope;
@override@JsonKey(name: 'class_scope') final  ClassScope classScope;
@override@JsonKey(name: 'valid_from') final  DateTime validFrom;
@override@JsonKey(name: 'valid_until') final  DateTime validUntil;
@override final  EntitlementStatus status;
 final  List<String> _allowedBranchIds;
@override@JsonKey() List<String> get allowedBranchIds {
  if (_allowedBranchIds is EqualUnmodifiableListView) return _allowedBranchIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedBranchIds);
}


/// Create a copy of MemberEntitlementModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberEntitlementModelCopyWith<_MemberEntitlementModel> get copyWith => __$MemberEntitlementModelCopyWithImpl<_MemberEntitlementModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberEntitlementModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberEntitlementModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.entitlementKind, entitlementKind) || other.entitlementKind == entitlementKind)&&(identical(other.branchAccessScope, branchAccessScope) || other.branchAccessScope == branchAccessScope)&&(identical(other.classScope, classScope) || other.classScope == classScope)&&(identical(other.validFrom, validFrom) || other.validFrom == validFrom)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.allowedBranchIds, _allowedBranchIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,memberId,subscriptionId,entitlementKind,branchAccessScope,classScope,validFrom,validUntil,status,const DeepCollectionEquality().hash(_allowedBranchIds));
}

@override
String toString() {
    return 'MemberEntitlementModel(id: $id, organizationId: $organizationId, memberId: $memberId, subscriptionId: $subscriptionId, entitlementKind: $entitlementKind, branchAccessScope: $branchAccessScope, classScope: $classScope, validFrom: $validFrom, validUntil: $validUntil, status: $status, allowedBranchIds: $allowedBranchIds)';
}


}

/// @nodoc
abstract mixin class _$MemberEntitlementModelCopyWith<$Res> implements $MemberEntitlementModelCopyWith<$Res> {
  factory _$MemberEntitlementModelCopyWith(_MemberEntitlementModel value, $Res Function(_MemberEntitlementModel) _then) = __$MemberEntitlementModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'subscription_id') String subscriptionId,@JsonKey(name: 'entitlement_kind') EntitlementKind entitlementKind,@JsonKey(name: 'branch_access_scope') BranchAccessScope branchAccessScope,@JsonKey(name: 'class_scope') ClassScope classScope,@JsonKey(name: 'valid_from') DateTime validFrom,@JsonKey(name: 'valid_until') DateTime validUntil, EntitlementStatus status, List<String> allowedBranchIds
});




}
/// @nodoc
class __$MemberEntitlementModelCopyWithImpl<$Res>
    implements _$MemberEntitlementModelCopyWith<$Res> {
  __$MemberEntitlementModelCopyWithImpl(this._self, this._then);

  final _MemberEntitlementModel _self;
  final $Res Function(_MemberEntitlementModel) _then;

/// Create a copy of MemberEntitlementModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? memberId = null,Object? subscriptionId = null,Object? entitlementKind = null,Object? branchAccessScope = null,Object? classScope = null,Object? validFrom = null,Object? validUntil = null,Object? status = null,Object? allowedBranchIds = null,}) {
  return _then(_MemberEntitlementModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: null == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String,entitlementKind: null == entitlementKind ? _self.entitlementKind : entitlementKind // ignore: cast_nullable_to_non_nullable
as EntitlementKind,branchAccessScope: null == branchAccessScope ? _self.branchAccessScope : branchAccessScope // ignore: cast_nullable_to_non_nullable
as BranchAccessScope,classScope: null == classScope ? _self.classScope : classScope // ignore: cast_nullable_to_non_nullable
as ClassScope,validFrom: null == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as DateTime,validUntil: null == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntitlementStatus,allowedBranchIds: null == allowedBranchIds ? _self._allowedBranchIds : allowedBranchIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$CreditGrantModel {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'member_id') String get memberId;@JsonKey(name: 'subscription_id') String? get subscriptionId;@JsonKey(name: 'credit_type') CreditType get creditType;@JsonKey(name: 'branch_access_scope') BranchAccessScope get branchAccessScope;@JsonKey(name: 'class_scope') ClassScope get classScope;@JsonKey(name: 'initial_amount') int get initialAmount;@JsonKey(name: 'remaining_amount') int get remainingAmount;@JsonKey(name: 'expires_at') DateTime? get expiresAt; CreditGrantStatus get status; List<String> get allowedBranchIds; List<String> get allowedClassTypeIds;
/// Create a copy of CreditGrantModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditGrantModelCopyWith<CreditGrantModel> get copyWith => _$CreditGrantModelCopyWithImpl<CreditGrantModel>(this as CreditGrantModel, _$identity);

  /// Serializes this CreditGrantModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreditGrantModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditGrantModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.memberId, _this.memberId) || other.memberId == _this.memberId)&&(identical(other.subscriptionId, _this.subscriptionId) || other.subscriptionId == _this.subscriptionId)&&(identical(other.creditType, _this.creditType) || other.creditType == _this.creditType)&&(identical(other.branchAccessScope, _this.branchAccessScope) || other.branchAccessScope == _this.branchAccessScope)&&(identical(other.classScope, _this.classScope) || other.classScope == _this.classScope)&&(identical(other.initialAmount, _this.initialAmount) || other.initialAmount == _this.initialAmount)&&(identical(other.remainingAmount, _this.remainingAmount) || other.remainingAmount == _this.remainingAmount)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.allowedBranchIds, _this.allowedBranchIds)&&const DeepCollectionEquality().equals(other.allowedClassTypeIds, _this.allowedClassTypeIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreditGrantModel;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.memberId,_this.subscriptionId,_this.creditType,_this.branchAccessScope,_this.classScope,_this.initialAmount,_this.remainingAmount,_this.expiresAt,_this.status,const DeepCollectionEquality().hash(_this.allowedBranchIds),const DeepCollectionEquality().hash(_this.allowedClassTypeIds));
}

@override
String toString() {
  final _this = this as CreditGrantModel;
  return 'CreditGrantModel(id: ${_this.id}, organizationId: ${_this.organizationId}, memberId: ${_this.memberId}, subscriptionId: ${_this.subscriptionId}, creditType: ${_this.creditType}, branchAccessScope: ${_this.branchAccessScope}, classScope: ${_this.classScope}, initialAmount: ${_this.initialAmount}, remainingAmount: ${_this.remainingAmount}, expiresAt: ${_this.expiresAt}, status: ${_this.status}, allowedBranchIds: ${_this.allowedBranchIds}, allowedClassTypeIds: ${_this.allowedClassTypeIds})';
}


}

/// @nodoc
abstract mixin class $CreditGrantModelCopyWith<$Res>  {
  factory $CreditGrantModelCopyWith(CreditGrantModel value, $Res Function(CreditGrantModel) _then) = _$CreditGrantModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'subscription_id') String? subscriptionId,@JsonKey(name: 'credit_type') CreditType creditType,@JsonKey(name: 'branch_access_scope') BranchAccessScope branchAccessScope,@JsonKey(name: 'class_scope') ClassScope classScope,@JsonKey(name: 'initial_amount') int initialAmount,@JsonKey(name: 'remaining_amount') int remainingAmount,@JsonKey(name: 'expires_at') DateTime? expiresAt, CreditGrantStatus status, List<String> allowedBranchIds, List<String> allowedClassTypeIds
});




}
/// @nodoc
class _$CreditGrantModelCopyWithImpl<$Res>
    implements $CreditGrantModelCopyWith<$Res> {
  _$CreditGrantModelCopyWithImpl(this._self, this._then);

  final CreditGrantModel _self;
  final $Res Function(CreditGrantModel) _then;

/// Create a copy of CreditGrantModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? memberId = null,Object? subscriptionId = freezed,Object? creditType = null,Object? branchAccessScope = null,Object? classScope = null,Object? initialAmount = null,Object? remainingAmount = null,Object? expiresAt = freezed,Object? status = null,Object? allowedBranchIds = null,Object? allowedClassTypeIds = null,}) {
  return _then(CreditGrantModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: freezed == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String?,creditType: null == creditType ? _self.creditType : creditType // ignore: cast_nullable_to_non_nullable
as CreditType,branchAccessScope: null == branchAccessScope ? _self.branchAccessScope : branchAccessScope // ignore: cast_nullable_to_non_nullable
as BranchAccessScope,classScope: null == classScope ? _self.classScope : classScope // ignore: cast_nullable_to_non_nullable
as ClassScope,initialAmount: null == initialAmount ? _self.initialAmount : initialAmount // ignore: cast_nullable_to_non_nullable
as int,remainingAmount: null == remainingAmount ? _self.remainingAmount : remainingAmount // ignore: cast_nullable_to_non_nullable
as int,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CreditGrantStatus,allowedBranchIds: null == allowedBranchIds ? _self.allowedBranchIds : allowedBranchIds // ignore: cast_nullable_to_non_nullable
as List<String>,allowedClassTypeIds: null == allowedClassTypeIds ? _self.allowedClassTypeIds : allowedClassTypeIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CreditGrantModel].
extension CreditGrantModelPatterns on CreditGrantModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreditGrantModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreditGrantModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreditGrantModel value)  $default,){
final _that = this;
switch (_that) {
case _CreditGrantModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreditGrantModel value)?  $default,){
final _that = this;
switch (_that) {
case _CreditGrantModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'subscription_id')  String? subscriptionId, @JsonKey(name: 'credit_type')  CreditType creditType, @JsonKey(name: 'branch_access_scope')  BranchAccessScope branchAccessScope, @JsonKey(name: 'class_scope')  ClassScope classScope, @JsonKey(name: 'initial_amount')  int initialAmount, @JsonKey(name: 'remaining_amount')  int remainingAmount, @JsonKey(name: 'expires_at')  DateTime? expiresAt,  CreditGrantStatus status,  List<String> allowedBranchIds,  List<String> allowedClassTypeIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditGrantModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.memberId,_that.subscriptionId,_that.creditType,_that.branchAccessScope,_that.classScope,_that.initialAmount,_that.remainingAmount,_that.expiresAt,_that.status,_that.allowedBranchIds,_that.allowedClassTypeIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'subscription_id')  String? subscriptionId, @JsonKey(name: 'credit_type')  CreditType creditType, @JsonKey(name: 'branch_access_scope')  BranchAccessScope branchAccessScope, @JsonKey(name: 'class_scope')  ClassScope classScope, @JsonKey(name: 'initial_amount')  int initialAmount, @JsonKey(name: 'remaining_amount')  int remainingAmount, @JsonKey(name: 'expires_at')  DateTime? expiresAt,  CreditGrantStatus status,  List<String> allowedBranchIds,  List<String> allowedClassTypeIds)  $default,) {final _that = this;
switch (_that) {
case _CreditGrantModel():
return $default(_that.id,_that.organizationId,_that.memberId,_that.subscriptionId,_that.creditType,_that.branchAccessScope,_that.classScope,_that.initialAmount,_that.remainingAmount,_that.expiresAt,_that.status,_that.allowedBranchIds,_that.allowedClassTypeIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'subscription_id')  String? subscriptionId, @JsonKey(name: 'credit_type')  CreditType creditType, @JsonKey(name: 'branch_access_scope')  BranchAccessScope branchAccessScope, @JsonKey(name: 'class_scope')  ClassScope classScope, @JsonKey(name: 'initial_amount')  int initialAmount, @JsonKey(name: 'remaining_amount')  int remainingAmount, @JsonKey(name: 'expires_at')  DateTime? expiresAt,  CreditGrantStatus status,  List<String> allowedBranchIds,  List<String> allowedClassTypeIds)?  $default,) {final _that = this;
switch (_that) {
case _CreditGrantModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.memberId,_that.subscriptionId,_that.creditType,_that.branchAccessScope,_that.classScope,_that.initialAmount,_that.remainingAmount,_that.expiresAt,_that.status,_that.allowedBranchIds,_that.allowedClassTypeIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreditGrantModel implements CreditGrantModel {
  const _CreditGrantModel({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'member_id') required this.memberId, @JsonKey(name: 'subscription_id') this.subscriptionId, @JsonKey(name: 'credit_type') required this.creditType, @JsonKey(name: 'branch_access_scope') required this.branchAccessScope, @JsonKey(name: 'class_scope') required this.classScope, @JsonKey(name: 'initial_amount') required this.initialAmount, @JsonKey(name: 'remaining_amount') required this.remainingAmount, @JsonKey(name: 'expires_at') this.expiresAt, required this.status,  List<String> allowedBranchIds = const <String>[],  List<String> allowedClassTypeIds = const <String>[]}): _allowedBranchIds = allowedBranchIds,_allowedClassTypeIds = allowedClassTypeIds;
  factory _CreditGrantModel.fromJson(Map<String, dynamic> json) => _$CreditGrantModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'member_id') final  String memberId;
@override@JsonKey(name: 'subscription_id') final  String? subscriptionId;
@override@JsonKey(name: 'credit_type') final  CreditType creditType;
@override@JsonKey(name: 'branch_access_scope') final  BranchAccessScope branchAccessScope;
@override@JsonKey(name: 'class_scope') final  ClassScope classScope;
@override@JsonKey(name: 'initial_amount') final  int initialAmount;
@override@JsonKey(name: 'remaining_amount') final  int remainingAmount;
@override@JsonKey(name: 'expires_at') final  DateTime? expiresAt;
@override final  CreditGrantStatus status;
 final  List<String> _allowedBranchIds;
@override@JsonKey() List<String> get allowedBranchIds {
  if (_allowedBranchIds is EqualUnmodifiableListView) return _allowedBranchIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedBranchIds);
}

 final  List<String> _allowedClassTypeIds;
@override@JsonKey() List<String> get allowedClassTypeIds {
  if (_allowedClassTypeIds is EqualUnmodifiableListView) return _allowedClassTypeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedClassTypeIds);
}


/// Create a copy of CreditGrantModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditGrantModelCopyWith<_CreditGrantModel> get copyWith => __$CreditGrantModelCopyWithImpl<_CreditGrantModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreditGrantModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditGrantModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.creditType, creditType) || other.creditType == creditType)&&(identical(other.branchAccessScope, branchAccessScope) || other.branchAccessScope == branchAccessScope)&&(identical(other.classScope, classScope) || other.classScope == classScope)&&(identical(other.initialAmount, initialAmount) || other.initialAmount == initialAmount)&&(identical(other.remainingAmount, remainingAmount) || other.remainingAmount == remainingAmount)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.allowedBranchIds, _allowedBranchIds)&&const DeepCollectionEquality().equals(other.allowedClassTypeIds, _allowedClassTypeIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,memberId,subscriptionId,creditType,branchAccessScope,classScope,initialAmount,remainingAmount,expiresAt,status,const DeepCollectionEquality().hash(_allowedBranchIds),const DeepCollectionEquality().hash(_allowedClassTypeIds));
}

@override
String toString() {
    return 'CreditGrantModel(id: $id, organizationId: $organizationId, memberId: $memberId, subscriptionId: $subscriptionId, creditType: $creditType, branchAccessScope: $branchAccessScope, classScope: $classScope, initialAmount: $initialAmount, remainingAmount: $remainingAmount, expiresAt: $expiresAt, status: $status, allowedBranchIds: $allowedBranchIds, allowedClassTypeIds: $allowedClassTypeIds)';
}


}

/// @nodoc
abstract mixin class _$CreditGrantModelCopyWith<$Res> implements $CreditGrantModelCopyWith<$Res> {
  factory _$CreditGrantModelCopyWith(_CreditGrantModel value, $Res Function(_CreditGrantModel) _then) = __$CreditGrantModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'subscription_id') String? subscriptionId,@JsonKey(name: 'credit_type') CreditType creditType,@JsonKey(name: 'branch_access_scope') BranchAccessScope branchAccessScope,@JsonKey(name: 'class_scope') ClassScope classScope,@JsonKey(name: 'initial_amount') int initialAmount,@JsonKey(name: 'remaining_amount') int remainingAmount,@JsonKey(name: 'expires_at') DateTime? expiresAt, CreditGrantStatus status, List<String> allowedBranchIds, List<String> allowedClassTypeIds
});




}
/// @nodoc
class __$CreditGrantModelCopyWithImpl<$Res>
    implements _$CreditGrantModelCopyWith<$Res> {
  __$CreditGrantModelCopyWithImpl(this._self, this._then);

  final _CreditGrantModel _self;
  final $Res Function(_CreditGrantModel) _then;

/// Create a copy of CreditGrantModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? memberId = null,Object? subscriptionId = freezed,Object? creditType = null,Object? branchAccessScope = null,Object? classScope = null,Object? initialAmount = null,Object? remainingAmount = null,Object? expiresAt = freezed,Object? status = null,Object? allowedBranchIds = null,Object? allowedClassTypeIds = null,}) {
  return _then(_CreditGrantModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: freezed == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String?,creditType: null == creditType ? _self.creditType : creditType // ignore: cast_nullable_to_non_nullable
as CreditType,branchAccessScope: null == branchAccessScope ? _self.branchAccessScope : branchAccessScope // ignore: cast_nullable_to_non_nullable
as BranchAccessScope,classScope: null == classScope ? _self.classScope : classScope // ignore: cast_nullable_to_non_nullable
as ClassScope,initialAmount: null == initialAmount ? _self.initialAmount : initialAmount // ignore: cast_nullable_to_non_nullable
as int,remainingAmount: null == remainingAmount ? _self.remainingAmount : remainingAmount // ignore: cast_nullable_to_non_nullable
as int,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CreditGrantStatus,allowedBranchIds: null == allowedBranchIds ? _self._allowedBranchIds : allowedBranchIds // ignore: cast_nullable_to_non_nullable
as List<String>,allowedClassTypeIds: null == allowedClassTypeIds ? _self._allowedClassTypeIds : allowedClassTypeIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$CreditLedgerEntryModel {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'member_id') String get memberId;@JsonKey(name: 'grant_id') String get grantId;@JsonKey(name: 'credit_type') CreditType get creditType;@JsonKey(name: 'entry_type') LedgerEntryType get entryType; int get delta;@JsonKey(name: 'reference_type') String get referenceType;@JsonKey(name: 'reference_id') String get referenceId; String? get reason;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of CreditLedgerEntryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditLedgerEntryModelCopyWith<CreditLedgerEntryModel> get copyWith => _$CreditLedgerEntryModelCopyWithImpl<CreditLedgerEntryModel>(this as CreditLedgerEntryModel, _$identity);

  /// Serializes this CreditLedgerEntryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreditLedgerEntryModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditLedgerEntryModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.memberId, _this.memberId) || other.memberId == _this.memberId)&&(identical(other.grantId, _this.grantId) || other.grantId == _this.grantId)&&(identical(other.creditType, _this.creditType) || other.creditType == _this.creditType)&&(identical(other.entryType, _this.entryType) || other.entryType == _this.entryType)&&(identical(other.delta, _this.delta) || other.delta == _this.delta)&&(identical(other.referenceType, _this.referenceType) || other.referenceType == _this.referenceType)&&(identical(other.referenceId, _this.referenceId) || other.referenceId == _this.referenceId)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreditLedgerEntryModel;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.memberId,_this.grantId,_this.creditType,_this.entryType,_this.delta,_this.referenceType,_this.referenceId,_this.reason,_this.createdAt);
}

@override
String toString() {
  final _this = this as CreditLedgerEntryModel;
  return 'CreditLedgerEntryModel(id: ${_this.id}, organizationId: ${_this.organizationId}, memberId: ${_this.memberId}, grantId: ${_this.grantId}, creditType: ${_this.creditType}, entryType: ${_this.entryType}, delta: ${_this.delta}, referenceType: ${_this.referenceType}, referenceId: ${_this.referenceId}, reason: ${_this.reason}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $CreditLedgerEntryModelCopyWith<$Res>  {
  factory $CreditLedgerEntryModelCopyWith(CreditLedgerEntryModel value, $Res Function(CreditLedgerEntryModel) _then) = _$CreditLedgerEntryModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'grant_id') String grantId,@JsonKey(name: 'credit_type') CreditType creditType,@JsonKey(name: 'entry_type') LedgerEntryType entryType, int delta,@JsonKey(name: 'reference_type') String referenceType,@JsonKey(name: 'reference_id') String referenceId, String? reason,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$CreditLedgerEntryModelCopyWithImpl<$Res>
    implements $CreditLedgerEntryModelCopyWith<$Res> {
  _$CreditLedgerEntryModelCopyWithImpl(this._self, this._then);

  final CreditLedgerEntryModel _self;
  final $Res Function(CreditLedgerEntryModel) _then;

/// Create a copy of CreditLedgerEntryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? memberId = null,Object? grantId = null,Object? creditType = null,Object? entryType = null,Object? delta = null,Object? referenceType = null,Object? referenceId = null,Object? reason = freezed,Object? createdAt = null,}) {
  return _then(CreditLedgerEntryModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,grantId: null == grantId ? _self.grantId : grantId // ignore: cast_nullable_to_non_nullable
as String,creditType: null == creditType ? _self.creditType : creditType // ignore: cast_nullable_to_non_nullable
as CreditType,entryType: null == entryType ? _self.entryType : entryType // ignore: cast_nullable_to_non_nullable
as LedgerEntryType,delta: null == delta ? _self.delta : delta // ignore: cast_nullable_to_non_nullable
as int,referenceType: null == referenceType ? _self.referenceType : referenceType // ignore: cast_nullable_to_non_nullable
as String,referenceId: null == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CreditLedgerEntryModel].
extension CreditLedgerEntryModelPatterns on CreditLedgerEntryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreditLedgerEntryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreditLedgerEntryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreditLedgerEntryModel value)  $default,){
final _that = this;
switch (_that) {
case _CreditLedgerEntryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreditLedgerEntryModel value)?  $default,){
final _that = this;
switch (_that) {
case _CreditLedgerEntryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'grant_id')  String grantId, @JsonKey(name: 'credit_type')  CreditType creditType, @JsonKey(name: 'entry_type')  LedgerEntryType entryType,  int delta, @JsonKey(name: 'reference_type')  String referenceType, @JsonKey(name: 'reference_id')  String referenceId,  String? reason, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditLedgerEntryModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.memberId,_that.grantId,_that.creditType,_that.entryType,_that.delta,_that.referenceType,_that.referenceId,_that.reason,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'grant_id')  String grantId, @JsonKey(name: 'credit_type')  CreditType creditType, @JsonKey(name: 'entry_type')  LedgerEntryType entryType,  int delta, @JsonKey(name: 'reference_type')  String referenceType, @JsonKey(name: 'reference_id')  String referenceId,  String? reason, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _CreditLedgerEntryModel():
return $default(_that.id,_that.organizationId,_that.memberId,_that.grantId,_that.creditType,_that.entryType,_that.delta,_that.referenceType,_that.referenceId,_that.reason,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'grant_id')  String grantId, @JsonKey(name: 'credit_type')  CreditType creditType, @JsonKey(name: 'entry_type')  LedgerEntryType entryType,  int delta, @JsonKey(name: 'reference_type')  String referenceType, @JsonKey(name: 'reference_id')  String referenceId,  String? reason, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CreditLedgerEntryModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.memberId,_that.grantId,_that.creditType,_that.entryType,_that.delta,_that.referenceType,_that.referenceId,_that.reason,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreditLedgerEntryModel implements CreditLedgerEntryModel {
  const _CreditLedgerEntryModel({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'member_id') required this.memberId, @JsonKey(name: 'grant_id') required this.grantId, @JsonKey(name: 'credit_type') required this.creditType, @JsonKey(name: 'entry_type') required this.entryType, required this.delta, @JsonKey(name: 'reference_type') required this.referenceType, @JsonKey(name: 'reference_id') required this.referenceId, this.reason, @JsonKey(name: 'created_at') required this.createdAt});
  factory _CreditLedgerEntryModel.fromJson(Map<String, dynamic> json) => _$CreditLedgerEntryModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'member_id') final  String memberId;
@override@JsonKey(name: 'grant_id') final  String grantId;
@override@JsonKey(name: 'credit_type') final  CreditType creditType;
@override@JsonKey(name: 'entry_type') final  LedgerEntryType entryType;
@override final  int delta;
@override@JsonKey(name: 'reference_type') final  String referenceType;
@override@JsonKey(name: 'reference_id') final  String referenceId;
@override final  String? reason;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of CreditLedgerEntryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditLedgerEntryModelCopyWith<_CreditLedgerEntryModel> get copyWith => __$CreditLedgerEntryModelCopyWithImpl<_CreditLedgerEntryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreditLedgerEntryModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditLedgerEntryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.grantId, grantId) || other.grantId == grantId)&&(identical(other.creditType, creditType) || other.creditType == creditType)&&(identical(other.entryType, entryType) || other.entryType == entryType)&&(identical(other.delta, delta) || other.delta == delta)&&(identical(other.referenceType, referenceType) || other.referenceType == referenceType)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,memberId,grantId,creditType,entryType,delta,referenceType,referenceId,reason,createdAt);
}

@override
String toString() {
    return 'CreditLedgerEntryModel(id: $id, organizationId: $organizationId, memberId: $memberId, grantId: $grantId, creditType: $creditType, entryType: $entryType, delta: $delta, referenceType: $referenceType, referenceId: $referenceId, reason: $reason, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CreditLedgerEntryModelCopyWith<$Res> implements $CreditLedgerEntryModelCopyWith<$Res> {
  factory _$CreditLedgerEntryModelCopyWith(_CreditLedgerEntryModel value, $Res Function(_CreditLedgerEntryModel) _then) = __$CreditLedgerEntryModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'grant_id') String grantId,@JsonKey(name: 'credit_type') CreditType creditType,@JsonKey(name: 'entry_type') LedgerEntryType entryType, int delta,@JsonKey(name: 'reference_type') String referenceType,@JsonKey(name: 'reference_id') String referenceId, String? reason,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$CreditLedgerEntryModelCopyWithImpl<$Res>
    implements _$CreditLedgerEntryModelCopyWith<$Res> {
  __$CreditLedgerEntryModelCopyWithImpl(this._self, this._then);

  final _CreditLedgerEntryModel _self;
  final $Res Function(_CreditLedgerEntryModel) _then;

/// Create a copy of CreditLedgerEntryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? memberId = null,Object? grantId = null,Object? creditType = null,Object? entryType = null,Object? delta = null,Object? referenceType = null,Object? referenceId = null,Object? reason = freezed,Object? createdAt = null,}) {
  return _then(_CreditLedgerEntryModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,grantId: null == grantId ? _self.grantId : grantId // ignore: cast_nullable_to_non_nullable
as String,creditType: null == creditType ? _self.creditType : creditType // ignore: cast_nullable_to_non_nullable
as CreditType,entryType: null == entryType ? _self.entryType : entryType // ignore: cast_nullable_to_non_nullable
as LedgerEntryType,delta: null == delta ? _self.delta : delta // ignore: cast_nullable_to_non_nullable
as int,referenceType: null == referenceType ? _self.referenceType : referenceType // ignore: cast_nullable_to_non_nullable
as String,referenceId: null == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
