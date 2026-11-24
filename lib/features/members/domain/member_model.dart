import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_model.freezed.dart';
part 'member_model.g.dart';

enum MemberStatus {
  active,
  frozen,
  suspended,
  archived;

  String get displayLabel => switch (this) {
    MemberStatus.active => 'Active',
    MemberStatus.frozen => 'Frozen',
    MemberStatus.suspended => 'Suspended',
    MemberStatus.archived => 'Archived',
  };
}

@freezed
abstract class MemberModel with _$MemberModel {
  const factory MemberModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'home_branch_id') required String homeBranchId,
    @JsonKey(name: 'member_code') required String memberCode,
    @JsonKey(name: 'full_name') required String fullName,
    String? email,
    String? phone,
    @JsonKey(name: 'emergency_contact_name') String? emergencyContactName,
    @JsonKey(name: 'emergency_contact_phone') String? emergencyContactPhone,
    @Default(MemberStatus.active) MemberStatus status,
  }) = _MemberModel;

  factory MemberModel.fromJson(Map<String, dynamic> json) =>
      _$MemberModelFromJson(json);
}
