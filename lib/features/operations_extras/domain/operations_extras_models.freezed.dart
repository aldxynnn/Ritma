// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'operations_extras_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EquipmentAssetModel {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'branch_id') String get branchId;@JsonKey(name: 'asset_code') String get assetCode; String get name; String get category; EquipmentStatus get status;@JsonKey(name: 'last_serviced_at') DateTime? get lastServicedAt;
/// Create a copy of EquipmentAssetModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EquipmentAssetModelCopyWith<EquipmentAssetModel> get copyWith => _$EquipmentAssetModelCopyWithImpl<EquipmentAssetModel>(this as EquipmentAssetModel, _$identity);

  /// Serializes this EquipmentAssetModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EquipmentAssetModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EquipmentAssetModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId)&&(identical(other.assetCode, _this.assetCode) || other.assetCode == _this.assetCode)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.lastServicedAt, _this.lastServicedAt) || other.lastServicedAt == _this.lastServicedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EquipmentAssetModel;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.branchId,_this.assetCode,_this.name,_this.category,_this.status,_this.lastServicedAt);
}

@override
String toString() {
  final _this = this as EquipmentAssetModel;
  return 'EquipmentAssetModel(id: ${_this.id}, organizationId: ${_this.organizationId}, branchId: ${_this.branchId}, assetCode: ${_this.assetCode}, name: ${_this.name}, category: ${_this.category}, status: ${_this.status}, lastServicedAt: ${_this.lastServicedAt})';
}


}

/// @nodoc
abstract mixin class $EquipmentAssetModelCopyWith<$Res>  {
  factory $EquipmentAssetModelCopyWith(EquipmentAssetModel value, $Res Function(EquipmentAssetModel) _then) = _$EquipmentAssetModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'branch_id') String branchId,@JsonKey(name: 'asset_code') String assetCode, String name, String category, EquipmentStatus status,@JsonKey(name: 'last_serviced_at') DateTime? lastServicedAt
});




}
/// @nodoc
class _$EquipmentAssetModelCopyWithImpl<$Res>
    implements $EquipmentAssetModelCopyWith<$Res> {
  _$EquipmentAssetModelCopyWithImpl(this._self, this._then);

  final EquipmentAssetModel _self;
  final $Res Function(EquipmentAssetModel) _then;

/// Create a copy of EquipmentAssetModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? branchId = null,Object? assetCode = null,Object? name = null,Object? category = null,Object? status = null,Object? lastServicedAt = freezed,}) {
  return _then(EquipmentAssetModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,assetCode: null == assetCode ? _self.assetCode : assetCode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EquipmentStatus,lastServicedAt: freezed == lastServicedAt ? _self.lastServicedAt : lastServicedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EquipmentAssetModel].
extension EquipmentAssetModelPatterns on EquipmentAssetModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EquipmentAssetModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EquipmentAssetModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EquipmentAssetModel value)  $default,){
final _that = this;
switch (_that) {
case _EquipmentAssetModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EquipmentAssetModel value)?  $default,){
final _that = this;
switch (_that) {
case _EquipmentAssetModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'asset_code')  String assetCode,  String name,  String category,  EquipmentStatus status, @JsonKey(name: 'last_serviced_at')  DateTime? lastServicedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EquipmentAssetModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.branchId,_that.assetCode,_that.name,_that.category,_that.status,_that.lastServicedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'asset_code')  String assetCode,  String name,  String category,  EquipmentStatus status, @JsonKey(name: 'last_serviced_at')  DateTime? lastServicedAt)  $default,) {final _that = this;
switch (_that) {
case _EquipmentAssetModel():
return $default(_that.id,_that.organizationId,_that.branchId,_that.assetCode,_that.name,_that.category,_that.status,_that.lastServicedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'asset_code')  String assetCode,  String name,  String category,  EquipmentStatus status, @JsonKey(name: 'last_serviced_at')  DateTime? lastServicedAt)?  $default,) {final _that = this;
switch (_that) {
case _EquipmentAssetModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.branchId,_that.assetCode,_that.name,_that.category,_that.status,_that.lastServicedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EquipmentAssetModel implements EquipmentAssetModel {
  const _EquipmentAssetModel({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'branch_id') required this.branchId, @JsonKey(name: 'asset_code') required this.assetCode, required this.name, required this.category, this.status = EquipmentStatus.operational, @JsonKey(name: 'last_serviced_at') this.lastServicedAt});
  factory _EquipmentAssetModel.fromJson(Map<String, dynamic> json) => _$EquipmentAssetModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'branch_id') final  String branchId;
@override@JsonKey(name: 'asset_code') final  String assetCode;
@override final  String name;
@override final  String category;
@override@JsonKey() final  EquipmentStatus status;
@override@JsonKey(name: 'last_serviced_at') final  DateTime? lastServicedAt;

/// Create a copy of EquipmentAssetModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EquipmentAssetModelCopyWith<_EquipmentAssetModel> get copyWith => __$EquipmentAssetModelCopyWithImpl<_EquipmentAssetModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EquipmentAssetModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EquipmentAssetModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.assetCode, assetCode) || other.assetCode == assetCode)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastServicedAt, lastServicedAt) || other.lastServicedAt == lastServicedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,branchId,assetCode,name,category,status,lastServicedAt);
}

