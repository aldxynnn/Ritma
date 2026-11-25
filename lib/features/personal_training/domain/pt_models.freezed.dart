// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pt_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrainerProfileModel {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'home_branch_id') String get homeBranchId; String get bio; List<String> get specialties;@JsonKey(name: 'default_credit_cost') int get defaultCreditCost;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'display_name') String get displayName;
/// Create a copy of TrainerProfileModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainerProfileModelCopyWith<TrainerProfileModel> get copyWith => _$TrainerProfileModelCopyWithImpl<TrainerProfileModel>(this as TrainerProfileModel, _$identity);

  /// Serializes this TrainerProfileModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TrainerProfileModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainerProfileModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.homeBranchId, _this.homeBranchId) || other.homeBranchId == _this.homeBranchId)&&(identical(other.bio, _this.bio) || other.bio == _this.bio)&&const DeepCollectionEquality().equals(other.specialties, _this.specialties)&&(identical(other.defaultCreditCost, _this.defaultCreditCost) || other.defaultCreditCost == _this.defaultCreditCost)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TrainerProfileModel;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.userId,_this.homeBranchId,_this.bio,const DeepCollectionEquality().hash(_this.specialties),_this.defaultCreditCost,_this.isActive,_this.displayName);
}

@override
String toString() {
  final _this = this as TrainerProfileModel;
  return 'TrainerProfileModel(id: ${_this.id}, organizationId: ${_this.organizationId}, userId: ${_this.userId}, homeBranchId: ${_this.homeBranchId}, bio: ${_this.bio}, specialties: ${_this.specialties}, defaultCreditCost: ${_this.defaultCreditCost}, isActive: ${_this.isActive}, displayName: ${_this.displayName})';
}


}

/// @nodoc
abstract mixin class $TrainerProfileModelCopyWith<$Res>  {
  factory $TrainerProfileModelCopyWith(TrainerProfileModel value, $Res Function(TrainerProfileModel) _then) = _$TrainerProfileModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'home_branch_id') String homeBranchId, String bio, List<String> specialties,@JsonKey(name: 'default_credit_cost') int defaultCreditCost,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'display_name') String displayName
});




}
/// @nodoc
class _$TrainerProfileModelCopyWithImpl<$Res>
    implements $TrainerProfileModelCopyWith<$Res> {
  _$TrainerProfileModelCopyWithImpl(this._self, this._then);

  final TrainerProfileModel _self;
  final $Res Function(TrainerProfileModel) _then;

/// Create a copy of TrainerProfileModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? userId = null,Object? homeBranchId = null,Object? bio = null,Object? specialties = null,Object? defaultCreditCost = null,Object? isActive = null,Object? displayName = null,}) {
  return _then(TrainerProfileModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,homeBranchId: null == homeBranchId ? _self.homeBranchId : homeBranchId // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,specialties: null == specialties ? _self.specialties : specialties // ignore: cast_nullable_to_non_nullable
as List<String>,defaultCreditCost: null == defaultCreditCost ? _self.defaultCreditCost : defaultCreditCost // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainerProfileModel].
extension TrainerProfileModelPatterns on TrainerProfileModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainerProfileModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainerProfileModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainerProfileModel value)  $default,){
final _that = this;
switch (_that) {
case _TrainerProfileModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainerProfileModel value)?  $default,){
final _that = this;
switch (_that) {
case _TrainerProfileModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'home_branch_id')  String homeBranchId,  String bio,  List<String> specialties, @JsonKey(name: 'default_credit_cost')  int defaultCreditCost, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'display_name')  String displayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainerProfileModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.userId,_that.homeBranchId,_that.bio,_that.specialties,_that.defaultCreditCost,_that.isActive,_that.displayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'home_branch_id')  String homeBranchId,  String bio,  List<String> specialties, @JsonKey(name: 'default_credit_cost')  int defaultCreditCost, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'display_name')  String displayName)  $default,) {final _that = this;
switch (_that) {
case _TrainerProfileModel():
return $default(_that.id,_that.organizationId,_that.userId,_that.homeBranchId,_that.bio,_that.specialties,_that.defaultCreditCost,_that.isActive,_that.displayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'home_branch_id')  String homeBranchId,  String bio,  List<String> specialties, @JsonKey(name: 'default_credit_cost')  int defaultCreditCost, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'display_name')  String displayName)?  $default,) {final _that = this;
switch (_that) {
case _TrainerProfileModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.userId,_that.homeBranchId,_that.bio,_that.specialties,_that.defaultCreditCost,_that.isActive,_that.displayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainerProfileModel implements TrainerProfileModel {
  const _TrainerProfileModel({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'home_branch_id') required this.homeBranchId, this.bio = '',  List<String> specialties = const <String>[], @JsonKey(name: 'default_credit_cost') this.defaultCreditCost = 1, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'display_name') this.displayName = ''}): _specialties = specialties;
  factory _TrainerProfileModel.fromJson(Map<String, dynamic> json) => _$TrainerProfileModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'home_branch_id') final  String homeBranchId;
@override@JsonKey() final  String bio;
 final  List<String> _specialties;
@override@JsonKey() List<String> get specialties {
  if (_specialties is EqualUnmodifiableListView) return _specialties;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_specialties);
}

@override@JsonKey(name: 'default_credit_cost') final  int defaultCreditCost;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'display_name') final  String displayName;

/// Create a copy of TrainerProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainerProfileModelCopyWith<_TrainerProfileModel> get copyWith => __$TrainerProfileModelCopyWithImpl<_TrainerProfileModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainerProfileModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainerProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.homeBranchId, homeBranchId) || other.homeBranchId == homeBranchId)&&(identical(other.bio, bio) || other.bio == bio)&&const DeepCollectionEquality().equals(other.specialties, _specialties)&&(identical(other.defaultCreditCost, defaultCreditCost) || other.defaultCreditCost == defaultCreditCost)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,userId,homeBranchId,bio,const DeepCollectionEquality().hash(_specialties),defaultCreditCost,isActive,displayName);
}

