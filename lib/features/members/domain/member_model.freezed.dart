// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MemberModel {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'user_id') String? get userId;@JsonKey(name: 'home_branch_id') String get homeBranchId;@JsonKey(name: 'member_code') String get memberCode;@JsonKey(name: 'full_name') String get fullName; String? get email; String? get phone;@JsonKey(name: 'emergency_contact_name') String? get emergencyContactName;@JsonKey(name: 'emergency_contact_phone') String? get emergencyContactPhone; MemberStatus get status;
/// Create a copy of MemberModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberModelCopyWith<MemberModel> get copyWith => _$MemberModelCopyWithImpl<MemberModel>(this as MemberModel, _$identity);

  /// Serializes this MemberModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MemberModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.homeBranchId, _this.homeBranchId) || other.homeBranchId == _this.homeBranchId)&&(identical(other.memberCode, _this.memberCode) || other.memberCode == _this.memberCode)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.emergencyContactName, _this.emergencyContactName) || other.emergencyContactName == _this.emergencyContactName)&&(identical(other.emergencyContactPhone, _this.emergencyContactPhone) || other.emergencyContactPhone == _this.emergencyContactPhone)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MemberModel;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.userId,_this.homeBranchId,_this.memberCode,_this.fullName,_this.email,_this.phone,_this.emergencyContactName,_this.emergencyContactPhone,_this.status);
}

@override
String toString() {
  final _this = this as MemberModel;
  return 'MemberModel(id: ${_this.id}, organizationId: ${_this.organizationId}, userId: ${_this.userId}, homeBranchId: ${_this.homeBranchId}, memberCode: ${_this.memberCode}, fullName: ${_this.fullName}, email: ${_this.email}, phone: ${_this.phone}, emergencyContactName: ${_this.emergencyContactName}, emergencyContactPhone: ${_this.emergencyContactPhone}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $MemberModelCopyWith<$Res>  {
  factory $MemberModelCopyWith(MemberModel value, $Res Function(MemberModel) _then) = _$MemberModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'user_id') String? userId,@JsonKey(name: 'home_branch_id') String homeBranchId,@JsonKey(name: 'member_code') String memberCode,@JsonKey(name: 'full_name') String fullName, String? email, String? phone,@JsonKey(name: 'emergency_contact_name') String? emergencyContactName,@JsonKey(name: 'emergency_contact_phone') String? emergencyContactPhone, MemberStatus status
});




}
/// @nodoc
class _$MemberModelCopyWithImpl<$Res>
    implements $MemberModelCopyWith<$Res> {
  _$MemberModelCopyWithImpl(this._self, this._then);

  final MemberModel _self;
  final $Res Function(MemberModel) _then;

/// Create a copy of MemberModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? userId = freezed,Object? homeBranchId = null,Object? memberCode = null,Object? fullName = null,Object? email = freezed,Object? phone = freezed,Object? emergencyContactName = freezed,Object? emergencyContactPhone = freezed,Object? status = null,}) {
  return _then(MemberModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,homeBranchId: null == homeBranchId ? _self.homeBranchId : homeBranchId // ignore: cast_nullable_to_non_nullable
as String,memberCode: null == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,emergencyContactName: freezed == emergencyContactName ? _self.emergencyContactName : emergencyContactName // ignore: cast_nullable_to_non_nullable
as String?,emergencyContactPhone: freezed == emergencyContactPhone ? _self.emergencyContactPhone : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberModel].
extension MemberModelPatterns on MemberModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberModel value)  $default,){
final _that = this;
switch (_that) {
case _MemberModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberModel value)?  $default,){
final _that = this;
switch (_that) {
case _MemberModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'user_id')  String? userId, @JsonKey(name: 'home_branch_id')  String homeBranchId, @JsonKey(name: 'member_code')  String memberCode, @JsonKey(name: 'full_name')  String fullName,  String? email,  String? phone, @JsonKey(name: 'emergency_contact_name')  String? emergencyContactName, @JsonKey(name: 'emergency_contact_phone')  String? emergencyContactPhone,  MemberStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.userId,_that.homeBranchId,_that.memberCode,_that.fullName,_that.email,_that.phone,_that.emergencyContactName,_that.emergencyContactPhone,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'user_id')  String? userId, @JsonKey(name: 'home_branch_id')  String homeBranchId, @JsonKey(name: 'member_code')  String memberCode, @JsonKey(name: 'full_name')  String fullName,  String? email,  String? phone, @JsonKey(name: 'emergency_contact_name')  String? emergencyContactName, @JsonKey(name: 'emergency_contact_phone')  String? emergencyContactPhone,  MemberStatus status)  $default,) {final _that = this;
switch (_that) {
case _MemberModel():
return $default(_that.id,_that.organizationId,_that.userId,_that.homeBranchId,_that.memberCode,_that.fullName,_that.email,_that.phone,_that.emergencyContactName,_that.emergencyContactPhone,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'user_id')  String? userId, @JsonKey(name: 'home_branch_id')  String homeBranchId, @JsonKey(name: 'member_code')  String memberCode, @JsonKey(name: 'full_name')  String fullName,  String? email,  String? phone, @JsonKey(name: 'emergency_contact_name')  String? emergencyContactName, @JsonKey(name: 'emergency_contact_phone')  String? emergencyContactPhone,  MemberStatus status)?  $default,) {final _that = this;
switch (_that) {
case _MemberModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.userId,_that.homeBranchId,_that.memberCode,_that.fullName,_that.email,_that.phone,_that.emergencyContactName,_that.emergencyContactPhone,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemberModel implements MemberModel {
  const _MemberModel({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'user_id') this.userId, @JsonKey(name: 'home_branch_id') required this.homeBranchId, @JsonKey(name: 'member_code') required this.memberCode, @JsonKey(name: 'full_name') required this.fullName, this.email, this.phone, @JsonKey(name: 'emergency_contact_name') this.emergencyContactName, @JsonKey(name: 'emergency_contact_phone') this.emergencyContactPhone, this.status = MemberStatus.active});
  factory _MemberModel.fromJson(Map<String, dynamic> json) => _$MemberModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'user_id') final  String? userId;
@override@JsonKey(name: 'home_branch_id') final  String homeBranchId;
@override@JsonKey(name: 'member_code') final  String memberCode;
@override@JsonKey(name: 'full_name') final  String fullName;
@override final  String? email;
@override final  String? phone;
@override@JsonKey(name: 'emergency_contact_name') final  String? emergencyContactName;
@override@JsonKey(name: 'emergency_contact_phone') final  String? emergencyContactPhone;
@override@JsonKey() final  MemberStatus status;

/// Create a copy of MemberModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberModelCopyWith<_MemberModel> get copyWith => __$MemberModelCopyWithImpl<_MemberModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.homeBranchId, homeBranchId) || other.homeBranchId == homeBranchId)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.emergencyContactName, emergencyContactName) || other.emergencyContactName == emergencyContactName)&&(identical(other.emergencyContactPhone, emergencyContactPhone) || other.emergencyContactPhone == emergencyContactPhone)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,userId,homeBranchId,memberCode,fullName,email,phone,emergencyContactName,emergencyContactPhone,status);
}

