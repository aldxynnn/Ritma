// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'operational_metrics_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OperationalMetricsModel {

@JsonKey(name: 'active_members') int get activeMembers;@JsonKey(name: 'today_visits') int get todayVisits;@JsonKey(name: 'window_revenue_minor') int get windowRevenueMinor;@JsonKey(name: 'class_capacity_total') int get classCapacityTotal;@JsonKey(name: 'class_confirmed_total') int get classConfirmedTotal;@JsonKey(name: 'class_occupancy_pct') double get classOccupancyPct;@JsonKey(name: 'expiring_entitlements_7d') int get expiringEntitlements7d;
/// Create a copy of OperationalMetricsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OperationalMetricsModelCopyWith<OperationalMetricsModel> get copyWith => _$OperationalMetricsModelCopyWithImpl<OperationalMetricsModel>(this as OperationalMetricsModel, _$identity);

  /// Serializes this OperationalMetricsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OperationalMetricsModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OperationalMetricsModel&&(identical(other.activeMembers, _this.activeMembers) || other.activeMembers == _this.activeMembers)&&(identical(other.todayVisits, _this.todayVisits) || other.todayVisits == _this.todayVisits)&&(identical(other.windowRevenueMinor, _this.windowRevenueMinor) || other.windowRevenueMinor == _this.windowRevenueMinor)&&(identical(other.classCapacityTotal, _this.classCapacityTotal) || other.classCapacityTotal == _this.classCapacityTotal)&&(identical(other.classConfirmedTotal, _this.classConfirmedTotal) || other.classConfirmedTotal == _this.classConfirmedTotal)&&(identical(other.classOccupancyPct, _this.classOccupancyPct) || other.classOccupancyPct == _this.classOccupancyPct)&&(identical(other.expiringEntitlements7d, _this.expiringEntitlements7d) || other.expiringEntitlements7d == _this.expiringEntitlements7d));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OperationalMetricsModel;
  return Object.hash(runtimeType,_this.activeMembers,_this.todayVisits,_this.windowRevenueMinor,_this.classCapacityTotal,_this.classConfirmedTotal,_this.classOccupancyPct,_this.expiringEntitlements7d);
}

@override
String toString() {
  final _this = this as OperationalMetricsModel;
  return 'OperationalMetricsModel(activeMembers: ${_this.activeMembers}, todayVisits: ${_this.todayVisits}, windowRevenueMinor: ${_this.windowRevenueMinor}, classCapacityTotal: ${_this.classCapacityTotal}, classConfirmedTotal: ${_this.classConfirmedTotal}, classOccupancyPct: ${_this.classOccupancyPct}, expiringEntitlements7d: ${_this.expiringEntitlements7d})';
}


}

