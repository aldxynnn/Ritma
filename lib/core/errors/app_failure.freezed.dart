// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppFailure {

 String get message;
/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppFailureCopyWith<AppFailure> get copyWith => _$AppFailureCopyWithImpl<AppFailure>(this as AppFailure, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AppFailure;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppFailure&&(identical(other.message, _this.message) || other.message == _this.message));
}


@override
int get hashCode {
  final _this = this as AppFailure;
  return Object.hash(runtimeType,_this.message);
}

@override
String toString() {
  final _this = this as AppFailure;
  return 'AppFailure(message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $AppFailureCopyWith<$Res>  {
  factory $AppFailureCopyWith(AppFailure value, $Res Function(AppFailure) _then) = _$AppFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$AppFailureCopyWithImpl<$Res>
    implements $AppFailureCopyWith<$Res> {
  _$AppFailureCopyWithImpl(this._self, this._then);

  final AppFailure _self;
  final $Res Function(AppFailure) _then;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AppFailure].
extension AppFailurePatterns on AppFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NetworkFailure value)?  network,TResult Function( UnauthorizedFailure value)?  unauthorized,TResult Function( ForbiddenFailure value)?  forbidden,TResult Function( NotFoundFailure value)?  notFound,TResult Function( ConflictFailure value)?  conflict,TResult Function( ValidationFailure value)?  validation,TResult Function( UnexpectedFailure value)?  unexpected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network(_that);case UnauthorizedFailure() when unauthorized != null:
return unauthorized(_that);case ForbiddenFailure() when forbidden != null:
return forbidden(_that);case NotFoundFailure() when notFound != null:
return notFound(_that);case ConflictFailure() when conflict != null:
return conflict(_that);case ValidationFailure() when validation != null:
return validation(_that);case UnexpectedFailure() when unexpected != null:
return unexpected(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NetworkFailure value)  network,required TResult Function( UnauthorizedFailure value)  unauthorized,required TResult Function( ForbiddenFailure value)  forbidden,required TResult Function( NotFoundFailure value)  notFound,required TResult Function( ConflictFailure value)  conflict,required TResult Function( ValidationFailure value)  validation,required TResult Function( UnexpectedFailure value)  unexpected,}){
final _that = this;
switch (_that) {
case NetworkFailure():
return network(_that);case UnauthorizedFailure():
return unauthorized(_that);case ForbiddenFailure():
return forbidden(_that);case NotFoundFailure():
return notFound(_that);case ConflictFailure():
return conflict(_that);case ValidationFailure():
return validation(_that);case UnexpectedFailure():
return unexpected(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NetworkFailure value)?  network,TResult? Function( UnauthorizedFailure value)?  unauthorized,TResult? Function( ForbiddenFailure value)?  forbidden,TResult? Function( NotFoundFailure value)?  notFound,TResult? Function( ConflictFailure value)?  conflict,TResult? Function( ValidationFailure value)?  validation,TResult? Function( UnexpectedFailure value)?  unexpected,}){
final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network(_that);case UnauthorizedFailure() when unauthorized != null:
return unauthorized(_that);case ForbiddenFailure() when forbidden != null:
return forbidden(_that);case NotFoundFailure() when notFound != null:
return notFound(_that);case ConflictFailure() when conflict != null:
return conflict(_that);case ValidationFailure() when validation != null:
return validation(_that);case UnexpectedFailure() when unexpected != null:
return unexpected(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String message,  Object? cause)?  network,TResult Function( String message,  Object? cause)?  unauthorized,TResult Function( String message,  String? requiredPermission)?  forbidden,TResult Function( String message,  String? resourceType)?  notFound,TResult Function( String message,  String? code)?  conflict,TResult Function( String message,  Map<String, String> fieldErrors)?  validation,TResult Function( String message,  Object? cause,  StackTrace? stackTrace)?  unexpected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network(_that.message,_that.cause);case UnauthorizedFailure() when unauthorized != null:
return unauthorized(_that.message,_that.cause);case ForbiddenFailure() when forbidden != null:
return forbidden(_that.message,_that.requiredPermission);case NotFoundFailure() when notFound != null:
return notFound(_that.message,_that.resourceType);case ConflictFailure() when conflict != null:
return conflict(_that.message,_that.code);case ValidationFailure() when validation != null:
return validation(_that.message,_that.fieldErrors);case UnexpectedFailure() when unexpected != null:
return unexpected(_that.message,_that.cause,_that.stackTrace);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String message,  Object? cause)  network,required TResult Function( String message,  Object? cause)  unauthorized,required TResult Function( String message,  String? requiredPermission)  forbidden,required TResult Function( String message,  String? resourceType)  notFound,required TResult Function( String message,  String? code)  conflict,required TResult Function( String message,  Map<String, String> fieldErrors)  validation,required TResult Function( String message,  Object? cause,  StackTrace? stackTrace)  unexpected,}) {final _that = this;
switch (_that) {
case NetworkFailure():
return network(_that.message,_that.cause);case UnauthorizedFailure():
return unauthorized(_that.message,_that.cause);case ForbiddenFailure():
return forbidden(_that.message,_that.requiredPermission);case NotFoundFailure():
return notFound(_that.message,_that.resourceType);case ConflictFailure():
return conflict(_that.message,_that.code);case ValidationFailure():
return validation(_that.message,_that.fieldErrors);case UnexpectedFailure():
return unexpected(_that.message,_that.cause,_that.stackTrace);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String message,  Object? cause)?  network,TResult? Function( String message,  Object? cause)?  unauthorized,TResult? Function( String message,  String? requiredPermission)?  forbidden,TResult? Function( String message,  String? resourceType)?  notFound,TResult? Function( String message,  String? code)?  conflict,TResult? Function( String message,  Map<String, String> fieldErrors)?  validation,TResult? Function( String message,  Object? cause,  StackTrace? stackTrace)?  unexpected,}) {final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network(_that.message,_that.cause);case UnauthorizedFailure() when unauthorized != null:
return unauthorized(_that.message,_that.cause);case ForbiddenFailure() when forbidden != null:
return forbidden(_that.message,_that.requiredPermission);case NotFoundFailure() when notFound != null:
return notFound(_that.message,_that.resourceType);case ConflictFailure() when conflict != null:
return conflict(_that.message,_that.code);case ValidationFailure() when validation != null:
return validation(_that.message,_that.fieldErrors);case UnexpectedFailure() when unexpected != null:
return unexpected(_that.message,_that.cause,_that.stackTrace);case _:
  return null;

}
}

}

