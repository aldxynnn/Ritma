// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_export_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReportExportPayload {

@JsonKey(name: 'report_type') String get reportType;@JsonKey(name: 'organization_name') String get organizationName;@JsonKey(name: 'branch_scope') String get branchScope;@JsonKey(name: 'currency_code') String get currencyCode; String get timezone;@JsonKey(name: 'generated_at') DateTime get generatedAt; List<String> get columns; List<List<dynamic>> get rows;
/// Create a copy of ReportExportPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportExportPayloadCopyWith<ReportExportPayload> get copyWith => _$ReportExportPayloadCopyWithImpl<ReportExportPayload>(this as ReportExportPayload, _$identity);

  /// Serializes this ReportExportPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReportExportPayload;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportExportPayload&&(identical(other.reportType, _this.reportType) || other.reportType == _this.reportType)&&(identical(other.organizationName, _this.organizationName) || other.organizationName == _this.organizationName)&&(identical(other.branchScope, _this.branchScope) || other.branchScope == _this.branchScope)&&(identical(other.currencyCode, _this.currencyCode) || other.currencyCode == _this.currencyCode)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone)&&(identical(other.generatedAt, _this.generatedAt) || other.generatedAt == _this.generatedAt)&&const DeepCollectionEquality().equals(other.columns, _this.columns)&&const DeepCollectionEquality().equals(other.rows, _this.rows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReportExportPayload;
  return Object.hash(runtimeType,_this.reportType,_this.organizationName,_this.branchScope,_this.currencyCode,_this.timezone,_this.generatedAt,const DeepCollectionEquality().hash(_this.columns),const DeepCollectionEquality().hash(_this.rows));
}

@override
String toString() {
  final _this = this as ReportExportPayload;
  return 'ReportExportPayload(reportType: ${_this.reportType}, organizationName: ${_this.organizationName}, branchScope: ${_this.branchScope}, currencyCode: ${_this.currencyCode}, timezone: ${_this.timezone}, generatedAt: ${_this.generatedAt}, columns: ${_this.columns}, rows: ${_this.rows})';
}


}