@override
String toString() {
    return 'TrainerProfileModel(id: $id, organizationId: $organizationId, userId: $userId, homeBranchId: $homeBranchId, bio: $bio, specialties: $specialties, defaultCreditCost: $defaultCreditCost, isActive: $isActive, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class _$TrainerProfileModelCopyWith<$Res> implements $TrainerProfileModelCopyWith<$Res> {
  factory _$TrainerProfileModelCopyWith(_TrainerProfileModel value, $Res Function(_TrainerProfileModel) _then) = __$TrainerProfileModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'home_branch_id') String homeBranchId, String bio, List<String> specialties,@JsonKey(name: 'default_credit_cost') int defaultCreditCost,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'display_name') String displayName
});




}
/// @nodoc
class __$TrainerProfileModelCopyWithImpl<$Res>
    implements _$TrainerProfileModelCopyWith<$Res> {
  __$TrainerProfileModelCopyWithImpl(this._self, this._then);

  final _TrainerProfileModel _self;
  final $Res Function(_TrainerProfileModel) _then;

/// Create a copy of TrainerProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? userId = null,Object? homeBranchId = null,Object? bio = null,Object? specialties = null,Object? defaultCreditCost = null,Object? isActive = null,Object? displayName = null,}) {
  return _then(_TrainerProfileModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,homeBranchId: null == homeBranchId ? _self.homeBranchId : homeBranchId // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,specialties: null == specialties ? _self._specialties : specialties // ignore: cast_nullable_to_non_nullable
as List<String>,defaultCreditCost: null == defaultCreditCost ? _self.defaultCreditCost : defaultCreditCost // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TrainerAvailabilityModel {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'branch_id') String get branchId;@JsonKey(name: 'trainer_id') String get trainerId; int get weekday;@JsonKey(name: 'start_time') String get startTime;@JsonKey(name: 'end_time') String get endTime;
/// Create a copy of TrainerAvailabilityModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainerAvailabilityModelCopyWith<TrainerAvailabilityModel> get copyWith => _$TrainerAvailabilityModelCopyWithImpl<TrainerAvailabilityModel>(this as TrainerAvailabilityModel, _$identity);

  /// Serializes this TrainerAvailabilityModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TrainerAvailabilityModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainerAvailabilityModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId)&&(identical(other.trainerId, _this.trainerId) || other.trainerId == _this.trainerId)&&(identical(other.weekday, _this.weekday) || other.weekday == _this.weekday)&&(identical(other.startTime, _this.startTime) || other.startTime == _this.startTime)&&(identical(other.endTime, _this.endTime) || other.endTime == _this.endTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TrainerAvailabilityModel;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.branchId,_this.trainerId,_this.weekday,_this.startTime,_this.endTime);
}

@override
String toString() {
  final _this = this as TrainerAvailabilityModel;
  return 'TrainerAvailabilityModel(id: ${_this.id}, organizationId: ${_this.organizationId}, branchId: ${_this.branchId}, trainerId: ${_this.trainerId}, weekday: ${_this.weekday}, startTime: ${_this.startTime}, endTime: ${_this.endTime})';
}


}

/// @nodoc
abstract mixin class $TrainerAvailabilityModelCopyWith<$Res>  {
  factory $TrainerAvailabilityModelCopyWith(TrainerAvailabilityModel value, $Res Function(TrainerAvailabilityModel) _then) = _$TrainerAvailabilityModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'branch_id') String branchId,@JsonKey(name: 'trainer_id') String trainerId, int weekday,@JsonKey(name: 'start_time') String startTime,@JsonKey(name: 'end_time') String endTime
});




}
/// @nodoc
class _$TrainerAvailabilityModelCopyWithImpl<$Res>
    implements $TrainerAvailabilityModelCopyWith<$Res> {
  _$TrainerAvailabilityModelCopyWithImpl(this._self, this._then);

  final TrainerAvailabilityModel _self;
  final $Res Function(TrainerAvailabilityModel) _then;

/// Create a copy of TrainerAvailabilityModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? branchId = null,Object? trainerId = null,Object? weekday = null,Object? startTime = null,Object? endTime = null,}) {
  return _then(TrainerAvailabilityModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,weekday: null == weekday ? _self.weekday : weekday // ignore: cast_nullable_to_non_nullable
as int,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainerAvailabilityModel].
extension TrainerAvailabilityModelPatterns on TrainerAvailabilityModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainerAvailabilityModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainerAvailabilityModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainerAvailabilityModel value)  $default,){
final _that = this;
switch (_that) {
case _TrainerAvailabilityModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainerAvailabilityModel value)?  $default,){
final _that = this;
switch (_that) {
case _TrainerAvailabilityModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'trainer_id')  String trainerId,  int weekday, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'end_time')  String endTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainerAvailabilityModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.branchId,_that.trainerId,_that.weekday,_that.startTime,_that.endTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'trainer_id')  String trainerId,  int weekday, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'end_time')  String endTime)  $default,) {final _that = this;
switch (_that) {
case _TrainerAvailabilityModel():
return $default(_that.id,_that.organizationId,_that.branchId,_that.trainerId,_that.weekday,_that.startTime,_that.endTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'trainer_id')  String trainerId,  int weekday, @JsonKey(name: 'start_time')  String startTime, @JsonKey(name: 'end_time')  String endTime)?  $default,) {final _that = this;
switch (_that) {
case _TrainerAvailabilityModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.branchId,_that.trainerId,_that.weekday,_that.startTime,_that.endTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainerAvailabilityModel implements TrainerAvailabilityModel {
  const _TrainerAvailabilityModel({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'branch_id') required this.branchId, @JsonKey(name: 'trainer_id') required this.trainerId, required this.weekday, @JsonKey(name: 'start_time') required this.startTime, @JsonKey(name: 'end_time') required this.endTime});
  factory _TrainerAvailabilityModel.fromJson(Map<String, dynamic> json) => _$TrainerAvailabilityModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'branch_id') final  String branchId;
@override@JsonKey(name: 'trainer_id') final  String trainerId;
@override final  int weekday;
@override@JsonKey(name: 'start_time') final  String startTime;
@override@JsonKey(name: 'end_time') final  String endTime;

/// Create a copy of TrainerAvailabilityModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainerAvailabilityModelCopyWith<_TrainerAvailabilityModel> get copyWith => __$TrainerAvailabilityModelCopyWithImpl<_TrainerAvailabilityModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainerAvailabilityModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainerAvailabilityModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.weekday, weekday) || other.weekday == weekday)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,branchId,trainerId,weekday,startTime,endTime);
}