@override
String toString() {
    return 'EquipmentAssetModel(id: $id, organizationId: $organizationId, branchId: $branchId, assetCode: $assetCode, name: $name, category: $category, status: $status, lastServicedAt: $lastServicedAt)';
}


}

/// @nodoc
abstract mixin class _$EquipmentAssetModelCopyWith<$Res> implements $EquipmentAssetModelCopyWith<$Res> {
  factory _$EquipmentAssetModelCopyWith(_EquipmentAssetModel value, $Res Function(_EquipmentAssetModel) _then) = __$EquipmentAssetModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'branch_id') String branchId,@JsonKey(name: 'asset_code') String assetCode, String name, String category, EquipmentStatus status,@JsonKey(name: 'last_serviced_at') DateTime? lastServicedAt
});




}
/// @nodoc
class __$EquipmentAssetModelCopyWithImpl<$Res>
    implements _$EquipmentAssetModelCopyWith<$Res> {
  __$EquipmentAssetModelCopyWithImpl(this._self, this._then);

  final _EquipmentAssetModel _self;
  final $Res Function(_EquipmentAssetModel) _then;

/// Create a copy of EquipmentAssetModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? branchId = null,Object? assetCode = null,Object? name = null,Object? category = null,Object? status = null,Object? lastServicedAt = freezed,}) {
  return _then(_EquipmentAssetModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,assetCode: null == assetCode ? _self.assetCode : assetCode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EquipmentStatus,lastServicedAt: freezed == lastServicedAt ? _self.lastServicedAt : lastServicedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$MaintenanceTicketModel {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'branch_id') String get branchId;@JsonKey(name: 'asset_id') String get assetId; String get summary; TicketPriority get priority; TicketStatus get status;@JsonKey(name: 'resolved_at') DateTime? get resolvedAt;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of MaintenanceTicketModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaintenanceTicketModelCopyWith<MaintenanceTicketModel> get copyWith => _$MaintenanceTicketModelCopyWithImpl<MaintenanceTicketModel>(this as MaintenanceTicketModel, _$identity);

  /// Serializes this MaintenanceTicketModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MaintenanceTicketModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaintenanceTicketModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId)&&(identical(other.assetId, _this.assetId) || other.assetId == _this.assetId)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.resolvedAt, _this.resolvedAt) || other.resolvedAt == _this.resolvedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MaintenanceTicketModel;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.branchId,_this.assetId,_this.summary,_this.priority,_this.status,_this.resolvedAt,_this.createdAt);
}

@override
String toString() {
  final _this = this as MaintenanceTicketModel;
  return 'MaintenanceTicketModel(id: ${_this.id}, organizationId: ${_this.organizationId}, branchId: ${_this.branchId}, assetId: ${_this.assetId}, summary: ${_this.summary}, priority: ${_this.priority}, status: ${_this.status}, resolvedAt: ${_this.resolvedAt}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $MaintenanceTicketModelCopyWith<$Res>  {
  factory $MaintenanceTicketModelCopyWith(MaintenanceTicketModel value, $Res Function(MaintenanceTicketModel) _then) = _$MaintenanceTicketModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'branch_id') String branchId,@JsonKey(name: 'asset_id') String assetId, String summary, TicketPriority priority, TicketStatus status,@JsonKey(name: 'resolved_at') DateTime? resolvedAt,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$MaintenanceTicketModelCopyWithImpl<$Res>
    implements $MaintenanceTicketModelCopyWith<$Res> {
  _$MaintenanceTicketModelCopyWithImpl(this._self, this._then);

  final MaintenanceTicketModel _self;
  final $Res Function(MaintenanceTicketModel) _then;

/// Create a copy of MaintenanceTicketModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? branchId = null,Object? assetId = null,Object? summary = null,Object? priority = null,Object? status = null,Object? resolvedAt = freezed,Object? createdAt = null,}) {
  return _then(MaintenanceTicketModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TicketPriority,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TicketStatus,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MaintenanceTicketModel].
extension MaintenanceTicketModelPatterns on MaintenanceTicketModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaintenanceTicketModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaintenanceTicketModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaintenanceTicketModel value)  $default,){
final _that = this;
switch (_that) {
case _MaintenanceTicketModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaintenanceTicketModel value)?  $default,){
final _that = this;
switch (_that) {
case _MaintenanceTicketModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'asset_id')  String assetId,  String summary,  TicketPriority priority,  TicketStatus status, @JsonKey(name: 'resolved_at')  DateTime? resolvedAt, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaintenanceTicketModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.branchId,_that.assetId,_that.summary,_that.priority,_that.status,_that.resolvedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'asset_id')  String assetId,  String summary,  TicketPriority priority,  TicketStatus status, @JsonKey(name: 'resolved_at')  DateTime? resolvedAt, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _MaintenanceTicketModel():
return $default(_that.id,_that.organizationId,_that.branchId,_that.assetId,_that.summary,_that.priority,_that.status,_that.resolvedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'asset_id')  String assetId,  String summary,  TicketPriority priority,  TicketStatus status, @JsonKey(name: 'resolved_at')  DateTime? resolvedAt, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MaintenanceTicketModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.branchId,_that.assetId,_that.summary,_that.priority,_that.status,_that.resolvedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MaintenanceTicketModel implements MaintenanceTicketModel {
  const _MaintenanceTicketModel({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'branch_id') required this.branchId, @JsonKey(name: 'asset_id') required this.assetId, required this.summary, this.priority = TicketPriority.normal, this.status = TicketStatus.open, @JsonKey(name: 'resolved_at') this.resolvedAt, @JsonKey(name: 'created_at') required this.createdAt});
  factory _MaintenanceTicketModel.fromJson(Map<String, dynamic> json) => _$MaintenanceTicketModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'branch_id') final  String branchId;