@override
String toString() {
    return 'MemberModel(id: $id, organizationId: $organizationId, userId: $userId, homeBranchId: $homeBranchId, memberCode: $memberCode, fullName: $fullName, email: $email, phone: $phone, emergencyContactName: $emergencyContactName, emergencyContactPhone: $emergencyContactPhone, status: $status)';
}


}

/// @nodoc
abstract mixin class _$MemberModelCopyWith<$Res> implements $MemberModelCopyWith<$Res> {
  factory _$MemberModelCopyWith(_MemberModel value, $Res Function(_MemberModel) _then) = __$MemberModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'user_id') String? userId,@JsonKey(name: 'home_branch_id') String homeBranchId,@JsonKey(name: 'member_code') String memberCode,@JsonKey(name: 'full_name') String fullName, String? email, String? phone,@JsonKey(name: 'emergency_contact_name') String? emergencyContactName,@JsonKey(name: 'emergency_contact_phone') String? emergencyContactPhone, MemberStatus status
});




}
/// @nodoc
class __$MemberModelCopyWithImpl<$Res>
    implements _$MemberModelCopyWith<$Res> {
  __$MemberModelCopyWithImpl(this._self, this._then);

  final _MemberModel _self;
  final $Res Function(_MemberModel) _then;

/// Create a copy of MemberModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? userId = freezed,Object? homeBranchId = null,Object? memberCode = null,Object? fullName = null,Object? email = freezed,Object? phone = freezed,Object? emergencyContactName = freezed,Object? emergencyContactPhone = freezed,Object? status = null,}) {
  return _then(_MemberModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,homeBranchId: null == homeBranchId ? _self.homeBranchId : homeBranchId // ignore: cast_nullable_to_non_nullable
as String,memberCode: null == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,emergencyContactName: freezed == emergencyContactName ? _self.emergencyContactName : emergencyContactName // ignore: cast_nullable_to_non_nullable
as String?,emergencyContactPhone: freezed == emergencyContactPhone ? _self.emergencyContactPhone : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MemberStatus,
  ));
}


}

// dart format on
