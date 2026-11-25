// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClassSessionModel {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'branch_id') String get branchId;@JsonKey(name: 'room_id') String get roomId;@JsonKey(name: 'class_type_id') String get classTypeId;@JsonKey(name: 'instructor_user_id') String? get instructorUserId;@JsonKey(name: 'instructor_display_name') String get instructorDisplayName; String get title;@JsonKey(name: 'starts_at') DateTime get startsAt;@JsonKey(name: 'ends_at') DateTime get endsAt; int get capacity;@JsonKey(name: 'confirmed_count') int get confirmedCount;@JsonKey(name: 'credit_cost') int get creditCost;@JsonKey(name: 'cancellation_cutoff_at') DateTime get cancellationCutoffAt;@JsonKey(name: 'waitlist_enabled') bool get waitlistEnabled; SessionStatus get status;
/// Create a copy of ClassSessionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClassSessionModelCopyWith<ClassSessionModel> get copyWith => _$ClassSessionModelCopyWithImpl<ClassSessionModel>(this as ClassSessionModel, _$identity);

  /// Serializes this ClassSessionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ClassSessionModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClassSessionModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId)&&(identical(other.roomId, _this.roomId) || other.roomId == _this.roomId)&&(identical(other.classTypeId, _this.classTypeId) || other.classTypeId == _this.classTypeId)&&(identical(other.instructorUserId, _this.instructorUserId) || other.instructorUserId == _this.instructorUserId)&&(identical(other.instructorDisplayName, _this.instructorDisplayName) || other.instructorDisplayName == _this.instructorDisplayName)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.startsAt, _this.startsAt) || other.startsAt == _this.startsAt)&&(identical(other.endsAt, _this.endsAt) || other.endsAt == _this.endsAt)&&(identical(other.capacity, _this.capacity) || other.capacity == _this.capacity)&&(identical(other.confirmedCount, _this.confirmedCount) || other.confirmedCount == _this.confirmedCount)&&(identical(other.creditCost, _this.creditCost) || other.creditCost == _this.creditCost)&&(identical(other.cancellationCutoffAt, _this.cancellationCutoffAt) || other.cancellationCutoffAt == _this.cancellationCutoffAt)&&(identical(other.waitlistEnabled, _this.waitlistEnabled) || other.waitlistEnabled == _this.waitlistEnabled)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ClassSessionModel;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.branchId,_this.roomId,_this.classTypeId,_this.instructorUserId,_this.instructorDisplayName,_this.title,_this.startsAt,_this.endsAt,_this.capacity,_this.confirmedCount,_this.creditCost,_this.cancellationCutoffAt,_this.waitlistEnabled,_this.status);
}

