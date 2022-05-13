// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['date', 'distance', 'notes', 'complete'],
  );
  return Event(
    DateTime.parse(json['date'] as String),
    (json['distance'] as num).toDouble(),
    json['notes'] as String,
  )..complete = json['complete'] as bool? ?? false;
}

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'distance': instance.distance,
      'notes': instance.notes,
      'complete': instance.complete,
    };
