import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'full_name') @Default('') String fullName,
    String? phone,
    @JsonKey(name: 'avatar_path') String? avatarPath,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
