import 'package:freezed_annotation/freezed_annotation.dart';

part 'tenant_context.freezed.dart';
part 'tenant_context.g.dart';

/// Immutable multi-tenant operational context identifying the active
/// organization and optional branch scope for a session.
@freezed
abstract class TenantContext with _$TenantContext {
  const factory TenantContext({
    required String organizationId,
    String? branchId,
  }) = _TenantContext;

  factory TenantContext.fromJson(Map<String, dynamic> json) =>
      _$TenantContextFromJson(json);
}