@override
String toString() {
  final _this = this as ClassSessionModel;
  return 'ClassSessionModel(id: ${_this.id}, organizationId: ${_this.organizationId}, branchId: ${_this.branchId}, roomId: ${_this.roomId}, classTypeId: ${_this.classTypeId}, instructorUserId: ${_this.instructorUserId}, instructorDisplayName: ${_this.instructorDisplayName}, title: ${_this.title}, startsAt: ${_this.startsAt}, endsAt: ${_this.endsAt}, capacity: ${_this.capacity}, confirmedCount: ${_this.confirmedCount}, creditCost: ${_this.creditCost}, cancellationCutoffAt: ${_this.cancellationCutoffAt}, waitlistEnabled: ${_this.waitlistEnabled}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $ClassSessionModelCopyWith<$Res>  {
  factory $ClassSessionModelCopyWith(ClassSessionModel value, $Res Function(ClassSessionModel) _then) = _$ClassSessionModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'branch_id') String branchId,@JsonKey(name: 'room_id') String roomId,@JsonKey(name: 'class_type_id') String classTypeId,@JsonKey(name: 'instructor_user_id') String? instructorUserId,@JsonKey(name: 'instructor_display_name') String instructorDisplayName, String title,@JsonKey(name: 'starts_at') DateTime startsAt,@JsonKey(name: 'ends_at') DateTime endsAt, int capacity,@JsonKey(name: 'confirmed_count') int confirmedCount,@JsonKey(name: 'credit_cost') int creditCost,@JsonKey(name: 'cancellation_cutoff_at') DateTime cancellationCutoffAt,@JsonKey(name: 'waitlist_enabled') bool waitlistEnabled, SessionStatus status
});




}
/// @nodoc
class _$ClassSessionModelCopyWithImpl<$Res>
    implements $ClassSessionModelCopyWith<$Res> {
  _$ClassSessionModelCopyWithImpl(this._self, this._then);

  final ClassSessionModel _self;
  final $Res Function(ClassSessionModel) _then;

/// Create a copy of ClassSessionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? branchId = null,Object? roomId = null,Object? classTypeId = null,Object? instructorUserId = freezed,Object? instructorDisplayName = null,Object? title = null,Object? startsAt = null,Object? endsAt = null,Object? capacity = null,Object? confirmedCount = null,Object? creditCost = null,Object? cancellationCutoffAt = null,Object? waitlistEnabled = null,Object? status = null,}) {
  return _then(ClassSessionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,classTypeId: null == classTypeId ? _self.classTypeId : classTypeId // ignore: cast_nullable_to_non_nullable
as String,instructorUserId: freezed == instructorUserId ? _self.instructorUserId : instructorUserId // ignore: cast_nullable_to_non_nullable
as String?,instructorDisplayName: null == instructorDisplayName ? _self.instructorDisplayName : instructorDisplayName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,endsAt: null == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,confirmedCount: null == confirmedCount ? _self.confirmedCount : confirmedCount // ignore: cast_nullable_to_non_nullable
as int,creditCost: null == creditCost ? _self.creditCost : creditCost // ignore: cast_nullable_to_non_nullable
as int,cancellationCutoffAt: null == cancellationCutoffAt ? _self.cancellationCutoffAt : cancellationCutoffAt // ignore: cast_nullable_to_non_nullable
as DateTime,waitlistEnabled: null == waitlistEnabled ? _self.waitlistEnabled : waitlistEnabled // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SessionStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [ClassSessionModel].
extension ClassSessionModelPatterns on ClassSessionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClassSessionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClassSessionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClassSessionModel value)  $default,){
final _that = this;
switch (_that) {
case _ClassSessionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClassSessionModel value)?  $default,){
final _that = this;
switch (_that) {
case _ClassSessionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'room_id')  String roomId, @JsonKey(name: 'class_type_id')  String classTypeId, @JsonKey(name: 'instructor_user_id')  String? instructorUserId, @JsonKey(name: 'instructor_display_name')  String instructorDisplayName,  String title, @JsonKey(name: 'starts_at')  DateTime startsAt, @JsonKey(name: 'ends_at')  DateTime endsAt,  int capacity, @JsonKey(name: 'confirmed_count')  int confirmedCount, @JsonKey(name: 'credit_cost')  int creditCost, @JsonKey(name: 'cancellation_cutoff_at')  DateTime cancellationCutoffAt, @JsonKey(name: 'waitlist_enabled')  bool waitlistEnabled,  SessionStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClassSessionModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.branchId,_that.roomId,_that.classTypeId,_that.instructorUserId,_that.instructorDisplayName,_that.title,_that.startsAt,_that.endsAt,_that.capacity,_that.confirmedCount,_that.creditCost,_that.cancellationCutoffAt,_that.waitlistEnabled,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'room_id')  String roomId, @JsonKey(name: 'class_type_id')  String classTypeId, @JsonKey(name: 'instructor_user_id')  String? instructorUserId, @JsonKey(name: 'instructor_display_name')  String instructorDisplayName,  String title, @JsonKey(name: 'starts_at')  DateTime startsAt, @JsonKey(name: 'ends_at')  DateTime endsAt,  int capacity, @JsonKey(name: 'confirmed_count')  int confirmedCount, @JsonKey(name: 'credit_cost')  int creditCost, @JsonKey(name: 'cancellation_cutoff_at')  DateTime cancellationCutoffAt, @JsonKey(name: 'waitlist_enabled')  bool waitlistEnabled,  SessionStatus status)  $default,) {final _that = this;
switch (_that) {
case _ClassSessionModel():
return $default(_that.id,_that.organizationId,_that.branchId,_that.roomId,_that.classTypeId,_that.instructorUserId,_that.instructorDisplayName,_that.title,_that.startsAt,_that.endsAt,_that.capacity,_that.confirmedCount,_that.creditCost,_that.cancellationCutoffAt,_that.waitlistEnabled,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'room_id')  String roomId, @JsonKey(name: 'class_type_id')  String classTypeId, @JsonKey(name: 'instructor_user_id')  String? instructorUserId, @JsonKey(name: 'instructor_display_name')  String instructorDisplayName,  String title, @JsonKey(name: 'starts_at')  DateTime startsAt, @JsonKey(name: 'ends_at')  DateTime endsAt,  int capacity, @JsonKey(name: 'confirmed_count')  int confirmedCount, @JsonKey(name: 'credit_cost')  int creditCost, @JsonKey(name: 'cancellation_cutoff_at')  DateTime cancellationCutoffAt, @JsonKey(name: 'waitlist_enabled')  bool waitlistEnabled,  SessionStatus status)?  $default,) {final _that = this;
switch (_that) {
case _ClassSessionModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.branchId,_that.roomId,_that.classTypeId,_that.instructorUserId,_that.instructorDisplayName,_that.title,_that.startsAt,_that.endsAt,_that.capacity,_that.confirmedCount,_that.creditCost,_that.cancellationCutoffAt,_that.waitlistEnabled,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClassSessionModel extends ClassSessionModel {
  const _ClassSessionModel({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'branch_id') required this.branchId, @JsonKey(name: 'room_id') required this.roomId, @JsonKey(name: 'class_type_id') required this.classTypeId, @JsonKey(name: 'instructor_user_id') this.instructorUserId, @JsonKey(name: 'instructor_display_name') this.instructorDisplayName = '', required this.title, @JsonKey(name: 'starts_at') required this.startsAt, @JsonKey(name: 'ends_at') required this.endsAt, required this.capacity, @JsonKey(name: 'confirmed_count') this.confirmedCount = 0, @JsonKey(name: 'credit_cost') this.creditCost = 1, @JsonKey(name: 'cancellation_cutoff_at') required this.cancellationCutoffAt, @JsonKey(name: 'waitlist_enabled') this.waitlistEnabled = true, this.status = SessionStatus.scheduled}): super._();
  factory _ClassSessionModel.fromJson(Map<String, dynamic> json) => _$ClassSessionModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'branch_id') final  String branchId;
@override@JsonKey(name: 'room_id') final  String roomId;
@override@JsonKey(name: 'class_type_id') final  String classTypeId;
@override@JsonKey(name: 'instructor_user_id') final  String? instructorUserId;
@override@JsonKey(name: 'instructor_display_name') final  String instructorDisplayName;
@override final  String title;
@override@JsonKey(name: 'starts_at') final  DateTime startsAt;
@override@JsonKey(name: 'ends_at') final  DateTime endsAt;
@override final  int capacity;
@override@JsonKey(name: 'confirmed_count') final  int confirmedCount;
@override@JsonKey(name: 'credit_cost') final  int creditCost;
@override@JsonKey(name: 'cancellation_cutoff_at') final  DateTime cancellationCutoffAt;
@override@JsonKey(name: 'waitlist_enabled') final  bool waitlistEnabled;
@override@JsonKey() final  SessionStatus status;

/// Create a copy of ClassSessionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClassSessionModelCopyWith<_ClassSessionModel> get copyWith => __$ClassSessionModelCopyWithImpl<_ClassSessionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClassSessionModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClassSessionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.classTypeId, classTypeId) || other.classTypeId == classTypeId)&&(identical(other.instructorUserId, instructorUserId) || other.instructorUserId == instructorUserId)&&(identical(other.instructorDisplayName, instructorDisplayName) || other.instructorDisplayName == instructorDisplayName)&&(identical(other.title, title) || other.title == title)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.confirmedCount, confirmedCount) || other.confirmedCount == confirmedCount)&&(identical(other.creditCost, creditCost) || other.creditCost == creditCost)&&(identical(other.cancellationCutoffAt, cancellationCutoffAt) || other.cancellationCutoffAt == cancellationCutoffAt)&&(identical(other.waitlistEnabled, waitlistEnabled) || other.waitlistEnabled == waitlistEnabled)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,branchId,roomId,classTypeId,instructorUserId,instructorDisplayName,title,startsAt,endsAt,capacity,confirmedCount,creditCost,cancellationCutoffAt,waitlistEnabled,status);
}

@override
String toString() {
    return 'ClassSessionModel(id: $id, organizationId: $organizationId, branchId: $branchId, roomId: $roomId, classTypeId: $classTypeId, instructorUserId: $instructorUserId, instructorDisplayName: $instructorDisplayName, title: $title, startsAt: $startsAt, endsAt: $endsAt, capacity: $capacity, confirmedCount: $confirmedCount, creditCost: $creditCost, cancellationCutoffAt: $cancellationCutoffAt, waitlistEnabled: $waitlistEnabled, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ClassSessionModelCopyWith<$Res> implements $ClassSessionModelCopyWith<$Res> {
  factory _$ClassSessionModelCopyWith(_ClassSessionModel value, $Res Function(_ClassSessionModel) _then) = __$ClassSessionModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'branch_id') String branchId,@JsonKey(name: 'room_id') String roomId,@JsonKey(name: 'class_type_id') String classTypeId,@JsonKey(name: 'instructor_user_id') String? instructorUserId,@JsonKey(name: 'instructor_display_name') String instructorDisplayName, String title,@JsonKey(name: 'starts_at') DateTime startsAt,@JsonKey(name: 'ends_at') DateTime endsAt, int capacity,@JsonKey(name: 'confirmed_count') int confirmedCount,@JsonKey(name: 'credit_cost') int creditCost,@JsonKey(name: 'cancellation_cutoff_at') DateTime cancellationCutoffAt,@JsonKey(name: 'waitlist_enabled') bool waitlistEnabled, SessionStatus status
});




}
/// @nodoc
class __$ClassSessionModelCopyWithImpl<$Res>
    implements _$ClassSessionModelCopyWith<$Res> {
  __$ClassSessionModelCopyWithImpl(this._self, this._then);

  final _ClassSessionModel _self;
  final $Res Function(_ClassSessionModel) _then;

/// Create a copy of ClassSessionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? branchId = null,Object? roomId = null,Object? classTypeId = null,Object? instructorUserId = freezed,Object? instructorDisplayName = null,Object? title = null,Object? startsAt = null,Object? endsAt = null,Object? capacity = null,Object? confirmedCount = null,Object? creditCost = null,Object? cancellationCutoffAt = null,Object? waitlistEnabled = null,Object? status = null,}) {
  return _then(_ClassSessionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,classTypeId: null == classTypeId ? _self.classTypeId : classTypeId // ignore: cast_nullable_to_non_nullable
as String,instructorUserId: freezed == instructorUserId ? _self.instructorUserId : instructorUserId // ignore: cast_nullable_to_non_nullable
as String?,instructorDisplayName: null == instructorDisplayName ? _self.instructorDisplayName : instructorDisplayName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,endsAt: null == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,confirmedCount: null == confirmedCount ? _self.confirmedCount : confirmedCount // ignore: cast_nullable_to_non_nullable
as int,creditCost: null == creditCost ? _self.creditCost : creditCost // ignore: cast_nullable_to_non_nullable
as int,cancellationCutoffAt: null == cancellationCutoffAt ? _self.cancellationCutoffAt : cancellationCutoffAt // ignore: cast_nullable_to_non_nullable
as DateTime,waitlistEnabled: null == waitlistEnabled ? _self.waitlistEnabled : waitlistEnabled // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SessionStatus,
  ));
}


}


