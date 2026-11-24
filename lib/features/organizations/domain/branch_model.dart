import 'package:freezed_annotation/freezed_annotation.dart';

part 'branch_model.freezed.dart';
part 'branch_model.g.dart';

@freezed
abstract class BranchModel with _$BranchModel {
  const factory BranchModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    required String name,
    required String code,
    String? address,
    String? timezone,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _BranchModel;

  factory BranchModel.fromJson(Map<String, dynamic> json) =>
      _$BranchModelFromJson(json);
}