/// @nodoc


class NetworkFailure implements AppFailure {
  const NetworkFailure({this.message = 'Unable to reach RITMA services. Check your connection.', this.cause});
  

@override@JsonKey() final  String message;
 final  Object? cause;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkFailureCopyWith<NetworkFailure> get copyWith => _$NetworkFailureCopyWithImpl<NetworkFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkFailure&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.cause, cause));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message,const DeepCollectionEquality().hash(cause));
}

@override
String toString() {
    return 'AppFailure.network(message: $message, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $NetworkFailureCopyWith<$Res> implements $AppFailureCopyWith<$Res> {
  factory $NetworkFailureCopyWith(NetworkFailure value, $Res Function(NetworkFailure) _then) = _$NetworkFailureCopyWithImpl;
@override @useResult
$Res call({
 String message, Object? cause
});




}
/// @nodoc
class _$NetworkFailureCopyWithImpl<$Res>
    implements $NetworkFailureCopyWith<$Res> {
  _$NetworkFailureCopyWithImpl(this._self, this._then);

  final NetworkFailure _self;
  final $Res Function(NetworkFailure) _then;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? cause = freezed,}) {
  return _then(NetworkFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause ,
  ));
}


}

/// @nodoc


class UnauthorizedFailure implements AppFailure {
  const UnauthorizedFailure({this.message = 'Your session has expired. Please sign in again.', this.cause});
  

@override@JsonKey() final  String message;
 final  Object? cause;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnauthorizedFailureCopyWith<UnauthorizedFailure> get copyWith => _$UnauthorizedFailureCopyWithImpl<UnauthorizedFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UnauthorizedFailure&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.cause, cause));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message,const DeepCollectionEquality().hash(cause));
}