/// @nodoc
mixin _$ClassBookingModel {

 String get id;@JsonKey(name: 'organization_id') String get organizationId;@JsonKey(name: 'branch_id') String get branchId;@JsonKey(name: 'session_id') String get sessionId;@JsonKey(name: 'member_id') String get memberId; BookingStatus get status;@JsonKey(name: 'attendance_status') AttendanceStatus get attendanceStatus;@JsonKey(name: 'waitlist_position') int? get waitlistPosition;@JsonKey(name: 'credit_cost') int get creditCost;@JsonKey(name: 'booked_at') DateTime get bookedAt;@JsonKey(name: 'cancelled_at') DateTime? get cancelledAt;
/// Create a copy of ClassBookingModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClassBookingModelCopyWith<ClassBookingModel> get copyWith => _$ClassBookingModelCopyWithImpl<ClassBookingModel>(this as ClassBookingModel, _$identity);

  /// Serializes this ClassBookingModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ClassBookingModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClassBookingModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.organizationId, _this.organizationId) || other.organizationId == _this.organizationId)&&(identical(other.branchId, _this.branchId) || other.branchId == _this.branchId)&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.memberId, _this.memberId) || other.memberId == _this.memberId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.attendanceStatus, _this.attendanceStatus) || other.attendanceStatus == _this.attendanceStatus)&&(identical(other.waitlistPosition, _this.waitlistPosition) || other.waitlistPosition == _this.waitlistPosition)&&(identical(other.creditCost, _this.creditCost) || other.creditCost == _this.creditCost)&&(identical(other.bookedAt, _this.bookedAt) || other.bookedAt == _this.bookedAt)&&(identical(other.cancelledAt, _this.cancelledAt) || other.cancelledAt == _this.cancelledAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ClassBookingModel;
  return Object.hash(runtimeType,_this.id,_this.organizationId,_this.branchId,_this.sessionId,_this.memberId,_this.status,_this.attendanceStatus,_this.waitlistPosition,_this.creditCost,_this.bookedAt,_this.cancelledAt);
}

@override
String toString() {
  final _this = this as ClassBookingModel;
  return 'ClassBookingModel(id: ${_this.id}, organizationId: ${_this.organizationId}, branchId: ${_this.branchId}, sessionId: ${_this.sessionId}, memberId: ${_this.memberId}, status: ${_this.status}, attendanceStatus: ${_this.attendanceStatus}, waitlistPosition: ${_this.waitlistPosition}, creditCost: ${_this.creditCost}, bookedAt: ${_this.bookedAt}, cancelledAt: ${_this.cancelledAt})';
}


}

