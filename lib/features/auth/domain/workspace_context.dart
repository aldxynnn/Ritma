import 'package:freezed_annotation/freezed_annotation.dart';

import 'ritma_role.dart';

part 'workspace_context.freezed.dart';
part 'workspace_context.g.dart';

/// Represents a single active operational or member role context for the
/// signed-in user within an organization (and optional branch).
@freezed
abstract class WorkspaceContext with _$WorkspaceContext {
  const WorkspaceContext._();

  const factory WorkspaceContext({
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'organization_name') required String organizationName,
    @JsonKey(name: 'branch_id') String? branchId,
    @JsonKey(name: 'branch_name') String? branchName,
    @JsonKey(name: 'role_code') required String roleCode,
    @JsonKey(name: 'role_display_name') required String roleDisplayName,
    @JsonKey(name: 'role_rank') required int roleRank,
    @JsonKey(name: 'member_id') String? memberId,
    @Default(<String>[]) List<String> permissions,
  }) = _WorkspaceContext;

  factory WorkspaceContext.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceContextFromJson(json);

  RitmaRole get role => RitmaRole.fromCode(roleCode);

  bool get isOperationsSurface => role.isOperationsSurface;

  bool hasPermission(String permission) => permissions.contains(permission);

  String get scopeLabel => branchName ?? 'All Branches';

  String get contextKey => '$organizationId:${branchId ?? 'org'}:$roleCode';
}