@override
String toString() {
    return 'AppFailure.unauthorized(message: $message, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $UnauthorizedFailureCopyWith<$Res> implements $AppFailureCopyWith<$Res> {
  factory $UnauthorizedFailureCopyWith(UnauthorizedFailure value, $Res Function(UnauthorizedFailure) _then) = _$UnauthorizedFailureCopyWithImpl;
@override @useResult
$Res call({
 String message, Object? cause
});




}
/// @nodoc
class _$UnauthorizedFailureCopyWithImpl<$Res>
    implements $UnauthorizedFailureCopyWith<$Res> {
  _$UnauthorizedFailureCopyWithImpl(this._self, this._then);

  final UnauthorizedFailure _self;
  final $Res Function(UnauthorizedFailure) _then;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? cause = freezed,}) {
  return _then(UnauthorizedFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause ,
  ));
}


}

/// @nodoc


class ForbiddenFailure implements AppFailure {
  const ForbiddenFailure({this.message = 'You do not have permission to perform this action.', this.requiredPermission});
  

@override@JsonKey() final  String message;
 final  String? requiredPermission;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForbiddenFailureCopyWith<ForbiddenFailure> get copyWith => _$ForbiddenFailureCopyWithImpl<ForbiddenFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ForbiddenFailure&&(identical(other.message, message) || other.message == message)&&(identical(other.requiredPermission, requiredPermission) || other.requiredPermission == requiredPermission));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message,requiredPermission);
}

@override
String toString() {
    return 'AppFailure.forbidden(message: $message, requiredPermission: $requiredPermission)';
}


}

/// @nodoc
abstract mixin class $ForbiddenFailureCopyWith<$Res> implements $AppFailureCopyWith<$Res> {
  factory $ForbiddenFailureCopyWith(ForbiddenFailure value, $Res Function(ForbiddenFailure) _then) = _$ForbiddenFailureCopyWithImpl;
@override @useResult
$Res call({
 String message, String? requiredPermission
});




}
/// @nodoc
class _$ForbiddenFailureCopyWithImpl<$Res>
    implements $ForbiddenFailureCopyWith<$Res> {
  _$ForbiddenFailureCopyWithImpl(this._self, this._then);

  final ForbiddenFailure _self;
  final $Res Function(ForbiddenFailure) _then;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? requiredPermission = freezed,}) {
  return _then(ForbiddenFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,requiredPermission: freezed == requiredPermission ? _self.requiredPermission : requiredPermission // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class NotFoundFailure implements AppFailure {
  const NotFoundFailure({this.message = 'The requested resource could not be found.', this.resourceType});
  

@override@JsonKey() final  String message;
 final  String? resourceType;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotFoundFailureCopyWith<NotFoundFailure> get copyWith => _$NotFoundFailureCopyWithImpl<NotFoundFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NotFoundFailure&&(identical(other.message, message) || other.message == message)&&(identical(other.resourceType, resourceType) || other.resourceType == resourceType));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message,resourceType);
}

@override
String toString() {
    return 'AppFailure.notFound(message: $message, resourceType: $resourceType)';
}


}

/// @nodoc
abstract mixin class $NotFoundFailureCopyWith<$Res> implements $AppFailureCopyWith<$Res> {
  factory $NotFoundFailureCopyWith(NotFoundFailure value, $Res Function(NotFoundFailure) _then) = _$NotFoundFailureCopyWithImpl;
@override @useResult
$Res call({
 String message, String? resourceType
});




}
/// @nodoc
class _$NotFoundFailureCopyWithImpl<$Res>
    implements $NotFoundFailureCopyWith<$Res> {
  _$NotFoundFailureCopyWithImpl(this._self, this._then);

  final NotFoundFailure _self;
  final $Res Function(NotFoundFailure) _then;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? resourceType = freezed,}) {
  return _then(NotFoundFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,resourceType: freezed == resourceType ? _self.resourceType : resourceType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class ConflictFailure implements AppFailure {
  const ConflictFailure({required this.message, this.code});
  

@override final  String message;
 final  String? code;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConflictFailureCopyWith<ConflictFailure> get copyWith => _$ConflictFailureCopyWithImpl<ConflictFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConflictFailure&&(identical(other.message, message) || other.message == message)&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message,code);
}

@override
String toString() {
    return 'AppFailure.conflict(message: $message, code: $code)';
}


}