/// @nodoc
abstract mixin class $OperationalMetricsModelCopyWith<$Res>  {
  factory $OperationalMetricsModelCopyWith(OperationalMetricsModel value, $Res Function(OperationalMetricsModel) _then) = _$OperationalMetricsModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'active_members') int activeMembers,@JsonKey(name: 'today_visits') int todayVisits,@JsonKey(name: 'window_revenue_minor') int windowRevenueMinor,@JsonKey(name: 'class_capacity_total') int classCapacityTotal,@JsonKey(name: 'class_confirmed_total') int classConfirmedTotal,@JsonKey(name: 'class_occupancy_pct') double classOccupancyPct,@JsonKey(name: 'expiring_entitlements_7d') int expiringEntitlements7d
});




}
/// @nodoc
class _$OperationalMetricsModelCopyWithImpl<$Res>
    implements $OperationalMetricsModelCopyWith<$Res> {
  _$OperationalMetricsModelCopyWithImpl(this._self, this._then);

  final OperationalMetricsModel _self;
  final $Res Function(OperationalMetricsModel) _then;

/// Create a copy of OperationalMetricsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activeMembers = null,Object? todayVisits = null,Object? windowRevenueMinor = null,Object? classCapacityTotal = null,Object? classConfirmedTotal = null,Object? classOccupancyPct = null,Object? expiringEntitlements7d = null,}) {
  return _then(OperationalMetricsModel(
activeMembers: null == activeMembers ? _self.activeMembers : activeMembers // ignore: cast_nullable_to_non_nullable
as int,todayVisits: null == todayVisits ? _self.todayVisits : todayVisits // ignore: cast_nullable_to_non_nullable
as int,windowRevenueMinor: null == windowRevenueMinor ? _self.windowRevenueMinor : windowRevenueMinor // ignore: cast_nullable_to_non_nullable
as int,classCapacityTotal: null == classCapacityTotal ? _self.classCapacityTotal : classCapacityTotal // ignore: cast_nullable_to_non_nullable
as int,classConfirmedTotal: null == classConfirmedTotal ? _self.classConfirmedTotal : classConfirmedTotal // ignore: cast_nullable_to_non_nullable
as int,classOccupancyPct: null == classOccupancyPct ? _self.classOccupancyPct : classOccupancyPct // ignore: cast_nullable_to_non_nullable
as double,expiringEntitlements7d: null == expiringEntitlements7d ? _self.expiringEntitlements7d : expiringEntitlements7d // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OperationalMetricsModel].
extension OperationalMetricsModelPatterns on OperationalMetricsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OperationalMetricsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OperationalMetricsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OperationalMetricsModel value)  $default,){
final _that = this;
switch (_that) {
case _OperationalMetricsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OperationalMetricsModel value)?  $default,){
final _that = this;
switch (_that) {
case _OperationalMetricsModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'active_members')  int activeMembers, @JsonKey(name: 'today_visits')  int todayVisits, @JsonKey(name: 'window_revenue_minor')  int windowRevenueMinor, @JsonKey(name: 'class_capacity_total')  int classCapacityTotal, @JsonKey(name: 'class_confirmed_total')  int classConfirmedTotal, @JsonKey(name: 'class_occupancy_pct')  double classOccupancyPct, @JsonKey(name: 'expiring_entitlements_7d')  int expiringEntitlements7d)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OperationalMetricsModel() when $default != null:
return $default(_that.activeMembers,_that.todayVisits,_that.windowRevenueMinor,_that.classCapacityTotal,_that.classConfirmedTotal,_that.classOccupancyPct,_that.expiringEntitlements7d);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'active_members')  int activeMembers, @JsonKey(name: 'today_visits')  int todayVisits, @JsonKey(name: 'window_revenue_minor')  int windowRevenueMinor, @JsonKey(name: 'class_capacity_total')  int classCapacityTotal, @JsonKey(name: 'class_confirmed_total')  int classConfirmedTotal, @JsonKey(name: 'class_occupancy_pct')  double classOccupancyPct, @JsonKey(name: 'expiring_entitlements_7d')  int expiringEntitlements7d)  $default,) {final _that = this;
switch (_that) {
case _OperationalMetricsModel():
return $default(_that.activeMembers,_that.todayVisits,_that.windowRevenueMinor,_that.classCapacityTotal,_that.classConfirmedTotal,_that.classOccupancyPct,_that.expiringEntitlements7d);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'active_members')  int activeMembers, @JsonKey(name: 'today_visits')  int todayVisits, @JsonKey(name: 'window_revenue_minor')  int windowRevenueMinor, @JsonKey(name: 'class_capacity_total')  int classCapacityTotal, @JsonKey(name: 'class_confirmed_total')  int classConfirmedTotal, @JsonKey(name: 'class_occupancy_pct')  double classOccupancyPct, @JsonKey(name: 'expiring_entitlements_7d')  int expiringEntitlements7d)?  $default,) {final _that = this;
switch (_that) {
case _OperationalMetricsModel() when $default != null:
return $default(_that.activeMembers,_that.todayVisits,_that.windowRevenueMinor,_that.classCapacityTotal,_that.classConfirmedTotal,_that.classOccupancyPct,_that.expiringEntitlements7d);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OperationalMetricsModel implements OperationalMetricsModel {
  const _OperationalMetricsModel({@JsonKey(name: 'active_members') this.activeMembers = 0, @JsonKey(name: 'today_visits') this.todayVisits = 0, @JsonKey(name: 'window_revenue_minor') this.windowRevenueMinor = 0, @JsonKey(name: 'class_capacity_total') this.classCapacityTotal = 0, @JsonKey(name: 'class_confirmed_total') this.classConfirmedTotal = 0, @JsonKey(name: 'class_occupancy_pct') this.classOccupancyPct = 0.0, @JsonKey(name: 'expiring_entitlements_7d') this.expiringEntitlements7d = 0});
  factory _OperationalMetricsModel.fromJson(Map<String, dynamic> json) => _$OperationalMetricsModelFromJson(json);

@override@JsonKey(name: 'active_members') final  int activeMembers;
@override@JsonKey(name: 'today_visits') final  int todayVisits;
@override@JsonKey(name: 'window_revenue_minor') final  int windowRevenueMinor;
@override@JsonKey(name: 'class_capacity_total') final  int classCapacityTotal;
@override@JsonKey(name: 'class_confirmed_total') final  int classConfirmedTotal;
@override@JsonKey(name: 'class_occupancy_pct') final  double classOccupancyPct;
@override@JsonKey(name: 'expiring_entitlements_7d') final  int expiringEntitlements7d;

/// Create a copy of OperationalMetricsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OperationalMetricsModelCopyWith<_OperationalMetricsModel> get copyWith => __$OperationalMetricsModelCopyWithImpl<_OperationalMetricsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OperationalMetricsModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OperationalMetricsModel&&(identical(other.activeMembers, activeMembers) || other.activeMembers == activeMembers)&&(identical(other.todayVisits, todayVisits) || other.todayVisits == todayVisits)&&(identical(other.windowRevenueMinor, windowRevenueMinor) || other.windowRevenueMinor == windowRevenueMinor)&&(identical(other.classCapacityTotal, classCapacityTotal) || other.classCapacityTotal == classCapacityTotal)&&(identical(other.classConfirmedTotal, classConfirmedTotal) || other.classConfirmedTotal == classConfirmedTotal)&&(identical(other.classOccupancyPct, classOccupancyPct) || other.classOccupancyPct == classOccupancyPct)&&(identical(other.expiringEntitlements7d, expiringEntitlements7d) || other.expiringEntitlements7d == expiringEntitlements7d));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,activeMembers,todayVisits,windowRevenueMinor,classCapacityTotal,classConfirmedTotal,classOccupancyPct,expiringEntitlements7d);
}

@override
String toString() {
    return 'OperationalMetricsModel(activeMembers: $activeMembers, todayVisits: $todayVisits, windowRevenueMinor: $windowRevenueMinor, classCapacityTotal: $classCapacityTotal, classConfirmedTotal: $classConfirmedTotal, classOccupancyPct: $classOccupancyPct, expiringEntitlements7d: $expiringEntitlements7d)';
}


}

/// @nodoc
abstract mixin class _$OperationalMetricsModelCopyWith<$Res> implements $OperationalMetricsModelCopyWith<$Res> {
  factory _$OperationalMetricsModelCopyWith(_OperationalMetricsModel value, $Res Function(_OperationalMetricsModel) _then) = __$OperationalMetricsModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'active_members') int activeMembers,@JsonKey(name: 'today_visits') int todayVisits,@JsonKey(name: 'window_revenue_minor') int windowRevenueMinor,@JsonKey(name: 'class_capacity_total') int classCapacityTotal,@JsonKey(name: 'class_confirmed_total') int classConfirmedTotal,@JsonKey(name: 'class_occupancy_pct') double classOccupancyPct,@JsonKey(name: 'expiring_entitlements_7d') int expiringEntitlements7d
});




}
/// @nodoc
class __$OperationalMetricsModelCopyWithImpl<$Res>
    implements _$OperationalMetricsModelCopyWith<$Res> {
  __$OperationalMetricsModelCopyWithImpl(this._self, this._then);

  final _OperationalMetricsModel _self;
  final $Res Function(_OperationalMetricsModel) _then;

/// Create a copy of OperationalMetricsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activeMembers = null,Object? todayVisits = null,Object? windowRevenueMinor = null,Object? classCapacityTotal = null,Object? classConfirmedTotal = null,Object? classOccupancyPct = null,Object? expiringEntitlements7d = null,}) {
  return _then(_OperationalMetricsModel(
activeMembers: null == activeMembers ? _self.activeMembers : activeMembers // ignore: cast_nullable_to_non_nullable
as int,todayVisits: null == todayVisits ? _self.todayVisits : todayVisits // ignore: cast_nullable_to_non_nullable
as int,windowRevenueMinor: null == windowRevenueMinor ? _self.windowRevenueMinor : windowRevenueMinor // ignore: cast_nullable_to_non_nullable
as int,classCapacityTotal: null == classCapacityTotal ? _self.classCapacityTotal : classCapacityTotal // ignore: cast_nullable_to_non_nullable
as int,classConfirmedTotal: null == classConfirmedTotal ? _self.classConfirmedTotal : classConfirmedTotal // ignore: cast_nullable_to_non_nullable
as int,classOccupancyPct: null == classOccupancyPct ? _self.classOccupancyPct : classOccupancyPct // ignore: cast_nullable_to_non_nullable
as double,expiringEntitlements7d: null == expiringEntitlements7d ? _self.expiringEntitlements7d : expiringEntitlements7d // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
