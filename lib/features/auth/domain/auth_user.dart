import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';

/// Minimal authenticated identity independent of any Supabase SDK class.
@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String email,
    String? fullName,
  }) = _AuthUser;
}