@override
String toString() {
    return 'TrainerAvailabilityModel(id: $id, organizationId: $organizationId, branchId: $branchId, trainerId: $trainerId, weekday: $weekday, startTime: $startTime, endTime: $endTime)';
}


}

/// @nodoc
abstract mixin class _$TrainerAvailabilityModelCopyWith<$Res> implements $TrainerAvailabilityModelCopyWith<$Res> {
  factory _$TrainerAvailabilityModelCopyWith(_TrainerAvailabilityModel value, $Res Function(_TrainerAvailabilityModel) _then) = __$TrainerAvailabilityModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'branch_id') String branchId,@JsonKey(name: 'trainer_id') String trainerId, int weekday,@JsonKey(name: 'start_time') String startTime,@JsonKey(name: 'end_time') String endTime
});




}
/// @nodoc
class __$TrainerAvailabilityModelCopyWithImpl<$Res>
    implements _$TrainerAvailabilityModelCopyWith<$Res> {
  __$TrainerAvailabilityModelCopyWithImpl(this._self, this._then);

  final _TrainerAvailabilityModel _self;
  final $Res Function(_TrainerAvailabilityModel) _then;

/// Create a copy of TrainerAvailabilityModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? branchId = null,Object? trainerId = null,Object? weekday = null,Object? startTime = null,Object? endTime = null,}) {
  return _then(_TrainerAvailabilityModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,weekday: null == weekday ? _self.weekday : weekday // ignore: cast_nullable_to_non_nullable
as int,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PtSessionModel {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'branch_id') String get branchId;@JsonKey(name: 'trainer_id') String get trainerId;@JsonKey(name: 'trainer_user_id') String? get trainerUserId;@JsonKey(name: 'member_id') String get memberId;@JsonKey(name: 'starts_at') DateTime get startsAt;@JsonKey(name: 'ends_at') DateTime get endsAt;@JsonKey(name: 'credit_cost') int get creditCost; PtSessionStatus get status; String? get notes;@JsonKey(name: 'trainer_display_name') String get trainerDisplayName;@JsonKey(name: 'member_display_name') String get memberDisplayName;@JsonKey(name: 'member_code') String get memberCode;
/// Create a copy of PtSessionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PtSessionModelCopyWith<PtSessionModel> get copyWith => _$PtSessionModelCopyWithImpl<PtSessionModel>(this as PtSessionModel, _$identity);

  /// Serializes this PtSessionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PtSessionModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PtSessionModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId)&&(identical(other.trainerId, _this.trainerId) || other.trainerId == _this.trainerId)&&(identical(other.trainerUserId, _this.trainerUserId) || other.trainerUserId == _this.trainerUserId)&&(identical(other.memberId, _this.memberId) || other.memberId == _this.memberId)&&(identical(other.startsAt, _this.startsAt) || other.startsAt == _this.startsAt)&&(identical(other.endsAt, _this.endsAt) || other.endsAt == _this.endsAt)&&(identical(other.creditCost, _this.creditCost) || other.creditCost == _this.creditCost)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.trainerDisplayName, _this.trainerDisplayName) || other.trainerDisplayName == _this.trainerDisplayName)&&(identical(other.memberDisplayName, _this.memberDisplayName) || other.memberDisplayName == _this.memberDisplayName)&&(identical(other.memberCode, _this.memberCode) || other.memberCode == _this.memberCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PtSessionModel;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.branchId,_this.trainerId,_this.trainerUserId,_this.memberId,_this.startsAt,_this.endsAt,_this.creditCost,_this.status,_this.notes,_this.trainerDisplayName,_this.memberDisplayName,_this.memberCode);
}

@override
String toString() {
  final _this = this as PtSessionModel;
  return 'PtSessionModel(id: ${_this.id}, organizationId: ${_this.organizationId}, branchId: ${_this.branchId}, trainerId: ${_this.trainerId}, trainerUserId: ${_this.trainerUserId}, memberId: ${_this.memberId}, startsAt: ${_this.startsAt}, endsAt: ${_this.endsAt}, creditCost: ${_this.creditCost}, status: ${_this.status}, notes: ${_this.notes}, trainerDisplayName: ${_this.trainerDisplayName}, memberDisplayName: ${_this.memberDisplayName}, memberCode: ${_this.memberCode})';
}


}