@override@JsonKey(name: 'asset_id') final  String assetId;
@override final  String summary;
@override@JsonKey() final  TicketPriority priority;
@override@JsonKey() final  TicketStatus status;
@override@JsonKey(name: 'resolved_at') final  DateTime? resolvedAt;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of MaintenanceTicketModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaintenanceTicketModelCopyWith<_MaintenanceTicketModel> get copyWith => __$MaintenanceTicketModelCopyWithImpl<_MaintenanceTicketModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaintenanceTicketModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaintenanceTicketModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,branchId,assetId,summary,priority,status,resolvedAt,createdAt);
}

@override
String toString() {
    return 'MaintenanceTicketModel(id: $id, organizationId: $organizationId, branchId: $branchId, assetId: $assetId, summary: $summary, priority: $priority, status: $status, resolvedAt: $resolvedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MaintenanceTicketModelCopyWith<$Res> implements $MaintenanceTicketModelCopyWith<$Res> {
  factory _$MaintenanceTicketModelCopyWith(_MaintenanceTicketModel value, $Res Function(_MaintenanceTicketModel) _then) = __$MaintenanceTicketModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'branch_id') String branchId,@JsonKey(name: 'asset_id') String assetId, String summary, TicketPriority priority, TicketStatus status,@JsonKey(name: 'resolved_at') DateTime? resolvedAt,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$MaintenanceTicketModelCopyWithImpl<$Res>
    implements _$MaintenanceTicketModelCopyWith<$Res> {
  __$MaintenanceTicketModelCopyWithImpl(this._self, this._then);

  final _MaintenanceTicketModel _self;
  final $Res Function(_MaintenanceTicketModel) _then;

/// Create a copy of MaintenanceTicketModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? branchId = null,Object? assetId = null,Object? summary = null,Object? priority = null,Object? status = null,Object? resolvedAt = freezed,Object? createdAt = null,}) {
  return _then(_MaintenanceTicketModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TicketPriority,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TicketStatus,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$UserNotificationModel {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'user_id') String get userId; String get title; String get body; String get category;@JsonKey(name: 'read_at') DateTime? get readAt;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of UserNotificationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserNotificationModelCopyWith<UserNotificationModel> get copyWith => _$UserNotificationModelCopyWithImpl<UserNotificationModel>(this as UserNotificationModel, _$identity);

  /// Serializes this UserNotificationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserNotificationModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserNotificationModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.readAt, _this.readAt) || other.readAt == _this.readAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserNotificationModel;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.userId,_this.title,_this.body,_this.category,_this.readAt,_this.createdAt);
}

@override
String toString() {
  final _this = this as UserNotificationModel;
  return 'UserNotificationModel(id: ${_this.id}, organizationId: ${_this.organizationId}, userId: ${_this.userId}, title: ${_this.title}, body: ${_this.body}, category: ${_this.category}, readAt: ${_this.readAt}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $UserNotificationModelCopyWith<$Res>  {
  factory $UserNotificationModelCopyWith(UserNotificationModel value, $Res Function(UserNotificationModel) _then) = _$UserNotificationModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'user_id') String userId, String title, String body, String category,@JsonKey(name: 'read_at') DateTime? readAt,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$UserNotificationModelCopyWithImpl<$Res>
    implements $UserNotificationModelCopyWith<$Res> {
  _$UserNotificationModelCopyWithImpl(this._self, this._then);

  final UserNotificationModel _self;
  final $Res Function(UserNotificationModel) _then;

/// Create a copy of UserNotificationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? userId = null,Object? title = null,Object? body = null,Object? category = null,Object? readAt = freezed,Object? createdAt = null,}) {
  return _then(UserNotificationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [UserNotificationModel].
extension UserNotificationModelPatterns on UserNotificationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserNotificationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserNotificationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserNotificationModel value)  $default,){
final _that = this;
switch (_that) {
case _UserNotificationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserNotificationModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserNotificationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'user_id')  String userId,  String title,  String body,  String category, @JsonKey(name: 'read_at')  DateTime? readAt, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserNotificationModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.userId,_that.title,_that.body,_that.category,_that.readAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'user_id')  String userId,  String title,  String body,  String category, @JsonKey(name: 'read_at')  DateTime? readAt, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _UserNotificationModel():
return $default(_that.id,_that.organizationId,_that.userId,_that.title,_that.body,_that.category,_that.readAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'user_id')  String userId,  String title,  String body,  String category, @JsonKey(name: 'read_at')  DateTime? readAt, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _UserNotificationModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.userId,_that.title,_that.body,_that.category,_that.readAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserNotificationModel implements UserNotificationModel {
  const _UserNotificationModel({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'user_id') required this.userId, required this.title, required this.body, required this.category, @JsonKey(name: 'read_at') this.readAt, @JsonKey(name: 'created_at') required this.createdAt});
  factory _UserNotificationModel.fromJson(Map<String, dynamic> json) => _$UserNotificationModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String title;
@override final  String body;
@override final  String category;
@override@JsonKey(name: 'read_at') final  DateTime? readAt;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of UserNotificationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserNotificationModelCopyWith<_UserNotificationModel> get copyWith => __$UserNotificationModelCopyWithImpl<_UserNotificationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserNotificationModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserNotificationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.category, category) || other.category == category)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,userId,title,body,category,readAt,createdAt);
}

@override
String toString() {
    return 'UserNotificationModel(id: $id, organizationId: $organizationId, userId: $userId, title: $title, body: $body, category: $category, readAt: $readAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$UserNotificationModelCopyWith<$Res> implements $UserNotificationModelCopyWith<$Res> {
  factory _$UserNotificationModelCopyWith(_UserNotificationModel value, $Res Function(_UserNotificationModel) _then) = __$UserNotificationModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'user_id') String userId, String title, String body, String category,@JsonKey(name: 'read_at') DateTime? readAt,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$UserNotificationModelCopyWithImpl<$Res>
    implements _$UserNotificationModelCopyWith<$Res> {
  __$UserNotificationModelCopyWithImpl(this._self, this._then);

  final _UserNotificationModel _self;
  final $Res Function(_UserNotificationModel) _then;

/// Create a copy of UserNotificationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? userId = null,Object? title = null,Object? body = null,Object? category = null,Object? readAt = freezed,Object? createdAt = null,}) {
  return _then(_UserNotificationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
