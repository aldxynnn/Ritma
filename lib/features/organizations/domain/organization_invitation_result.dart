import 'package:freezed_annotation/freezed_annotation.dart';

part 'organization_invitation_result.freezed.dart';

@freezed
abstract class OrganizationInvitationResult
    with _$OrganizationInvitationResult {
  const factory OrganizationInvitationResult({
    required String invitationId,
    required String token,
    required String invitedEmail,
    required String roleCode,
    String? branchId,
  }) = _OrganizationInvitationResult;
}
