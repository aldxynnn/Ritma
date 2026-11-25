import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff_management_models.freezed.dart';
part 'staff_management_models.g.dart';

@freezed
abstract class StaffAssignmentModel with _$StaffAssignmentModel {
  const factory StaffAssignmentModel({
    @JsonKey(name: 'assignment_id') required String assignmentId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'full_name') @Default('') String fullName,
    @Default('') String email,
    @JsonKey(name: 'role_code') required String roleCode,
    @JsonKey(name: 'role_display_name') @Default('') String roleDisplayName,
    @JsonKey(name: 'role_rank') @Default(0) int roleRank,
    @JsonKey(name: 'branch_id') String? branchId,
    @JsonKey(name: 'branch_name') String? branchName,
    @Default('active') String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'revoked_at') DateTime? revokedAt,
  }) = _StaffAssignmentModel;

  factory StaffAssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$StaffAssignmentModelFromJson(json);
}

@freezed
abstract class OrganizationInvitationModel with _$OrganizationInvitationModel {
  const factory OrganizationInvitationModel({
    required String id,
    @JsonKey(name: 'invited_email') required String invitedEmail,
    @JsonKey(name: 'role_code') required String roleCode,
    @JsonKey(name: 'role_display_name') @Default('') String roleDisplayName,
    @JsonKey(name: 'role_rank') @Default(0) int roleRank,
    @JsonKey(name: 'branch_id') String? branchId,
    @JsonKey(name: 'branch_name') String? branchName,
    @Default('pending') String status,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _OrganizationInvitationModel;

  factory OrganizationInvitationModel.fromJson(Map<String, dynamic> json) =>
      _$OrganizationInvitationModelFromJson(json);
}