/// @nodoc
abstract mixin class $ClassBookingModelCopyWith<$Res>  {
  factory $ClassBookingModelCopyWith(ClassBookingModel value, $Res Function(ClassBookingModel) _then) = _$ClassBookingModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'branch_id') String branchId,@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'member_id') String memberId, BookingStatus status,@JsonKey(name: 'attendance_status') AttendanceStatus attendanceStatus,@JsonKey(name: 'waitlist_position') int? waitlistPosition,@JsonKey(name: 'credit_cost') int creditCost,@JsonKey(name: 'booked_at') DateTime bookedAt,@JsonKey(name: 'cancelled_at') DateTime? cancelledAt
});




}
/// @nodoc
class _$ClassBookingModelCopyWithImpl<$Res>
    implements $ClassBookingModelCopyWith<$Res> {
  _$ClassBookingModelCopyWithImpl(this._self, this._then);

  final ClassBookingModel _self;
  final $Res Function(ClassBookingModel) _then;

/// Create a copy of ClassBookingModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? branchId = null,Object? sessionId = null,Object? memberId = null,Object? status = null,Object? attendanceStatus = null,Object? waitlistPosition = freezed,Object? creditCost = null,Object? bookedAt = null,Object? cancelledAt = freezed,}) {
  return _then(ClassBookingModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,attendanceStatus: null == attendanceStatus ? _self.attendanceStatus : attendanceStatus // ignore: cast_nullable_to_non_nullable
as AttendanceStatus,waitlistPosition: freezed == waitlistPosition ? _self.waitlistPosition : waitlistPosition // ignore: cast_nullable_to_non_nullable
as int?,creditCost: null == creditCost ? _self.creditCost : creditCost // ignore: cast_nullable_to_non_nullable
as int,bookedAt: null == bookedAt ? _self.bookedAt : bookedAt // ignore: cast_nullable_to_non_nullable
as DateTime,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClassBookingModel].
extension ClassBookingModelPatterns on ClassBookingModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClassBookingModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClassBookingModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClassBookingModel value)  $default,){
final _that = this;
switch (_that) {
case _ClassBookingModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClassBookingModel value)?  $default,){
final _that = this;
switch (_that) {
case _ClassBookingModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'member_id')  String memberId,  BookingStatus status, @JsonKey(name: 'attendance_status')  AttendanceStatus attendanceStatus, @JsonKey(name: 'waitlist_position')  int? waitlistPosition, @JsonKey(name: 'credit_cost')  int creditCost, @JsonKey(name: 'booked_at')  DateTime bookedAt, @JsonKey(name: 'cancelled_at')  DateTime? cancelledAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClassBookingModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.branchId,_that.sessionId,_that.memberId,_that.status,_that.attendanceStatus,_that.waitlistPosition,_that.creditCost,_that.bookedAt,_that.cancelledAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'member_id')  String memberId,  BookingStatus status, @JsonKey(name: 'attendance_status')  AttendanceStatus attendanceStatus, @JsonKey(name: 'waitlist_position')  int? waitlistPosition, @JsonKey(name: 'credit_cost')  int creditCost, @JsonKey(name: 'booked_at')  DateTime bookedAt, @JsonKey(name: 'cancelled_at')  DateTime? cancelledAt)  $default,) {final _that = this;
switch (_that) {
case _ClassBookingModel():
return $default(_that.id,_that.organizationId,_that.branchId,_that.sessionId,_that.memberId,_that.status,_that.attendanceStatus,_that.waitlistPosition,_that.creditCost,_that.bookedAt,_that.cancelledAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'organization_id')  String organizationId, @JsonKey(name: 'branch_id')  String branchId, @JsonKey(name: 'session_id')  String sessionId, @JsonKey(name: 'member_id')  String memberId,  BookingStatus status, @JsonKey(name: 'attendance_status')  AttendanceStatus attendanceStatus, @JsonKey(name: 'waitlist_position')  int? waitlistPosition, @JsonKey(name: 'credit_cost')  int creditCost, @JsonKey(name: 'booked_at')  DateTime bookedAt, @JsonKey(name: 'cancelled_at')  DateTime? cancelledAt)?  $default,) {final _that = this;
switch (_that) {
case _ClassBookingModel() when $default != null:
return $default(_that.id,_that.organizationId,_that.branchId,_that.sessionId,_that.memberId,_that.status,_that.attendanceStatus,_that.waitlistPosition,_that.creditCost,_that.bookedAt,_that.cancelledAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClassBookingModel implements ClassBookingModel {
  const _ClassBookingModel({required this.id, @JsonKey(name: 'organization_id') required this.organizationId, @JsonKey(name: 'branch_id') required this.branchId, @JsonKey(name: 'session_id') required this.sessionId, @JsonKey(name: 'member_id') required this.memberId, required this.status, @JsonKey(name: 'attendance_status') this.attendanceStatus = AttendanceStatus.pending, @JsonKey(name: 'waitlist_position') this.waitlistPosition, @JsonKey(name: 'credit_cost') this.creditCost = 0, @JsonKey(name: 'booked_at') required this.bookedAt, @JsonKey(name: 'cancelled_at') this.cancelledAt});
  factory _ClassBookingModel.fromJson(Map<String, dynamic> json) => _$ClassBookingModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'organization_id') final  String organizationId;
@override@JsonKey(name: 'branch_id') final  String branchId;
@override@JsonKey(name: 'session_id') final  String sessionId;
@override@JsonKey(name: 'member_id') final  String memberId;
@override final  BookingStatus status;
@override@JsonKey(name: 'attendance_status') final  AttendanceStatus attendanceStatus;
@override@JsonKey(name: 'waitlist_position') final  int? waitlistPosition;
@override@JsonKey(name: 'credit_cost') final  int creditCost;
@override@JsonKey(name: 'booked_at') final  DateTime bookedAt;
@override@JsonKey(name: 'cancelled_at') final  DateTime? cancelledAt;

/// Create a copy of ClassBookingModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClassBookingModelCopyWith<_ClassBookingModel> get copyWith => __$ClassBookingModelCopyWithImpl<_ClassBookingModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClassBookingModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClassBookingModel&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.status, status) || other.status == status)&&(identical(other.attendanceStatus, attendanceStatus) || other.attendanceStatus == attendanceStatus)&&(identical(other.waitlistPosition, waitlistPosition) || other.waitlistPosition == waitlistPosition)&&(identical(other.creditCost, creditCost) || other.creditCost == creditCost)&&(identical(other.bookedAt, bookedAt) || other.bookedAt == bookedAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,organizationId,branchId,sessionId,memberId,status,attendanceStatus,waitlistPosition,creditCost,bookedAt,cancelledAt);
}

@override
String toString() {
    return 'ClassBookingModel(id: $id, organizationId: $organizationId, branchId: $branchId, sessionId: $sessionId, memberId: $memberId, status: $status, attendanceStatus: $attendanceStatus, waitlistPosition: $waitlistPosition, creditCost: $creditCost, bookedAt: $bookedAt, cancelledAt: $cancelledAt)';
}


}

/// @nodoc
abstract mixin class _$ClassBookingModelCopyWith<$Res> implements $ClassBookingModelCopyWith<$Res> {
  factory _$ClassBookingModelCopyWith(_ClassBookingModel value, $Res Function(_ClassBookingModel) _then) = __$ClassBookingModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'organization_id') String organizationId,@JsonKey(name: 'branch_id') String branchId,@JsonKey(name: 'session_id') String sessionId,@JsonKey(name: 'member_id') String memberId, BookingStatus status,@JsonKey(name: 'attendance_status') AttendanceStatus attendanceStatus,@JsonKey(name: 'waitlist_position') int? waitlistPosition,@JsonKey(name: 'credit_cost') int creditCost,@JsonKey(name: 'booked_at') DateTime bookedAt,@JsonKey(name: 'cancelled_at') DateTime? cancelledAt
});




}
/// @nodoc
class __$ClassBookingModelCopyWithImpl<$Res>
    implements _$ClassBookingModelCopyWith<$Res> {
  __$ClassBookingModelCopyWithImpl(this._self, this._then);

  final _ClassBookingModel _self;
  final $Res Function(_ClassBookingModel) _then;

/// Create a copy of ClassBookingModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? branchId = null,Object? sessionId = null,Object? memberId = null,Object? status = null,Object? attendanceStatus = null,Object? waitlistPosition = freezed,Object? creditCost = null,Object? bookedAt = null,Object? cancelledAt = freezed,}) {
  return _then(_ClassBookingModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,attendanceStatus: null == attendanceStatus ? _self.attendanceStatus : attendanceStatus // ignore: cast_nullable_to_non_nullable
as AttendanceStatus,waitlistPosition: freezed == waitlistPosition ? _self.waitlistPosition : waitlistPosition // ignore: cast_nullable_to_non_nullable
as int?,creditCost: null == creditCost ? _self.creditCost : creditCost // ignore: cast_nullable_to_non_nullable
as int,bookedAt: null == bookedAt ? _self.bookedAt : bookedAt // ignore: cast_nullable_to_non_nullable
as DateTime,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SessionRosterEntry {

@JsonKey(name: 'booking_id') String get bookingId;@JsonKey(name: 'member_id') String get memberId;@JsonKey(name: 'member_display_name') String get memberDisplayName;@JsonKey(name: 'member_code') String get memberCode; BookingStatus get status;@JsonKey(name: 'attendance_status') AttendanceStatus get attendanceStatus;@JsonKey(name: 'waitlist_position') int? get waitlistPosition;@JsonKey(name: 'booked_at') DateTime get bookedAt;
/// Create a copy of SessionRosterEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionRosterEntryCopyWith<SessionRosterEntry> get copyWith => _$SessionRosterEntryCopyWithImpl<SessionRosterEntry>(this as SessionRosterEntry, _$identity);

  /// Serializes this SessionRosterEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SessionRosterEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionRosterEntry&&(identical(other.bookingId, _this.bookingId) || other.bookingId == _this.bookingId)&&(identical(other.memberId, _this.memberId) || other.memberId == _this.memberId)&&(identical(other.memberDisplayName, _this.memberDisplayName) || other.memberDisplayName == _this.memberDisplayName)&&(identical(other.memberCode, _this.memberCode) || other.memberCode == _this.memberCode)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.attendanceStatus, _this.attendanceStatus) || other.attendanceStatus == _this.attendanceStatus)&&(identical(other.waitlistPosition, _this.waitlistPosition) || other.waitlistPosition == _this.waitlistPosition)&&(identical(other.bookedAt, _this.bookedAt) || other.bookedAt == _this.bookedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SessionRosterEntry;
  return Object.hash(runtimeType,_this.bookingId,_this.memberId,_this.memberDisplayName,_this.memberCode,_this.status,_this.attendanceStatus,_this.waitlistPosition,_this.bookedAt);
}

@override
String toString() {
  final _this = this as SessionRosterEntry;
  return 'SessionRosterEntry(bookingId: ${_this.bookingId}, memberId: ${_this.memberId}, memberDisplayName: ${_this.memberDisplayName}, memberCode: ${_this.memberCode}, status: ${_this.status}, attendanceStatus: ${_this.attendanceStatus}, waitlistPosition: ${_this.waitlistPosition}, bookedAt: ${_this.bookedAt})';
}


}

/// @nodoc
abstract mixin class $SessionRosterEntryCopyWith<$Res>  {
  factory $SessionRosterEntryCopyWith(SessionRosterEntry value, $Res Function(SessionRosterEntry) _then) = _$SessionRosterEntryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'booking_id') String bookingId,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'member_display_name') String memberDisplayName,@JsonKey(name: 'member_code') String memberCode, BookingStatus status,@JsonKey(name: 'attendance_status') AttendanceStatus attendanceStatus,@JsonKey(name: 'waitlist_position') int? waitlistPosition,@JsonKey(name: 'booked_at') DateTime bookedAt
});




}
/// @nodoc
class _$SessionRosterEntryCopyWithImpl<$Res>
    implements $SessionRosterEntryCopyWith<$Res> {
  _$SessionRosterEntryCopyWithImpl(this._self, this._then);

  final SessionRosterEntry _self;
  final $Res Function(SessionRosterEntry) _then;

/// Create a copy of SessionRosterEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookingId = null,Object? memberId = null,Object? memberDisplayName = null,Object? memberCode = null,Object? status = null,Object? attendanceStatus = null,Object? waitlistPosition = freezed,Object? bookedAt = null,}) {
  return _then(SessionRosterEntry(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberDisplayName: null == memberDisplayName ? _self.memberDisplayName : memberDisplayName // ignore: cast_nullable_to_non_nullable
as String,memberCode: null == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,attendanceStatus: null == attendanceStatus ? _self.attendanceStatus : attendanceStatus // ignore: cast_nullable_to_non_nullable
as AttendanceStatus,waitlistPosition: freezed == waitlistPosition ? _self.waitlistPosition : waitlistPosition // ignore: cast_nullable_to_non_nullable
as int?,bookedAt: null == bookedAt ? _self.bookedAt : bookedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionRosterEntry].
extension SessionRosterEntryPatterns on SessionRosterEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionRosterEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionRosterEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionRosterEntry value)  $default,){
final _that = this;
switch (_that) {
case _SessionRosterEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionRosterEntry value)?  $default,){
final _that = this;
switch (_that) {
case _SessionRosterEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'booking_id')  String bookingId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'member_display_name')  String memberDisplayName, @JsonKey(name: 'member_code')  String memberCode,  BookingStatus status, @JsonKey(name: 'attendance_status')  AttendanceStatus attendanceStatus, @JsonKey(name: 'waitlist_position')  int? waitlistPosition, @JsonKey(name: 'booked_at')  DateTime bookedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionRosterEntry() when $default != null:
return $default(_that.bookingId,_that.memberId,_that.memberDisplayName,_that.memberCode,_that.status,_that.attendanceStatus,_that.waitlistPosition,_that.bookedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'booking_id')  String bookingId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'member_display_name')  String memberDisplayName, @JsonKey(name: 'member_code')  String memberCode,  BookingStatus status, @JsonKey(name: 'attendance_status')  AttendanceStatus attendanceStatus, @JsonKey(name: 'waitlist_position')  int? waitlistPosition, @JsonKey(name: 'booked_at')  DateTime bookedAt)  $default,) {final _that = this;
switch (_that) {
case _SessionRosterEntry():
return $default(_that.bookingId,_that.memberId,_that.memberDisplayName,_that.memberCode,_that.status,_that.attendanceStatus,_that.waitlistPosition,_that.bookedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'booking_id')  String bookingId, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'member_display_name')  String memberDisplayName, @JsonKey(name: 'member_code')  String memberCode,  BookingStatus status, @JsonKey(name: 'attendance_status')  AttendanceStatus attendanceStatus, @JsonKey(name: 'waitlist_position')  int? waitlistPosition, @JsonKey(name: 'booked_at')  DateTime bookedAt)?  $default,) {final _that = this;
switch (_that) {
case _SessionRosterEntry() when $default != null:
return $default(_that.bookingId,_that.memberId,_that.memberDisplayName,_that.memberCode,_that.status,_that.attendanceStatus,_that.waitlistPosition,_that.bookedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionRosterEntry implements SessionRosterEntry {
  const _SessionRosterEntry({@JsonKey(name: 'booking_id') required this.bookingId, @JsonKey(name: 'member_id') required this.memberId, @JsonKey(name: 'member_display_name') required this.memberDisplayName, @JsonKey(name: 'member_code') required this.memberCode, required this.status, @JsonKey(name: 'attendance_status') this.attendanceStatus = AttendanceStatus.pending, @JsonKey(name: 'waitlist_position') this.waitlistPosition, @JsonKey(name: 'booked_at') required this.bookedAt});
  factory _SessionRosterEntry.fromJson(Map<String, dynamic> json) => _$SessionRosterEntryFromJson(json);

@override@JsonKey(name: 'booking_id') final  String bookingId;
@override@JsonKey(name: 'member_id') final  String memberId;
@override@JsonKey(name: 'member_display_name') final  String memberDisplayName;
@override@JsonKey(name: 'member_code') final  String memberCode;
@override final  BookingStatus status;
@override@JsonKey(name: 'attendance_status') final  AttendanceStatus attendanceStatus;
@override@JsonKey(name: 'waitlist_position') final  int? waitlistPosition;
@override@JsonKey(name: 'booked_at') final  DateTime bookedAt;

/// Create a copy of SessionRosterEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionRosterEntryCopyWith<_SessionRosterEntry> get copyWith => __$SessionRosterEntryCopyWithImpl<_SessionRosterEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionRosterEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionRosterEntry&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberDisplayName, memberDisplayName) || other.memberDisplayName == memberDisplayName)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.status, status) || other.status == status)&&(identical(other.attendanceStatus, attendanceStatus) || other.attendanceStatus == attendanceStatus)&&(identical(other.waitlistPosition, waitlistPosition) || other.waitlistPosition == waitlistPosition)&&(identical(other.bookedAt, bookedAt) || other.bookedAt == bookedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,bookingId,memberId,memberDisplayName,memberCode,status,attendanceStatus,waitlistPosition,bookedAt);
}

@override
String toString() {
    return 'SessionRosterEntry(bookingId: $bookingId, memberId: $memberId, memberDisplayName: $memberDisplayName, memberCode: $memberCode, status: $status, attendanceStatus: $attendanceStatus, waitlistPosition: $waitlistPosition, bookedAt: $bookedAt)';
}


}

/// @nodoc
abstract mixin class _$SessionRosterEntryCopyWith<$Res> implements $SessionRosterEntryCopyWith<$Res> {
  factory _$SessionRosterEntryCopyWith(_SessionRosterEntry value, $Res Function(_SessionRosterEntry) _then) = __$SessionRosterEntryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'booking_id') String bookingId,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'member_display_name') String memberDisplayName,@JsonKey(name: 'member_code') String memberCode, BookingStatus status,@JsonKey(name: 'attendance_status') AttendanceStatus attendanceStatus,@JsonKey(name: 'waitlist_position') int? waitlistPosition,@JsonKey(name: 'booked_at') DateTime bookedAt
});




}
/// @nodoc
class __$SessionRosterEntryCopyWithImpl<$Res>
    implements _$SessionRosterEntryCopyWith<$Res> {
  __$SessionRosterEntryCopyWithImpl(this._self, this._then);

  final _SessionRosterEntry _self;
  final $Res Function(_SessionRosterEntry) _then;

/// Create a copy of SessionRosterEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookingId = null,Object? memberId = null,Object? memberDisplayName = null,Object? memberCode = null,Object? status = null,Object? attendanceStatus = null,Object? waitlistPosition = freezed,Object? bookedAt = null,}) {
  return _then(_SessionRosterEntry(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberDisplayName: null == memberDisplayName ? _self.memberDisplayName : memberDisplayName // ignore: cast_nullable_to_non_nullable
as String,memberCode: null == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,attendanceStatus: null == attendanceStatus ? _self.attendanceStatus : attendanceStatus // ignore: cast_nullable_to_non_nullable
as AttendanceStatus,waitlistPosition: freezed == waitlistPosition ? _self.waitlistPosition : waitlistPosition // ignore: cast_nullable_to_non_nullable
as int?,bookedAt: null == bookedAt ? _self.bookedAt : bookedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$BookingActionOutcome {

@JsonKey(name: 'booking_id') String get bookingId; BookingStatus get status;@JsonKey(name: 'waitlist_position') int? get waitlistPosition;@JsonKey(name: 'idempotent_replay') bool get idempotentReplay;
/// Create a copy of BookingActionOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingActionOutcomeCopyWith<BookingActionOutcome> get copyWith => _$BookingActionOutcomeCopyWithImpl<BookingActionOutcome>(this as BookingActionOutcome, _$identity);

  /// Serializes this BookingActionOutcome to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BookingActionOutcome;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingActionOutcome&&(identical(other.bookingId, _this.bookingId) || other.bookingId == _this.bookingId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.waitlistPosition, _this.waitlistPosition) || other.waitlistPosition == _this.waitlistPosition)&&(identical(other.idempotentReplay, _this.idempotentReplay) || other.idempotentReplay == _this.idempotentReplay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BookingActionOutcome;
  return Object.hash(runtimeType,_this.bookingId,_this.status,_this.waitlistPosition,_this.idempotentReplay);
}

@override
String toString() {
  final _this = this as BookingActionOutcome;
  return 'BookingActionOutcome(bookingId: ${_this.bookingId}, status: ${_this.status}, waitlistPosition: ${_this.waitlistPosition}, idempotentReplay: ${_this.idempotentReplay})';
}


}

/// @nodoc
abstract mixin class $BookingActionOutcomeCopyWith<$Res>  {
  factory $BookingActionOutcomeCopyWith(BookingActionOutcome value, $Res Function(BookingActionOutcome) _then) = _$BookingActionOutcomeCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'booking_id') String bookingId, BookingStatus status,@JsonKey(name: 'waitlist_position') int? waitlistPosition,@JsonKey(name: 'idempotent_replay') bool idempotentReplay
});




}
/// @nodoc
class _$BookingActionOutcomeCopyWithImpl<$Res>
    implements $BookingActionOutcomeCopyWith<$Res> {
  _$BookingActionOutcomeCopyWithImpl(this._self, this._then);

  final BookingActionOutcome _self;
  final $Res Function(BookingActionOutcome) _then;

/// Create a copy of BookingActionOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookingId = null,Object? status = null,Object? waitlistPosition = freezed,Object? idempotentReplay = null,}) {
  return _then(BookingActionOutcome(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,waitlistPosition: freezed == waitlistPosition ? _self.waitlistPosition : waitlistPosition // ignore: cast_nullable_to_non_nullable
as int?,idempotentReplay: null == idempotentReplay ? _self.idempotentReplay : idempotentReplay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingActionOutcome].
extension BookingActionOutcomePatterns on BookingActionOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingActionOutcome value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingActionOutcome() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingActionOutcome value)  $default,){
final _that = this;
switch (_that) {
case _BookingActionOutcome():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingActionOutcome value)?  $default,){
final _that = this;
switch (_that) {
case _BookingActionOutcome() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'booking_id')  String bookingId,  BookingStatus status, @JsonKey(name: 'waitlist_position')  int? waitlistPosition, @JsonKey(name: 'idempotent_replay')  bool idempotentReplay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingActionOutcome() when $default != null:
return $default(_that.bookingId,_that.status,_that.waitlistPosition,_that.idempotentReplay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'booking_id')  String bookingId,  BookingStatus status, @JsonKey(name: 'waitlist_position')  int? waitlistPosition, @JsonKey(name: 'idempotent_replay')  bool idempotentReplay)  $default,) {final _that = this;
switch (_that) {
case _BookingActionOutcome():
return $default(_that.bookingId,_that.status,_that.waitlistPosition,_that.idempotentReplay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'booking_id')  String bookingId,  BookingStatus status, @JsonKey(name: 'waitlist_position')  int? waitlistPosition, @JsonKey(name: 'idempotent_replay')  bool idempotentReplay)?  $default,) {final _that = this;
switch (_that) {
case _BookingActionOutcome() when $default != null:
return $default(_that.bookingId,_that.status,_that.waitlistPosition,_that.idempotentReplay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookingActionOutcome implements BookingActionOutcome {
  const _BookingActionOutcome({@JsonKey(name: 'booking_id') required this.bookingId, required this.status, @JsonKey(name: 'waitlist_position') this.waitlistPosition, @JsonKey(name: 'idempotent_replay') this.idempotentReplay = false});
  factory _BookingActionOutcome.fromJson(Map<String, dynamic> json) => _$BookingActionOutcomeFromJson(json);

@override@JsonKey(name: 'booking_id') final  String bookingId;
@override final  BookingStatus status;
@override@JsonKey(name: 'waitlist_position') final  int? waitlistPosition;
@override@JsonKey(name: 'idempotent_replay') final  bool idempotentReplay;

/// Create a copy of BookingActionOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingActionOutcomeCopyWith<_BookingActionOutcome> get copyWith => __$BookingActionOutcomeCopyWithImpl<_BookingActionOutcome>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingActionOutcomeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingActionOutcome&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.status, status) || other.status == status)&&(identical(other.waitlistPosition, waitlistPosition) || other.waitlistPosition == waitlistPosition)&&(identical(other.idempotentReplay, idempotentReplay) || other.idempotentReplay == idempotentReplay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,bookingId,status,waitlistPosition,idempotentReplay);
}

@override
String toString() {
    return 'BookingActionOutcome(bookingId: $bookingId, status: $status, waitlistPosition: $waitlistPosition, idempotentReplay: $idempotentReplay)';
}


}

/// @nodoc
abstract mixin class _$BookingActionOutcomeCopyWith<$Res> implements $BookingActionOutcomeCopyWith<$Res> {
  factory _$BookingActionOutcomeCopyWith(_BookingActionOutcome value, $Res Function(_BookingActionOutcome) _then) = __$BookingActionOutcomeCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'booking_id') String bookingId, BookingStatus status,@JsonKey(name: 'waitlist_position') int? waitlistPosition,@JsonKey(name: 'idempotent_replay') bool idempotentReplay
});




}
/// @nodoc
class __$BookingActionOutcomeCopyWithImpl<$Res>
    implements _$BookingActionOutcomeCopyWith<$Res> {
  __$BookingActionOutcomeCopyWithImpl(this._self, this._then);

  final _BookingActionOutcome _self;
  final $Res Function(_BookingActionOutcome) _then;

/// Create a copy of BookingActionOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookingId = null,Object? status = null,Object? waitlistPosition = freezed,Object? idempotentReplay = null,}) {
  return _then(_BookingActionOutcome(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,waitlistPosition: freezed == waitlistPosition ? _self.waitlistPosition : waitlistPosition // ignore: cast_nullable_to_non_nullable
as int?,idempotentReplay: null == idempotentReplay ? _self.idempotentReplay : idempotentReplay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$CancelBookingOutcome {

 BookingStatus get status;@JsonKey(name: 'refunded_credits') int get refundedCredits;@JsonKey(name: 'promoted_booking_id') String? get promotedBookingId;@JsonKey(name: 'idempotent_replay') bool get idempotentReplay;
/// Create a copy of CancelBookingOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CancelBookingOutcomeCopyWith<CancelBookingOutcome> get copyWith => _$CancelBookingOutcomeCopyWithImpl<CancelBookingOutcome>(this as CancelBookingOutcome, _$identity);

  /// Serializes this CancelBookingOutcome to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CancelBookingOutcome;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CancelBookingOutcome&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.refundedCredits, _this.refundedCredits) || other.refundedCredits == _this.refundedCredits)&&(identical(other.promotedBookingId, _this.promotedBookingId) || other.promotedBookingId == _this.promotedBookingId)&&(identical(other.idempotentReplay, _this.idempotentReplay) || other.idempotentReplay == _this.idempotentReplay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CancelBookingOutcome;
  return Object.hash(runtimeType,_this.status,_this.refundedCredits,_this.promotedBookingId,_this.idempotentReplay);
}

@override
String toString() {
  final _this = this as CancelBookingOutcome;
  return 'CancelBookingOutcome(status: ${_this.status}, refundedCredits: ${_this.refundedCredits}, promotedBookingId: ${_this.promotedBookingId}, idempotentReplay: ${_this.idempotentReplay})';
}


}

/// @nodoc
abstract mixin class $CancelBookingOutcomeCopyWith<$Res>  {
  factory $CancelBookingOutcomeCopyWith(CancelBookingOutcome value, $Res Function(CancelBookingOutcome) _then) = _$CancelBookingOutcomeCopyWithImpl;
@useResult
$Res call({
 BookingStatus status,@JsonKey(name: 'refunded_credits') int refundedCredits,@JsonKey(name: 'promoted_booking_id') String? promotedBookingId,@JsonKey(name: 'idempotent_replay') bool idempotentReplay
});




}
/// @nodoc
class _$CancelBookingOutcomeCopyWithImpl<$Res>
    implements $CancelBookingOutcomeCopyWith<$Res> {
  _$CancelBookingOutcomeCopyWithImpl(this._self, this._then);

  final CancelBookingOutcome _self;
  final $Res Function(CancelBookingOutcome) _then;

/// Create a copy of CancelBookingOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? refundedCredits = null,Object? promotedBookingId = freezed,Object? idempotentReplay = null,}) {
  return _then(CancelBookingOutcome(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,refundedCredits: null == refundedCredits ? _self.refundedCredits : refundedCredits // ignore: cast_nullable_to_non_nullable
as int,promotedBookingId: freezed == promotedBookingId ? _self.promotedBookingId : promotedBookingId // ignore: cast_nullable_to_non_nullable
as String?,idempotentReplay: null == idempotentReplay ? _self.idempotentReplay : idempotentReplay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CancelBookingOutcome].
extension CancelBookingOutcomePatterns on CancelBookingOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CancelBookingOutcome value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CancelBookingOutcome() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CancelBookingOutcome value)  $default,){
final _that = this;
switch (_that) {
case _CancelBookingOutcome():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CancelBookingOutcome value)?  $default,){
final _that = this;
switch (_that) {
case _CancelBookingOutcome() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BookingStatus status, @JsonKey(name: 'refunded_credits')  int refundedCredits, @JsonKey(name: 'promoted_booking_id')  String? promotedBookingId, @JsonKey(name: 'idempotent_replay')  bool idempotentReplay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CancelBookingOutcome() when $default != null:
return $default(_that.status,_that.refundedCredits,_that.promotedBookingId,_that.idempotentReplay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BookingStatus status, @JsonKey(name: 'refunded_credits')  int refundedCredits, @JsonKey(name: 'promoted_booking_id')  String? promotedBookingId, @JsonKey(name: 'idempotent_replay')  bool idempotentReplay)  $default,) {final _that = this;
switch (_that) {
case _CancelBookingOutcome():
return $default(_that.status,_that.refundedCredits,_that.promotedBookingId,_that.idempotentReplay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BookingStatus status, @JsonKey(name: 'refunded_credits')  int refundedCredits, @JsonKey(name: 'promoted_booking_id')  String? promotedBookingId, @JsonKey(name: 'idempotent_replay')  bool idempotentReplay)?  $default,) {final _that = this;
switch (_that) {
case _CancelBookingOutcome() when $default != null:
return $default(_that.status,_that.refundedCredits,_that.promotedBookingId,_that.idempotentReplay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CancelBookingOutcome implements CancelBookingOutcome {
  const _CancelBookingOutcome({required this.status, @JsonKey(name: 'refunded_credits') this.refundedCredits = 0, @JsonKey(name: 'promoted_booking_id') this.promotedBookingId, @JsonKey(name: 'idempotent_replay') this.idempotentReplay = false});
  factory _CancelBookingOutcome.fromJson(Map<String, dynamic> json) => _$CancelBookingOutcomeFromJson(json);

@override final  BookingStatus status;
@override@JsonKey(name: 'refunded_credits') final  int refundedCredits;
@override@JsonKey(name: 'promoted_booking_id') final  String? promotedBookingId;
@override@JsonKey(name: 'idempotent_replay') final  bool idempotentReplay;

/// Create a copy of CancelBookingOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CancelBookingOutcomeCopyWith<_CancelBookingOutcome> get copyWith => __$CancelBookingOutcomeCopyWithImpl<_CancelBookingOutcome>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CancelBookingOutcomeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CancelBookingOutcome&&(identical(other.status, status) || other.status == status)&&(identical(other.refundedCredits, refundedCredits) || other.refundedCredits == refundedCredits)&&(identical(other.promotedBookingId, promotedBookingId) || other.promotedBookingId == promotedBookingId)&&(identical(other.idempotentReplay, idempotentReplay) || other.idempotentReplay == idempotentReplay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,refundedCredits,promotedBookingId,idempotentReplay);
}

@override
String toString() {
    return 'CancelBookingOutcome(status: $status, refundedCredits: $refundedCredits, promotedBookingId: $promotedBookingId, idempotentReplay: $idempotentReplay)';
}


}

/// @nodoc
abstract mixin class _$CancelBookingOutcomeCopyWith<$Res> implements $CancelBookingOutcomeCopyWith<$Res> {
  factory _$CancelBookingOutcomeCopyWith(_CancelBookingOutcome value, $Res Function(_CancelBookingOutcome) _then) = __$CancelBookingOutcomeCopyWithImpl;
@override @useResult
$Res call({
 BookingStatus status,@JsonKey(name: 'refunded_credits') int refundedCredits,@JsonKey(name: 'promoted_booking_id') String? promotedBookingId,@JsonKey(name: 'idempotent_replay') bool idempotentReplay
});




}
/// @nodoc
class __$CancelBookingOutcomeCopyWithImpl<$Res>
    implements _$CancelBookingOutcomeCopyWith<$Res> {
  __$CancelBookingOutcomeCopyWithImpl(this._self, this._then);

  final _CancelBookingOutcome _self;
  final $Res Function(_CancelBookingOutcome) _then;

/// Create a copy of CancelBookingOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? refundedCredits = null,Object? promotedBookingId = freezed,Object? idempotentReplay = null,}) {
  return _then(_CancelBookingOutcome(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,refundedCredits: null == refundedCredits ? _self.refundedCredits : refundedCredits // ignore: cast_nullable_to_non_nullable
as int,promotedBookingId: freezed == promotedBookingId ? _self.promotedBookingId : promotedBookingId // ignore: cast_nullable_to_non_nullable
as String?,idempotentReplay: null == idempotentReplay ? _self.idempotentReplay : idempotentReplay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AssignableInstructor {

@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'display_name') String get displayName;@JsonKey(name: 'role_code') String get roleCode;@JsonKey(name: 'role_display_name') String get roleDisplayName;
/// Create a copy of AssignableInstructor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignableInstructorCopyWith<AssignableInstructor> get copyWith => _$AssignableInstructorCopyWithImpl<AssignableInstructor>(this as AssignableInstructor, _$identity);

  /// Serializes this AssignableInstructor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AssignableInstructor;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignableInstructor&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.roleCode, _this.roleCode) || other.roleCode == _this.roleCode)&&(identical(other.roleDisplayName, _this.roleDisplayName) || other.roleDisplayName == _this.roleDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AssignableInstructor;
  return Object.hash(runtimeType,_this.userId,_this.displayName,_this.roleCode,_this.roleDisplayName);
}

@override
String toString() {
  final _this = this as AssignableInstructor;
  return 'AssignableInstructor(userId: ${_this.userId}, displayName: ${_this.displayName}, roleCode: ${_this.roleCode}, roleDisplayName: ${_this.roleDisplayName})';
}


}

/// @nodoc
abstract mixin class $AssignableInstructorCopyWith<$Res>  {
  factory $AssignableInstructorCopyWith(AssignableInstructor value, $Res Function(AssignableInstructor) _then) = _$AssignableInstructorCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'role_code') String roleCode,@JsonKey(name: 'role_display_name') String roleDisplayName
});




}
/// @nodoc
class _$AssignableInstructorCopyWithImpl<$Res>
    implements $AssignableInstructorCopyWith<$Res> {
  _$AssignableInstructorCopyWithImpl(this._self, this._then);

  final AssignableInstructor _self;
  final $Res Function(AssignableInstructor) _then;

/// Create a copy of AssignableInstructor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? displayName = null,Object? roleCode = null,Object? roleDisplayName = null,}) {
  return _then(AssignableInstructor(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,roleCode: null == roleCode ? _self.roleCode : roleCode // ignore: cast_nullable_to_non_nullable
as String,roleDisplayName: null == roleDisplayName ? _self.roleDisplayName : roleDisplayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AssignableInstructor].
extension AssignableInstructorPatterns on AssignableInstructor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssignableInstructor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssignableInstructor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssignableInstructor value)  $default,){
final _that = this;
switch (_that) {
case _AssignableInstructor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssignableInstructor value)?  $default,){
final _that = this;
switch (_that) {
case _AssignableInstructor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'role_code')  String roleCode, @JsonKey(name: 'role_display_name')  String roleDisplayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssignableInstructor() when $default != null:
return $default(_that.userId,_that.displayName,_that.roleCode,_that.roleDisplayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'role_code')  String roleCode, @JsonKey(name: 'role_display_name')  String roleDisplayName)  $default,) {final _that = this;
switch (_that) {
case _AssignableInstructor():
return $default(_that.userId,_that.displayName,_that.roleCode,_that.roleDisplayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'role_code')  String roleCode, @JsonKey(name: 'role_display_name')  String roleDisplayName)?  $default,) {final _that = this;
switch (_that) {
case _AssignableInstructor() when $default != null:
return $default(_that.userId,_that.displayName,_that.roleCode,_that.roleDisplayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssignableInstructor implements AssignableInstructor {
  const _AssignableInstructor({@JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'display_name') required this.displayName, @JsonKey(name: 'role_code') this.roleCode = '', @JsonKey(name: 'role_display_name') this.roleDisplayName = ''});
  factory _AssignableInstructor.fromJson(Map<String, dynamic> json) => _$AssignableInstructorFromJson(json);

@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'display_name') final  String displayName;
@override@JsonKey(name: 'role_code') final  String roleCode;
@override@JsonKey(name: 'role_display_name') final  String roleDisplayName;

/// Create a copy of AssignableInstructor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssignableInstructorCopyWith<_AssignableInstructor> get copyWith => __$AssignableInstructorCopyWithImpl<_AssignableInstructor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignableInstructorToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssignableInstructor&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.roleCode, roleCode) || other.roleCode == roleCode)&&(identical(other.roleDisplayName, roleDisplayName) || other.roleDisplayName == roleDisplayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,userId,displayName,roleCode,roleDisplayName);
}

@override
String toString() {
    return 'AssignableInstructor(userId: $userId, displayName: $displayName, roleCode: $roleCode, roleDisplayName: $roleDisplayName)';
}


}

/// @nodoc
abstract mixin class _$AssignableInstructorCopyWith<$Res> implements $AssignableInstructorCopyWith<$Res> {
  factory _$AssignableInstructorCopyWith(_AssignableInstructor value, $Res Function(_AssignableInstructor) _then) = __$AssignableInstructorCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'role_code') String roleCode,@JsonKey(name: 'role_display_name') String roleDisplayName
});




}
/// @nodoc
class __$AssignableInstructorCopyWithImpl<$Res>
    implements _$AssignableInstructorCopyWith<$Res> {
  __$AssignableInstructorCopyWithImpl(this._self, this._then);

  final _AssignableInstructor _self;
  final $Res Function(_AssignableInstructor) _then;

/// Create a copy of AssignableInstructor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? displayName = null,Object? roleCode = null,Object? roleDisplayName = null,}) {
  return _then(_AssignableInstructor(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,roleCode: null == roleCode ? _self.roleCode : roleCode // ignore: cast_nullable_to_non_nullable
as String,roleDisplayName: null == roleDisplayName ? _self.roleDisplayName : roleDisplayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
