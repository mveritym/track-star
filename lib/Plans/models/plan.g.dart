// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Plan _$PlanFromJson(Map<String, dynamic> json) => Plan(
      json['name'] as String,
      $enumDecode(_$PlanTypeEnumMap, json['plan_type'], unknownValue: PlanType.baseTraining),
      json['is_race'] as bool,
      $enumDecodeNullable(_$RaceTypeEnumMap, json['race_type']),
      DateTime.parse(json['start_date'] as String),
      DateTime.parse(json['end_date'] as String),
    )
      ..planId = json['plan_id'] as String
      ..userId = json['user_id'] as String
      ..events = (json['events'] as List<dynamic>)
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$PlanToJson(Plan instance) => <String, dynamic>{
      'plan_id': instance.planId,
      'user_id': instance.userId,
      'name': instance.name,
      'plan_type': _$PlanTypeEnumMap[instance.planType],
      'race_type': _$RaceTypeEnumMap[instance.raceType],
      'is_race': instance.isRace,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'events': instance.events.map((e) => e.toJson()).toList(),
    };

const _$PlanTypeEnumMap = {
  PlanType.baseTraining: 'baseTraining',
  PlanType.race: 'race',
  PlanType.noPlan: 'noPlan',
};

const _$RaceTypeEnumMap = {
  RaceType.fiveK: 'fiveK',
  RaceType.tenK: 'tenK',
  RaceType.halfMarathon: 'halfMarathon',
  RaceType.marathon: 'marathon',
};
