import 'package:freezed_annotation/freezed_annotation.dart';

part 'organization_model.freezed.dart';
part 'organization_model.g.dart';

@freezed
abstract class OrganizationModel with _$OrganizationModel {
  const factory OrganizationModel({
    required String id,
    required String name,
    required String slug,
    @JsonKey(name: 'business_type') @Default('hybrid') String businessType,
    @Default('UTC') String timezone,
    @JsonKey(name: 'currency_code') @Default('USD') String currencyCode,
    @Default('active') String status,
  }) = _OrganizationModel;

  factory OrganizationModel.fromJson(Map<String, dynamic> json) =>
      _$OrganizationModelFromJson(json);
}