/// @nodoc
abstract mixin class $PtSessionModelCopyWith<$Res>  {
  factory $PtSessionModelCopyWith(PtSessionModel value, $Res Function(PtSessionModel) _then) = _$PtSessionModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'branch_id') String branchId,@JsonKey(name: 'trainer_id') String trainerId,@JsonKey(name: 'trainer_user_id') String? trainerUserId,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'starts_at') DateTime startsAt,@JsonKey(name: 'ends_at') DateTime endsAt,@JsonKey(name: 'credit_cost') int creditCost, PtSessionStatus status, String? notes,@JsonKey(name: 'trainer_display_name') String trainerDisplayName,@JsonKey(name: 'member_display_name') String memberDisplayName,@JsonKey(name: 'member_code') String memberCode
});




}
/// @nodoc
class _$PtSessionModelCopyWithImpl<$Res>
    implements $PtSessionModelCopyWith<$Res> {
  _$PtSessionModelCopyWithImpl(this._self, this._then);

  final PtSessionModel _self;
  final $Res Function(PtSessionModel) _then;

/// Create a copy of PtSessionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? branchId = null,Object? trainerId = null,Object? trainerUserId = freezed,Object? memberId = null,Object? startsAt = null,Object? endsAt = null,Object? creditCost = null,Object? status = null,Object? notes = freezed,Object? trainerDisplayName = null,Object? memberDisplayName = null,Object? memberCode = null,}) {
  return _then(PtSessionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,trainerUserId: freezed == trainerUserId ? _self.trainerUserId : trainerUserId // ignore: cast_nullable_to_non_nullable
as String?,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,endsAt: null == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime,creditCost: null == creditCost ? _self.creditCost : creditCost // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PtSessionStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,trainerDisplayName: null == trainerDisplayName ? _self.trainerDisplayName : trainerDisplayName // ignore: cast_nullable_to_non_nullable
as String,memberDisplayName: null == memberDisplayName ? _self.memberDisplayName : memberDisplayName // ignore: cast_nullable_to_non_nullable
as String,memberCode: null == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PtSessionModel].
extension PtSessionModelPatterns on PtSessionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PtSessionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PtSessionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PtSessionModel value)  $default,){
final _that = this;
switch (_that) {
case _PtSessionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PtSessionModel value)?  $default,){
final _that = this;
switch (_that) {
case _PtSessionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'trainer_id')  String trainerId, @JsonKey(name: 'trainer_user_id')  String? trainerUserId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'starts_at')  DateTime startsAt, @JsonKey(name: 'ends_at')  DateTime endsAt, @JsonKey(name: 'credit_cost')  int creditCost,  PtSessionStatus status,  String? notes, @JsonKey(name: 'trainer_display_name')  String trainerDisplayName, @JsonKey(name: 'member_display_name')  String memberDisplayName, @JsonKey(name: 'member_code')  String memberCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PtSessionModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.branchId,_that.trainerId,_that.trainerUserId,_that.memberId,_that.startsAt,_that.endsAt,_that.creditCost,_that.status,_that.notes,_that.trainerDisplayName,_that.memberDisplayName,_that.memberCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'trainer_id')  String trainerId, @JsonKey(name: 'trainer_user_id')  String? trainerUserId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'starts_at')  DateTime startsAt, @JsonKey(name: 'ends_at')  DateTime endsAt, @JsonKey(name: 'credit_cost')  int creditCost,  PtSessionStatus status,  String? notes, @JsonKey(name: 'trainer_display_name')  String trainerDisplayName, @JsonKey(name: 'member_display_name')  String memberDisplayName, @JsonKey(name: 'member_code')  String memberCode)  $default,) {final _that = this;
switch (_that) {
case _PtSessionModel():
return $default(_that.id,_that.organizationId,_that.branchId,_that.trainerId,_that.trainerUserId,_that.memberId,_that.startsAt,_that.endsAt,_that.creditCost,_that.status,_that.notes,_that.trainerDisplayName,_that.memberDisplayName,_that.memberCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'trainer_id')  String trainerId, @JsonKey(name: 'trainer_user_id')  String? trainerUserId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'starts_at')  DateTime startsAt, @JsonKey(name: 'ends_at')  DateTime endsAt, @JsonKey(name: 'credit_cost')  int creditCost,  PtSessionStatus status,  String? notes, @JsonKey(name: 'trainer_display_name')  String trainerDisplayName, @JsonKey(name: 'member_display_name')  String memberDisplayName, @JsonKey(name: 'member_code')  String memberCode)?  $default,) {final _that = this;
switch (_that) {
case _PtSessionModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.branchId,_that.trainerId,_that.trainerUserId,_that.memberId,_that.startsAt,_that.endsAt,_that.creditCost,_that.status,_that.notes,_that.trainerDisplayName,_that.memberDisplayName,_that.memberCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PtSessionModel implements PtSessionModel {
  const _PtSessionModel({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'branch_id') required this.branchId, @JsonKey(name: 'trainer_id') required this.trainerId, @JsonKey(name: 'trainer_user_id') this.trainerUserId, @JsonKey(name: 'member_id') required this.memberId, @JsonKey(name: 'starts_at') required this.startsAt, @JsonKey(name: 'ends_at') required this.endsAt, @JsonKey(name: 'credit_cost') this.creditCost = 1, this.status = PtSessionStatus.scheduled, this.notes, @JsonKey(name: 'trainer_display_name') this.trainerDisplayName = '', @JsonKey(name: 'member_display_name') this.memberDisplayName = '', @JsonKey(name: 'member_code') this.memberCode = ''});
  factory _PtSessionModel.fromJson(Map<String, dynamic> json) => _$PtSessionModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'branch_id') final  String branchId;
@override@JsonKey(name: 'trainer_id') final  String trainerId;
@override@JsonKey(name: 'trainer_user_id') final  String? trainerUserId;
@override@JsonKey(name: 'member_id') final  String memberId;
@override@JsonKey(name: 'starts_at') final  DateTime startsAt;
@override@JsonKey(name: 'ends_at') final  DateTime endsAt;
@override@JsonKey(name: 'credit_cost') final  int creditCost;
@override@JsonKey() final  PtSessionStatus status;
@override final  String? notes;
@override@JsonKey(name: 'trainer_display_name') final  String trainerDisplayName;
@override@JsonKey(name: 'member_display_name') final  String memberDisplayName;
@override@JsonKey(name: 'member_code') final  String memberCode;

/// Create a copy of PtSessionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PtSessionModelCopyWith<_PtSessionModel> get copyWith => __$PtSessionModelCopyWithImpl<_PtSessionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PtSessionModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PtSessionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.trainerUserId, trainerUserId) || other.trainerUserId == trainerUserId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.creditCost, creditCost) || other.creditCost == creditCost)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.trainerDisplayName, trainerDisplayName) || other.trainerDisplayName == trainerDisplayName)&&(identical(other.memberDisplayName, memberDisplayName) || other.memberDisplayName == memberDisplayName)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,branchId,trainerId,trainerUserId,memberId,startsAt,endsAt,creditCost,status,notes,trainerDisplayName,memberDisplayName,memberCode);
}

