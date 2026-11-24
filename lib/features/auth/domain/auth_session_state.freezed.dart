// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthSessionState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSessionState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthSessionState()';
}


}

/// @nodoc
class $AuthSessionStateCopyWith<$Res>  {
$AuthSessionStateCopyWith(AuthSessionState _, $Res Function(AuthSessionState) __);
}


/// Adds pattern-matching-related methods to [AuthSessionState].
extension AuthSessionStatePatterns on AuthSessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( UnauthenticatedSession value)?  unauthenticated,TResult Function( AuthenticatedSession value)?  authenticated,required TResult orElse(),}){
final _that = this;
switch (_that) {
case UnauthenticatedSession() when unauthenticated != null:
return unauthenticated(_that);case AuthenticatedSession() when authenticated != null:
return authenticated(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( UnauthenticatedSession value)  unauthenticated,required TResult Function( AuthenticatedSession value)  authenticated,}){
final _that = this;
switch (_that) {
case UnauthenticatedSession():
return unauthenticated(_that);case AuthenticatedSession():
return authenticated(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( UnauthenticatedSession value)?  unauthenticated,TResult? Function( AuthenticatedSession value)?  authenticated,}){
final _that = this;
switch (_that) {
case UnauthenticatedSession() when unauthenticated != null:
return unauthenticated(_that);case AuthenticatedSession() when authenticated != null:
return authenticated(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  unauthenticated,TResult Function( AuthUser user,  UserProfile profile,  List<WorkspaceContext> workspaces)?  authenticated,required TResult orElse(),}) {final _that = this;
switch (_that) {
case UnauthenticatedSession() when unauthenticated != null:
return unauthenticated();case AuthenticatedSession() when authenticated != null:
return authenticated(_that.user,_that.profile,_that.workspaces);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  unauthenticated,required TResult Function( AuthUser user,  UserProfile profile,  List<WorkspaceContext> workspaces)  authenticated,}) {final _that = this;
switch (_that) {
case UnauthenticatedSession():
return unauthenticated();case AuthenticatedSession():
return authenticated(_that.user,_that.profile,_that.workspaces);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  unauthenticated,TResult? Function( AuthUser user,  UserProfile profile,  List<WorkspaceContext> workspaces)?  authenticated,}) {final _that = this;
switch (_that) {
case UnauthenticatedSession() when unauthenticated != null:
return unauthenticated();case AuthenticatedSession() when authenticated != null:
return authenticated(_that.user,_that.profile,_that.workspaces);case _:
  return null;

}
}

}

/// @nodoc


class UnauthenticatedSession implements AuthSessionState {
  const UnauthenticatedSession();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UnauthenticatedSession);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthSessionState.unauthenticated()';
}


}




/// @nodoc


class AuthenticatedSession implements AuthSessionState {
  const AuthenticatedSession({required this.user, required this.profile, required  List<WorkspaceContext> workspaces}): _workspaces = workspaces;
  

 final  AuthUser user;
 final  UserProfile profile;
 final  List<WorkspaceContext> _workspaces;
 List<WorkspaceContext> get workspaces {
  if (_workspaces is EqualUnmodifiableListView) return _workspaces;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workspaces);
}


/// Create a copy of AuthSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthenticatedSessionCopyWith<AuthenticatedSession> get copyWith => _$AuthenticatedSessionCopyWithImpl<AuthenticatedSession>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthenticatedSession&&(identical(other.user, user) || other.user == user)&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other.workspaces, _workspaces));
}


@override
int get hashCode {
    return Object.hash(runtimeType,user,profile,const DeepCollectionEquality().hash(_workspaces));
}

@override
String toString() {
    return 'AuthSessionState.authenticated(user: $user, profile: $profile, workspaces: $workspaces)';
}


}

/// @nodoc
abstract mixin class $AuthenticatedSessionCopyWith<$Res> implements $AuthSessionStateCopyWith<$Res> {
  factory $AuthenticatedSessionCopyWith(AuthenticatedSession value, $Res Function(AuthenticatedSession) _then) = _$AuthenticatedSessionCopyWithImpl;
@useResult
$Res call({
 AuthUser user, UserProfile profile, List<WorkspaceContext> workspaces
});


$AuthUserCopyWith<$Res> get user;$UserProfileCopyWith<$Res> get profile;

}
/// @nodoc
class _$AuthenticatedSessionCopyWithImpl<$Res>
    implements $AuthenticatedSessionCopyWith<$Res> {
  _$AuthenticatedSessionCopyWithImpl(this._self, this._then);

  final AuthenticatedSession _self;
  final $Res Function(AuthenticatedSession) _then;

/// Create a copy of AuthSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? user = null,Object? profile = null,Object? workspaces = null,}) {
  return _then(AuthenticatedSession(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AuthUser,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserProfile,workspaces: null == workspaces ? _self._workspaces : workspaces // ignore: cast_nullable_to_non_nullable
as List<WorkspaceContext>,
  ));
}

/// Create a copy of AuthSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthUserCopyWith<$Res> get user {
  
  return $AuthUserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of AuthSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res> get profile {
  
  return $UserProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}

// dart format on
