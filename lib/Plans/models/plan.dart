import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:track_star/Events/events.dart';
import 'package:track_star/Plans/models/add_plan_model.dart';
import 'package:uuid/uuid.dart';

import 'package:track_star/User/user_provider.dart';
import 'plan_type_model.dart';

part 'plan.g.dart';

enum RaceType {
  fiveK,
  tenK,
  halfMarathon,
  marathon,
}

extension PlanTypeExtension on RaceType {
  String getDisplayName() {
    switch (this) {
      case RaceType.fiveK: return "5K";
      case RaceType.tenK: return "10K";
      case RaceType.halfMarathon: return "Half marathon";
      case RaceType.marathon: return "Marathon";
    }
  }
}

enum PlanStatus {
  inProgress,
  upcoming,
  finished
}

extension PlanStatusExtension on PlanStatus {
  String getDisplayName() {
    switch (this) {
      case PlanStatus.finished: return 'Finished';
      case PlanStatus.upcoming: return 'Upcoming';
      case PlanStatus.inProgress: return 'In progress';
    }
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Plan {
  @JsonKey(required: true, name: 'plan_id')
  String _planId = const Uuid().v1();
  String get planId => _planId;
  set planId(val) {
    _planId = val;
  }

  @JsonKey(required: true, name: 'user_id')
  String _userId = FirebaseAuth.instance.currentUser!.uid;
  String get userId => _userId;
  set userId(val) {
    _userId = val;
  }

  @JsonKey(required: true, name: 'name')
  late String _name;
  String get name => _name;
  set name(val) {
    _name = val;
  }

  @JsonKey(required: true, name: 'plan_type', unknownEnumValue: PlanType.baseTraining)
  late PlanType _planType;
  PlanType get planType => _planType;
  set planType(val) {
    _planType = val;
  }

  @JsonKey(name: 'race_type')
  late RaceType? _raceType;
  RaceType? get raceType => _raceType;
  set raceType(val) {
    _raceType = val;
  }

  @JsonKey(required: true, name: 'is_race')
  late bool _isRace;
  bool get isRace => _isRace;
  set isRace(val) {
    _isRace = val;
  }

  @JsonKey(required: true, name: 'start_date')
  late DateTime _startDate;
  DateTime get startDate => _startDate;
  set startDate(val) {
    _startDate = val;
  }

  @JsonKey(required: true, name: 'end_date')
  late DateTime _endDate;
  DateTime get endDate => _endDate;
  set endDate(val) {
    _endDate = val;
  }

  @JsonKey(required: true, name: 'events')
  List<Event> _events = [];
  List<Event> get events => _events;
  set events(val) {
    _events = val;
  }

  Plan(String name, PlanType planType, bool isRace, RaceType? raceType, DateTime startDate, DateTime endDate) {
    _name = name;
    _planType = planType;
    _raceType = raceType;
    _isRace = isRace;
    _startDate = startDate;
    _endDate = endDate;
  }

  factory Plan.fromLaunchModel(AddPlanModel model) {
    return Plan(
      model.name,
      model.type,
      model.isRace,
      model.raceType,
      model.startDate!,
      model.endDate!,
    );
  }

  factory Plan.fromJson(Map<String, dynamic> json) {
    Plan plan = _$PlanFromJson(json);
    for (var event in plan.events) {
      event.plan = plan;
    }
    return plan;
  }

  Map<String, dynamic> toJson() => _$PlanToJson(this);

  get status {
    var today = DateTime.now();
    if (startDate.isAfter(today)) { return PlanStatus.upcoming; }
    if (endDate.isBefore(today)) { return PlanStatus.finished; }
    return PlanStatus.inProgress;
  }

  get numWeeks => ((endDate.difference(startDate).inDays + 1) / 7).ceil();

  Event? get finalEvent {
    if (events.isEmpty) { return null; }
    events.sort((a, b) => a.date.compareTo(b.date));
    return events.last;
  }

  int weekOf(DateTime date) => ((date.difference(startDate).inDays + 1) / 7).ceil();

  String totalDistanceText(BuildContext context, DateTime date) {
    var weekStart = DateTime(date.year, date.month, date.day - (date.weekday - 1));
    var weekEnd = weekStart.add(const Duration(days: 7));
    var unit = context.read<UserSettingsProvider>().settings?.unit ?? DistanceUnit.mi;

    if (events.isEmpty) { return '0 ' + unit.getDisplayName(); }

    var distance = events.map((event) {
      var startValid = event.date.isAfter(weekStart) || isSameDay(event.date, weekStart);
      var endValid = event.date.isBefore(weekEnd);
      return (startValid && endValid) ? event.distance : 0;
    }).reduce((value, element) => value + element);

    if (unit == DistanceUnit.km) {
      distance = distance / kmToMi;
    }

    distance = double.parse(distance.toStringAsFixed(1));
    return distance.toStringAsFixed(distance.truncateToDouble() == distance ? 0 : 1) + " " + unit.getDisplayName();
  }

  Future<Plan?> overlappingPlan() async {
    var plans = await _getAllPlans();
    var overlappingIdx = plans.indexWhere((plan) {
      var disjoint = (startDate.isAfter(plan.endDate)) || (endDate.isBefore(plan.startDate));
      return !disjoint && plan.planId != planId;
    });
    return overlappingIdx != -1 ? plans[overlappingIdx] : null;
  }

  void saveTrainingPlan() {
    FirebaseFirestore.instance
        .collection('plans')
        .doc(_planId)
        .set(toJson());
  }

  void replaceEvent(Event existingEvent, Event newEvent) {
    _events.remove(existingEvent);
    _events.add(newEvent);
  }

  Future<void> addEvent(Event event) async {
    _events.add(event);
  }

  Future<void> deleteEvent(Event event) async {
    _events.remove(event);
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance
        .collection('plans')
        .doc(_planId.toString())
        .delete();
  }

  static Future<Plan> getPlanFor(DateTime date) async {
    List<Plan> plans = await _getAllPlans();

    return plans.firstWhere((plan) =>
      (date.isAfter(plan.startDate) || isSameDay(date, plan.startDate)) &&
      (date.isBefore(plan.endDate) || isSameDay(date, plan.endDate)));
  }

  static Future<List<Plan>> _getAllPlans() async {
    var data = await FirebaseFirestore.instance
      .collection('plans')
      .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
      .get();

    return data.docs.map((doc) => Plan.fromJson(doc.data())).toList();
  }

  Future<void> savePlanUpdate() async {
    await FirebaseFirestore.instance
        .collection('plans')
        .doc(_planId.toString())
        .update(toJson());
  }
}