/// @nodoc
abstract mixin class $ConflictFailureCopyWith<$Res> implements $AppFailureCopyWith<$Res> {
  factory $ConflictFailureCopyWith(ConflictFailure value, $Res Function(ConflictFailure) _then) = _$ConflictFailureCopyWithImpl;
@override @useResult
$Res call({
 String message, String? code
});




}
/// @nodoc
class _$ConflictFailureCopyWithImpl<$Res>
    implements $ConflictFailureCopyWith<$Res> {
  _$ConflictFailureCopyWithImpl(this._self, this._then);

  final ConflictFailure _self;
  final $Res Function(ConflictFailure) _then;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? code = freezed,}) {
  return _then(ConflictFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class ValidationFailure implements AppFailure {
  const ValidationFailure({required this.message,  Map<String, String> fieldErrors = const <String, String>{}}): _fieldErrors = fieldErrors;
  

@override final  String message;
 final  Map<String, String> _fieldErrors;
@JsonKey() Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}


/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidationFailureCopyWith<ValidationFailure> get copyWith => _$ValidationFailureCopyWithImpl<ValidationFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationFailure&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.fieldErrors, _fieldErrors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message,const DeepCollectionEquality().hash(_fieldErrors));
}

@override
String toString() {
    return 'AppFailure.validation(message: $message, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class $ValidationFailureCopyWith<$Res> implements $AppFailureCopyWith<$Res> {
  factory $ValidationFailureCopyWith(ValidationFailure value, $Res Function(ValidationFailure) _then) = _$ValidationFailureCopyWithImpl;
@override @useResult
$Res call({
 String message, Map<String, String> fieldErrors
});




}
/// @nodoc
class _$ValidationFailureCopyWithImpl<$Res>
    implements $ValidationFailureCopyWith<$Res> {
  _$ValidationFailureCopyWithImpl(this._self, this._then);

  final ValidationFailure _self;
  final $Res Function(ValidationFailure) _then;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? fieldErrors = null,}) {
  return _then(ValidationFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

/// @nodoc


class UnexpectedFailure implements AppFailure {
  const UnexpectedFailure({this.message = 'An unexpected error occurred. Please try again.', this.cause, this.stackTrace});
  

@override@JsonKey() final  String message;
 final  Object? cause;
 final  StackTrace? stackTrace;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnexpectedFailureCopyWith<UnexpectedFailure> get copyWith => _$UnexpectedFailureCopyWithImpl<UnexpectedFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UnexpectedFailure&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.cause, cause)&&(identical(other.stackTrace, stackTrace) || other.stackTrace == stackTrace));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message,const DeepCollectionEquality().hash(cause),stackTrace);
}

@override
String toString() {
    return 'AppFailure.unexpected(message: $message, cause: $cause, stackTrace: $stackTrace)';
}


}

/// @nodoc
abstract mixin class $UnexpectedFailureCopyWith<$Res> implements $AppFailureCopyWith<$Res> {
  factory $UnexpectedFailureCopyWith(UnexpectedFailure value, $Res Function(UnexpectedFailure) _then) = _$UnexpectedFailureCopyWithImpl;
@override @useResult
$Res call({
 String message, Object? cause, StackTrace? stackTrace
});




}
/// @nodoc
class _$UnexpectedFailureCopyWithImpl<$Res>
    implements $UnexpectedFailureCopyWith<$Res> {
  _$UnexpectedFailureCopyWithImpl(this._self, this._then);

  final UnexpectedFailure _self;
  final $Res Function(UnexpectedFailure) _then;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? cause = freezed,Object? stackTrace = freezed,}) {
  return _then(UnexpectedFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause ,stackTrace: freezed == stackTrace ? _self.stackTrace : stackTrace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}


}

// dart format on
