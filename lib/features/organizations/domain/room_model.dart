import 'package:freezed_annotation/freezed_annotation.dart';

part 'room_model.freezed.dart';
part 'room_model.g.dart';

@freezed
abstract class RoomModel with _$RoomModel {
  const factory RoomModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'branch_id') required String branchId,
    required String name,
    @JsonKey(name: 'room_type') @Default('studio') String roomType,
    @JsonKey(name: 'default_capacity') required int defaultCapacity,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _RoomModel;

  factory RoomModel.fromJson(Map<String, dynamic> json) =>
      _$RoomModelFromJson(json);
}