/// @nodoc
abstract mixin class $ReportExportPayloadCopyWith<$Res>  {
  factory $ReportExportPayloadCopyWith(ReportExportPayload value, $Res Function(ReportExportPayload) _then) = _$ReportExportPayloadCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'report_type') String reportType,@JsonKey(name: 'organization_name') String organizationName,@JsonKey(name: 'branch_scope') String branchScope,@JsonKey(name: 'currency_code') String currencyCode, String timezone,@JsonKey(name: 'generated_at') DateTime generatedAt, List<String> columns, List<List<dynamic>> rows
});




}
/// @nodoc
class _$ReportExportPayloadCopyWithImpl<$Res>
    implements $ReportExportPayloadCopyWith<$Res> {
  _$ReportExportPayloadCopyWithImpl(this._self, this._then);

  final ReportExportPayload _self;
  final $Res Function(ReportExportPayload) _then;

/// Create a copy of ReportExportPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reportType = null,Object? organizationName = null,Object? branchScope = null,Object? currencyCode = null,Object? timezone = null,Object? generatedAt = null,Object? columns = null,Object? rows = null,}) {
  return _then(ReportExportPayload(
reportType: null == reportType ? _self.reportType : reportType // ignore: cast_nullable_to_non_nullable
as String,organizationName: null == organizationName ? _self.organizationName : organizationName // ignore: cast_nullable_to_non_nullable
as String,branchScope: null == branchScope ? _self.branchScope : branchScope // ignore: cast_nullable_to_non_nullable
as String,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,columns: null == columns ? _self.columns : columns // ignore: cast_nullable_to_non_nullable
as List<String>,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as List<List<dynamic>>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportExportPayload].
extension ReportExportPayloadPatterns on ReportExportPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportExportPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportExportPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportExportPayload value)  $default,){
final _that = this;
switch (_that) {
case _ReportExportPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportExportPayload value)?  $default,){
final _that = this;
switch (_that) {
case _ReportExportPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'report_type')  String reportType, @JsonKey(name: 'organization_name')  String organizationName, @JsonKey(name: 'branch_scope')  String branchScope, @JsonKey(name: 'currency_code')  String currencyCode,  String timezone, @JsonKey(name: 'generated_at')  DateTime generatedAt,  List<String> columns,  List<List<dynamic>> rows)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportExportPayload() when $default != null:
return $default(_that.reportType,_that.organizationName,_that.branchScope,_that.currencyCode,_that.timezone,_that.generatedAt,_that.columns,_that.rows);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'report_type')  String reportType, @JsonKey(name: 'organization_name')  String organizationName, @JsonKey(name: 'branch_scope')  String branchScope, @JsonKey(name: 'currency_code')  String currencyCode,  String timezone, @JsonKey(name: 'generated_at')  DateTime generatedAt,  List<String> columns,  List<List<dynamic>> rows)  $default,) {final _that = this;
switch (_that) {
case _ReportExportPayload():
return $default(_that.reportType,_that.organizationName,_that.branchScope,_that.currencyCode,_that.timezone,_that.generatedAt,_that.columns,_that.rows);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'report_type')  String reportType, @JsonKey(name: 'organization_name')  String organizationName, @JsonKey(name: 'branch_scope')  String branchScope, @JsonKey(name: 'currency_code')  String currencyCode,  String timezone, @JsonKey(name: 'generated_at')  DateTime generatedAt,  List<String> columns,  List<List<dynamic>> rows)?  $default,) {final _that = this;
switch (_that) {
case _ReportExportPayload() when $default != null:
return $default(_that.reportType,_that.organizationName,_that.branchScope,_that.currencyCode,_that.timezone,_that.generatedAt,_that.columns,_that.rows);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportExportPayload implements ReportExportPayload {
  const _ReportExportPayload({@JsonKey(name: 'report_type') required this.reportType, @JsonKey(name: 'organization_name') required this.organizationName, @JsonKey(name: 'branch_scope') required this.branchScope, @JsonKey(name: 'currency_code') this.currencyCode = 'USD', this.timezone = 'UTC', @JsonKey(name: 'generated_at') required this.generatedAt,  List<String> columns = const <String>[],  List<List<dynamic>> rows = const <List<dynamic>>[]}): _columns = columns,_rows = rows;
  factory _ReportExportPayload.fromJson(Map<String, dynamic> json) => _$ReportExportPayloadFromJson(json);

@override@JsonKey(name: 'report_type') final  String reportType;
@override@JsonKey(name: 'organization_name') final  String organizationName;
@override@JsonKey(name: 'branch_scope') final  String branchScope;
@override@JsonKey(name: 'currency_code') final  String currencyCode;
@override@JsonKey() final  String timezone;
@override@JsonKey(name: 'generated_at') final  DateTime generatedAt;
 final  List<String> _columns;
@override@JsonKey() List<String> get columns {
  if (_columns is EqualUnmodifiableListView) return _columns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_columns);
}

 final  List<List<dynamic>> _rows;
@override@JsonKey() List<List<dynamic>> get rows {
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rows);
}


/// Create a copy of ReportExportPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportExportPayloadCopyWith<_ReportExportPayload> get copyWith => __$ReportExportPayloadCopyWithImpl<_ReportExportPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportExportPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportExportPayload&&(identical(other.reportType, reportType) || other.reportType == reportType)&&(identical(other.organizationName, organizationName) || other.organizationName == organizationName)&&(identical(other.branchScope, branchScope) || other.branchScope == branchScope)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&const DeepCollectionEquality().equals(other.columns, _columns)&&const DeepCollectionEquality().equals(other.rows, _rows));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,reportType,organizationName,branchScope,currencyCode,timezone,generatedAt,const DeepCollectionEquality().hash(_columns),const DeepCollectionEquality().hash(_rows));
}

@override
String toString() {
    return 'ReportExportPayload(reportType: $reportType, organizationName: $organizationName, branchScope: $branchScope, currencyCode: $currencyCode, timezone: $timezone, generatedAt: $generatedAt, columns: $columns, rows: $rows)';
}


}

/// @nodoc
abstract mixin class _$ReportExportPayloadCopyWith<$Res> implements $ReportExportPayloadCopyWith<$Res> {
  factory _$ReportExportPayloadCopyWith(_ReportExportPayload value, $Res Function(_ReportExportPayload) _then) = __$ReportExportPayloadCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'report_type') String reportType,@JsonKey(name: 'organization_name') String organizationName,@JsonKey(name: 'branch_scope') String branchScope,@JsonKey(name: 'currency_code') String currencyCode, String timezone,@JsonKey(name: 'generated_at') DateTime generatedAt, List<String> columns, List<List<dynamic>> rows
});




}
/// @nodoc
class __$ReportExportPayloadCopyWithImpl<$Res>
    implements _$ReportExportPayloadCopyWith<$Res> {
  __$ReportExportPayloadCopyWithImpl(this._self, this._then);

  final _ReportExportPayload _self;
  final $Res Function(_ReportExportPayload) _then;

/// Create a copy of ReportExportPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reportType = null,Object? organizationName = null,Object? branchScope = null,Object? currencyCode = null,Object? timezone = null,Object? generatedAt = null,Object? columns = null,Object? rows = null,}) {
  return _then(_ReportExportPayload(
reportType: null == reportType ? _self.reportType : reportType // ignore: cast_nullable_to_non_nullable
as String,organizationName: null == organizationName ? _self.organizationName : organizationName // ignore: cast_nullable_to_non_nullable
as String,branchScope: null == branchScope ? _self.branchScope : branchScope // ignore: cast_nullable_to_non_nullable
as String,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,columns: null == columns ? _self._columns : columns // ignore: cast_nullable_to_non_nullable
as List<String>,rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<List<dynamic>>,
  ));
}


}

// dart format on
