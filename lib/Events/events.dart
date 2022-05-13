import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:track_star/Events/event_widgets.dart';
import 'package:track_star/Plans/models/plan.dart';
import 'package:track_star/User/user_provider.dart';

part 'events.g.dart';

enum EventType {
  run,
  rest,
}

extension EventTypeExtension on EventType {
  String getDisplayName() {
    switch (this) {
      case EventType.run: return "Run";
      case EventType.rest: return "Rest";
    }
  }
}

enum DistanceUnit {
  mi,
  km,
}

extension DistanceUnitExtension on DistanceUnit {
  String getDisplayName() {
    switch(this) {
      case DistanceUnit.mi: return 'miles';
      case DistanceUnit.km: return 'kilometers';
    }
  }
}

const double kmToMi = 0.62;

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Event {
  @JsonKey(required: true)
  late DateTime date;

  @JsonKey(required: true)
  late double distance;

  @JsonKey(required: true)
  late String notes;

  @JsonKey(required: true, defaultValue: false)
  late bool complete = false;

  @JsonKey(ignore: true)
  Plan? plan;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);

  Event(this.date, this.distance, this.notes);

  Event.createAndAdd(BuildContext context, AddEventModel model) {
    distance = distanceTextToDouble(context, model.distanceText);
    date = model.date;
    notes = model.notes ?? '';
    complete = model.complete;
    plan = model.plan;
    plan!.addEvent(this);
  }

  double distanceTextToDouble(BuildContext context, String? distanceText) {
    var distance = double.parse(distanceText!);
    var unit = context.read<UserSettingsProvider>().settings?.unit ?? DistanceUnit.mi;
    return unit == DistanceUnit.km ? distance * kmToMi : distance;
  }

  String displayDistanceWithUnit(BuildContext context) {
    DistanceUnit unit = context.read<UserSettingsProvider>().settings?.unit ?? DistanceUnit.mi;
    var dist = unit == DistanceUnit.km ? distance / kmToMi : distance;
    dist = double.parse(dist.toStringAsFixed(2));
    return dist.toStringAsFixed(dist.truncateToDouble() == dist ? 0 : 1) + " " + unit.name;
  }

  String displayDistance(BuildContext context) {
    DistanceUnit unit = context.read<UserSettingsProvider>().settings?.unit ?? DistanceUnit.mi;
    var dist = unit == DistanceUnit.km ? distance / kmToMi : distance;
    dist = double.parse(dist.toStringAsFixed(1));
    return dist.toStringAsFixed(dist.truncateToDouble() == dist ? 0 : 1);
  }

  void update(BuildContext context, AddEventModel model) {
    date = model.date;
    distance = distanceTextToDouble(context, model.distanceText);
    notes = model.notes ?? '';
    complete = model.complete;
  }

  void delete() async {
    if (plan == null) { throw Error(); }
    plan!.deleteEvent(this);
  }

  void setComplete(bool complete) async {
    plan ??= await Plan.getPlanFor(date);
    int eventIdx = plan!.events.indexWhere((e) => isSameDay(e.date, date));
    if (eventIdx != -1) {
      Event existingEvent = plan!.events[eventIdx];
      existingEvent.complete = complete;
      plan!.replaceEvent(existingEvent, this);
    } else {
      this.complete = complete;
      plan!.addEvent(this);
    }
  }
}
