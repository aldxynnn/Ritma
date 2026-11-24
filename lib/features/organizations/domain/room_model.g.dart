// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RoomModel _$RoomModelFromJson(Map<String, dynamic> json) => _RoomModel(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  branchId: json['branch_id'] as String,
  name: json['name'] as String,
  roomType: json['room_type'] as String? ?? 'studio',
  defaultCapacity: (json['default_capacity'] as num).toInt(),
  isActive: json['is_active'] as bool? ?? true,
);

Map<String, dynamic> _$RoomModelToJson(_RoomModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'branch_id': instance.branchId,
      'name': instance.name,
      'room_type': instance.roomType,
      'default_capacity': instance.defaultCapacity,
      'is_active': instance.isActive,
    };
