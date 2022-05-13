// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['settings_id', 'user_id', 'distance_unit'],
  );
  return UserSettings(
    json['user_id'] as String,
    $enumDecode(_$DistanceUnitEnumMap, json['distance_unit']),
    json['app_version'] as String? ?? '0',
  )..id = json['settings_id'] as String;
}

Map<String, dynamic> _$UserSettingsToJson(UserSettings instance) =>
    <String, dynamic>{
      'settings_id': instance.id,
      'user_id': instance.userId,
      'distance_unit': _$DistanceUnitEnumMap[instance.unit],
      'app_version': instance.appVersion,
    };

const _$DistanceUnitEnumMap = {
  DistanceUnit.mi: 'mi',
  DistanceUnit.km: 'km',
};