@override
String toString() {
    return 'PtSessionModel(id: $id, organizationId: $organizationId, branchId: $branchId, trainerId: $trainerId, trainerUserId: $trainerUserId, memberId: $memberId, startsAt: $startsAt, endsAt: $endsAt, creditCost: $creditCost, status: $status, notes: $notes, trainerDisplayName: $trainerDisplayName, memberDisplayName: $memberDisplayName, memberCode: $memberCode)';
}


}

/// @nodoc
abstract mixin class _$PtSessionModelCopyWith<$Res> implements $PtSessionModelCopyWith<$Res> {
  factory _$PtSessionModelCopyWith(_PtSessionModel value, $Res Function(_PtSessionModel) _then) = __$PtSessionModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'branch_id') String branchId,@JsonKey(name: 'trainer_id') String trainerId,@JsonKey(name: 'trainer_user_id') String? trainerUserId,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'starts_at') DateTime startsAt,@JsonKey(name: 'ends_at') DateTime endsAt,@JsonKey(name: 'credit_cost') int creditCost, PtSessionStatus status, String? notes,@JsonKey(name: 'trainer_display_name') String trainerDisplayName,@JsonKey(name: 'member_display_name') String memberDisplayName,@JsonKey(name: 'member_code') String memberCode
});




}
/// @nodoc
class __$PtSessionModelCopyWithImpl<$Res>
    implements _$PtSessionModelCopyWith<$Res> {
  __$PtSessionModelCopyWithImpl(this._self, this._then);

  final _PtSessionModel _self;
  final $Res Function(_PtSessionModel) _then;

/// Create a copy of PtSessionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? branchId = null,Object? trainerId = null,Object? trainerUserId = freezed,Object? memberId = null,Object? startsAt = null,Object? endsAt = null,Object? creditCost = null,Object? status = null,Object? notes = freezed,Object? trainerDisplayName = null,Object? memberDisplayName = null,Object? memberCode = null,}) {
  return _then(_PtSessionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,trainerUserId: freezed == trainerUserId ? _self.trainerUserId : trainerUserId // ignore: cast_nullable_to_non_nullable
as String?,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,endsAt: null == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime,creditCost: null == creditCost ? _self.creditCost : creditCost // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PtSessionStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,trainerDisplayName: null == trainerDisplayName ? _self.trainerDisplayName : trainerDisplayName // ignore: cast_nullable_to_non_nullable
as String,memberDisplayName: null == memberDisplayName ? _self.memberDisplayName : memberDisplayName // ignore: cast_nullable_to_non_nullable
as String,memberCode: null == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PtClientLookup {

 String get id;@JsonKey(name: 'member_code') String get memberCode;@JsonKey(name: 'full_name') String get fullName;@JsonKey(name: 'home_branch_id') String get homeBranchId; String get status;@JsonKey(name: 'available_pt_credits') int get availablePtCredits;
/// Create a copy of PtClientLookup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PtClientLookupCopyWith<PtClientLookup> get copyWith => _$PtClientLookupCopyWithImpl<PtClientLookup>(this as PtClientLookup, _$identity);

  /// Serializes this PtClientLookup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PtClientLookup;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PtClientLookup&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.memberCode, _this.memberCode) || other.memberCode == _this.memberCode)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.homeBranchId, _this.homeBranchId) || other.homeBranchId == _this.homeBranchId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.availablePtCredits, _this.availablePtCredits) || other.availablePtCredits == _this.availablePtCredits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PtClientLookup;
  return Object.hash(runtimeType,_this.id,_this.memberCode,_this.fullName,_this.homeBranchId,_this.status,_this.availablePtCredits);
}

@override
String toString() {
  final _this = this as PtClientLookup;
  return 'PtClientLookup(id: ${_this.id}, memberCode: ${_this.memberCode}, fullName: ${_this.fullName}, homeBranchId: ${_this.homeBranchId}, status: ${_this.status}, availablePtCredits: ${_this.availablePtCredits})';
}


}

/// @nodoc
abstract mixin class $PtClientLookupCopyWith<$Res>  {
  factory $PtClientLookupCopyWith(PtClientLookup value, $Res Function(PtClientLookup) _then) = _$PtClientLookupCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'member_code') String memberCode,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'home_branch_id') String homeBranchId, String status,@JsonKey(name: 'available_pt_credits') int availablePtCredits
});




}
/// @nodoc
class _$PtClientLookupCopyWithImpl<$Res>
    implements $PtClientLookupCopyWith<$Res> {
  _$PtClientLookupCopyWithImpl(this._self, this._then);

  final PtClientLookup _self;
  final $Res Function(PtClientLookup) _then;

/// Create a copy of PtClientLookup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberCode = null,Object? fullName = null,Object? homeBranchId = null,Object? status = null,Object? availablePtCredits = null,}) {
  return _then(PtClientLookup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberCode: null == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,homeBranchId: null == homeBranchId ? _self.homeBranchId : homeBranchId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,availablePtCredits: null == availablePtCredits ? _self.availablePtCredits : availablePtCredits // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PtClientLookup].
extension PtClientLookupPatterns on PtClientLookup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PtClientLookup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PtClientLookup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PtClientLookup value)  $default,){
final _that = this;
switch (_that) {
case _PtClientLookup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PtClientLookup value)?  $default,){
final _that = this;
switch (_that) {
case _PtClientLookup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'member_code')  String memberCode, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'home_branch_id')  String homeBranchId,  String status, @JsonKey(name: 'available_pt_credits')  int availablePtCredits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PtClientLookup() when $default != null:
return $default(_that.id,_that.memberCode,_that.fullName,_that.homeBranchId,_that.status,_that.availablePtCredits);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'member_code')  String memberCode, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'home_branch_id')  String homeBranchId,  String status, @JsonKey(name: 'available_pt_credits')  int availablePtCredits)  $default,) {final _that = this;
switch (_that) {
case _PtClientLookup():
return $default(_that.id,_that.memberCode,_that.fullName,_that.homeBranchId,_that.status,_that.availablePtCredits);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'member_code')  String memberCode, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'home_branch_id')  String homeBranchId,  String status, @JsonKey(name: 'available_pt_credits')  int availablePtCredits)?  $default,) {final _that = this;
switch (_that) {
case _PtClientLookup() when $default != null:
return $default(_that.id,_that.memberCode,_that.fullName,_that.homeBranchId,_that.status,_that.availablePtCredits);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PtClientLookup implements PtClientLookup {
  const _PtClientLookup({required this.id, @JsonKey(name: 'member_code') required this.memberCode, @JsonKey(name: 'full_name') required this.fullName, @JsonKey(name: 'home_branch_id') required this.homeBranchId, this.status = 'active', @JsonKey(name: 'available_pt_credits') this.availablePtCredits = 0});
  factory _PtClientLookup.fromJson(Map<String, dynamic> json) => _$PtClientLookupFromJson(json);

@override final  String id;
@override@JsonKey(name: 'member_code') final  String memberCode;
@override@JsonKey(name: 'full_name') final  String fullName;
@override@JsonKey(name: 'home_branch_id') final  String homeBranchId;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'available_pt_credits') final  int availablePtCredits;

/// Create a copy of PtClientLookup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PtClientLookupCopyWith<_PtClientLookup> get copyWith => __$PtClientLookupCopyWithImpl<_PtClientLookup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PtClientLookupToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PtClientLookup&&(identical(other.id, id) || other.id == id)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.homeBranchId, homeBranchId) || other.homeBranchId == homeBranchId)&&(identical(other.status, status) || other.status == status)&&(identical(other.availablePtCredits, availablePtCredits) || other.availablePtCredits == availablePtCredits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,memberCode,fullName,homeBranchId,status,availablePtCredits);
}

@override
String toString() {
    return 'PtClientLookup(id: $id, memberCode: $memberCode, fullName: $fullName, homeBranchId: $homeBranchId, status: $status, availablePtCredits: $availablePtCredits)';
}


}

