// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  userId: json['user_id'] as String,
  fullName: json['full_name'] as String? ?? '',
  phone: json['phone'] as String?,
  avatarPath: json['avatar_path'] as String?,
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'avatar_path': instance.avatarPath,
    };