/// @nodoc
abstract mixin class _$PtClientLookupCopyWith<$Res> implements $PtClientLookupCopyWith<$Res> {
  factory _$PtClientLookupCopyWith(_PtClientLookup value, $Res Function(_PtClientLookup) _then) = __$PtClientLookupCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'member_code') String memberCode,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'home_branch_id') String homeBranchId, String status,@JsonKey(name: 'available_pt_credits') int availablePtCredits
});




}
/// @nodoc
class __$PtClientLookupCopyWithImpl<$Res>
    implements _$PtClientLookupCopyWith<$Res> {
  __$PtClientLookupCopyWithImpl(this._self, this._then);

  final _PtClientLookup _self;
  final $Res Function(_PtClientLookup) _then;

/// Create a copy of PtClientLookup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberCode = null,Object? fullName = null,Object? homeBranchId = null,Object? status = null,Object? availablePtCredits = null,}) {
  return _then(_PtClientLookup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberCode: null == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,homeBranchId: null == homeBranchId ? _self.homeBranchId : homeBranchId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,availablePtCredits: null == availablePtCredits ? _self.availablePtCredits : availablePtCredits // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PtBookingOutcome {

@JsonKey(name: 'pt_session_id') String get ptSessionId; PtSessionStatus get status;@JsonKey(name: 'credit_cost') int get creditCost;@JsonKey(name: 'idempotent_replay') bool get idempotentReplay;
/// Create a copy of PtBookingOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PtBookingOutcomeCopyWith<PtBookingOutcome> get copyWith => _$PtBookingOutcomeCopyWithImpl<PtBookingOutcome>(this as PtBookingOutcome, _$identity);

  /// Serializes this PtBookingOutcome to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PtBookingOutcome;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PtBookingOutcome&&(identical(other.ptSessionId, _this.ptSessionId) || other.ptSessionId == _this.ptSessionId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.creditCost, _this.creditCost) || other.creditCost == _this.creditCost)&&(identical(other.idempotentReplay, _this.idempotentReplay) || other.idempotentReplay == _this.idempotentReplay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PtBookingOutcome;
  return Object.hash(runtimeType,_this.ptSessionId,_this.status,_this.creditCost,_this.idempotentReplay);
}

@override
String toString() {
  final _this = this as PtBookingOutcome;
  return 'PtBookingOutcome(ptSessionId: ${_this.ptSessionId}, status: ${_this.status}, creditCost: ${_this.creditCost}, idempotentReplay: ${_this.idempotentReplay})';
}


}

/// @nodoc
abstract mixin class $PtBookingOutcomeCopyWith<$Res>  {
  factory $PtBookingOutcomeCopyWith(PtBookingOutcome value, $Res Function(PtBookingOutcome) _then) = _$PtBookingOutcomeCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'pt_session_id') String ptSessionId, PtSessionStatus status,@JsonKey(name: 'credit_cost') int creditCost,@JsonKey(name: 'idempotent_replay') bool idempotentReplay
});




}
/// @nodoc
class _$PtBookingOutcomeCopyWithImpl<$Res>
    implements $PtBookingOutcomeCopyWith<$Res> {
  _$PtBookingOutcomeCopyWithImpl(this._self, this._then);

  final PtBookingOutcome _self;
  final $Res Function(PtBookingOutcome) _then;

/// Create a copy of PtBookingOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ptSessionId = null,Object? status = null,Object? creditCost = null,Object? idempotentReplay = null,}) {
  return _then(PtBookingOutcome(
ptSessionId: null == ptSessionId ? _self.ptSessionId : ptSessionId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PtSessionStatus,creditCost: null == creditCost ? _self.creditCost : creditCost // ignore: cast_nullable_to_non_nullable
as int,idempotentReplay: null == idempotentReplay ? _self.idempotentReplay : idempotentReplay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PtBookingOutcome].
extension PtBookingOutcomePatterns on PtBookingOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PtBookingOutcome value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PtBookingOutcome() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PtBookingOutcome value)  $default,){
final _that = this;
switch (_that) {
case _PtBookingOutcome():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PtBookingOutcome value)?  $default,){
final _that = this;
switch (_that) {
case _PtBookingOutcome() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'pt_session_id')  String ptSessionId,  PtSessionStatus status, @JsonKey(name: 'credit_cost')  int creditCost, @JsonKey(name: 'idempotent_replay')  bool idempotentReplay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PtBookingOutcome() when $default != null:
return $default(_that.ptSessionId,_that.status,_that.creditCost,_that.idempotentReplay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'pt_session_id')  String ptSessionId,  PtSessionStatus status, @JsonKey(name: 'credit_cost')  int creditCost, @JsonKey(name: 'idempotent_replay')  bool idempotentReplay)  $default,) {final _that = this;
switch (_that) {
case _PtBookingOutcome():
return $default(_that.ptSessionId,_that.status,_that.creditCost,_that.idempotentReplay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'pt_session_id')  String ptSessionId,  PtSessionStatus status, @JsonKey(name: 'credit_cost')  int creditCost, @JsonKey(name: 'idempotent_replay')  bool idempotentReplay)?  $default,) {final _that = this;
switch (_that) {
case _PtBookingOutcome() when $default != null:
return $default(_that.ptSessionId,_that.status,_that.creditCost,_that.idempotentReplay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PtBookingOutcome implements PtBookingOutcome {
  const _PtBookingOutcome({@JsonKey(name: 'pt_session_id') required this.ptSessionId, this.status = PtSessionStatus.scheduled, @JsonKey(name: 'credit_cost') this.creditCost = 1, @JsonKey(name: 'idempotent_replay') this.idempotentReplay = false});
  factory _PtBookingOutcome.fromJson(Map<String, dynamic> json) => _$PtBookingOutcomeFromJson(json);

@override@JsonKey(name: 'pt_session_id') final  String ptSessionId;
@override@JsonKey() final  PtSessionStatus status;
@override@JsonKey(name: 'credit_cost') final  int creditCost;
@override@JsonKey(name: 'idempotent_replay') final  bool idempotentReplay;

/// Create a copy of PtBookingOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PtBookingOutcomeCopyWith<_PtBookingOutcome> get copyWith => __$PtBookingOutcomeCopyWithImpl<_PtBookingOutcome>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PtBookingOutcomeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PtBookingOutcome&&(identical(other.ptSessionId, ptSessionId) || other.ptSessionId == ptSessionId)&&(identical(other.status, status) || other.status == status)&&(identical(other.creditCost, creditCost) || other.creditCost == creditCost)&&(identical(other.idempotentReplay, idempotentReplay) || other.idempotentReplay == idempotentReplay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,ptSessionId,status,creditCost,idempotentReplay);
}

@override
String toString() {
    return 'PtBookingOutcome(ptSessionId: $ptSessionId, status: $status, creditCost: $creditCost, idempotentReplay: $idempotentReplay)';
}


}

/// @nodoc
abstract mixin class _$PtBookingOutcomeCopyWith<$Res> implements $PtBookingOutcomeCopyWith<$Res> {
  factory _$PtBookingOutcomeCopyWith(_PtBookingOutcome value, $Res Function(_PtBookingOutcome) _then) = __$PtBookingOutcomeCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'pt_session_id') String ptSessionId, PtSessionStatus status,@JsonKey(name: 'credit_cost') int creditCost,@JsonKey(name: 'idempotent_replay') bool idempotentReplay
});




}
/// @nodoc
class __$PtBookingOutcomeCopyWithImpl<$Res>
    implements _$PtBookingOutcomeCopyWith<$Res> {
  __$PtBookingOutcomeCopyWithImpl(this._self, this._then);

  final _PtBookingOutcome _self;
  final $Res Function(_PtBookingOutcome) _then;

/// Create a copy of PtBookingOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ptSessionId = null,Object? status = null,Object? creditCost = null,Object? idempotentReplay = null,}) {
  return _then(_PtBookingOutcome(
ptSessionId: null == ptSessionId ? _self.ptSessionId : ptSessionId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PtSessionStatus,creditCost: null == creditCost ? _self.creditCost : creditCost // ignore: cast_nullable_to_non_nullable
as int,idempotentReplay: null == idempotentReplay ? _self.idempotentReplay : idempotentReplay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PtCancelOutcome {

 PtSessionStatus get status;@JsonKey(name: 'refunded_credits') int get refundedCredits;@JsonKey(name: 'idempotent_replay') bool get idempotentReplay;
/// Create a copy of PtCancelOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PtCancelOutcomeCopyWith<PtCancelOutcome> get copyWith => _$PtCancelOutcomeCopyWithImpl<PtCancelOutcome>(this as PtCancelOutcome, _$identity);

  /// Serializes this PtCancelOutcome to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PtCancelOutcome;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PtCancelOutcome&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.refundedCredits, _this.refundedCredits) || other.refundedCredits == _this.refundedCredits)&&(identical(other.idempotentReplay, _this.idempotentReplay) || other.idempotentReplay == _this.idempotentReplay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PtCancelOutcome;
  return Object.hash(runtimeType,_this.status,_this.refundedCredits,_this.idempotentReplay);
}

@override
String toString() {
  final _this = this as PtCancelOutcome;
  return 'PtCancelOutcome(status: ${_this.status}, refundedCredits: ${_this.refundedCredits}, idempotentReplay: ${_this.idempotentReplay})';
}


}

/// @nodoc
abstract mixin class $PtCancelOutcomeCopyWith<$Res>  {
  factory $PtCancelOutcomeCopyWith(PtCancelOutcome value, $Res Function(PtCancelOutcome) _then) = _$PtCancelOutcomeCopyWithImpl;
@useResult
$Res call({
 PtSessionStatus status,@JsonKey(name: 'refunded_credits') int refundedCredits,@JsonKey(name: 'idempotent_replay') bool idempotentReplay
});




}
/// @nodoc
class _$PtCancelOutcomeCopyWithImpl<$Res>
    implements $PtCancelOutcomeCopyWith<$Res> {
  _$PtCancelOutcomeCopyWithImpl(this._self, this._then);

  final PtCancelOutcome _self;
  final $Res Function(PtCancelOutcome) _then;

/// Create a copy of PtCancelOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? refundedCredits = null,Object? idempotentReplay = null,}) {
  return _then(PtCancelOutcome(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PtSessionStatus,refundedCredits: null == refundedCredits ? _self.refundedCredits : refundedCredits // ignore: cast_nullable_to_non_nullable
as int,idempotentReplay: null == idempotentReplay ? _self.idempotentReplay : idempotentReplay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PtCancelOutcome].
extension PtCancelOutcomePatterns on PtCancelOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PtCancelOutcome value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PtCancelOutcome() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PtCancelOutcome value)  $default,){
final _that = this;
switch (_that) {
case _PtCancelOutcome():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PtCancelOutcome value)?  $default,){
final _that = this;
switch (_that) {
case _PtCancelOutcome() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PtSessionStatus status, @JsonKey(name: 'refunded_credits')  int refundedCredits, @JsonKey(name: 'idempotent_replay')  bool idempotentReplay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PtCancelOutcome() when $default != null:
return $default(_that.status,_that.refundedCredits,_that.idempotentReplay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PtSessionStatus status, @JsonKey(name: 'refunded_credits')  int refundedCredits, @JsonKey(name: 'idempotent_replay')  bool idempotentReplay)  $default,) {final _that = this;
switch (_that) {
case _PtCancelOutcome():
return $default(_that.status,_that.refundedCredits,_that.idempotentReplay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PtSessionStatus status, @JsonKey(name: 'refunded_credits')  int refundedCredits, @JsonKey(name: 'idempotent_replay')  bool idempotentReplay)?  $default,) {final _that = this;
switch (_that) {
case _PtCancelOutcome() when $default != null:
return $default(_that.status,_that.refundedCredits,_that.idempotentReplay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PtCancelOutcome implements PtCancelOutcome {
  const _PtCancelOutcome({this.status = PtSessionStatus.cancelledEarly, @JsonKey(name: 'refunded_credits') this.refundedCredits = 0, @JsonKey(name: 'idempotent_replay') this.idempotentReplay = false});
  factory _PtCancelOutcome.fromJson(Map<String, dynamic> json) => _$PtCancelOutcomeFromJson(json);

@override@JsonKey() final  PtSessionStatus status;
@override@JsonKey(name: 'refunded_credits') final  int refundedCredits;
@override@JsonKey(name: 'idempotent_replay') final  bool idempotentReplay;

/// Create a copy of PtCancelOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PtCancelOutcomeCopyWith<_PtCancelOutcome> get copyWith => __$PtCancelOutcomeCopyWithImpl<_PtCancelOutcome>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PtCancelOutcomeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PtCancelOutcome&&(identical(other.status, status) || other.status == status)&&(identical(other.refundedCredits, refundedCredits) || other.refundedCredits == refundedCredits)&&(identical(other.idempotentReplay, idempotentReplay) || other.idempotentReplay == idempotentReplay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,refundedCredits,idempotentReplay);
}

@override
String toString() {
    return 'PtCancelOutcome(status: $status, refundedCredits: $refundedCredits, idempotentReplay: $idempotentReplay)';
}


}

/// @nodoc
abstract mixin class _$PtCancelOutcomeCopyWith<$Res> implements $PtCancelOutcomeCopyWith<$Res> {
  factory _$PtCancelOutcomeCopyWith(_PtCancelOutcome value, $Res Function(_PtCancelOutcome) _then) = __$PtCancelOutcomeCopyWithImpl;
@override @useResult
$Res call({
 PtSessionStatus status,@JsonKey(name: 'refunded_credits') int refundedCredits,@JsonKey(name: 'idempotent_replay') bool idempotentReplay
});




}
/// @nodoc
class __$PtCancelOutcomeCopyWithImpl<$Res>
    implements _$PtCancelOutcomeCopyWith<$Res> {
  __$PtCancelOutcomeCopyWithImpl(this._self, this._then);

  final _PtCancelOutcome _self;
  final $Res Function(_PtCancelOutcome) _then;

/// Create a copy of PtCancelOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? refundedCredits = null,Object? idempotentReplay = null,}) {
  return _then(_PtCancelOutcome(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PtSessionStatus,refundedCredits: null == refundedCredits ? _self.refundedCredits : refundedCredits // ignore: cast_nullable_to_non_nullable
as int,idempotentReplay: null == idempotentReplay ? _self.idempotentReplay : idempotentReplay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
