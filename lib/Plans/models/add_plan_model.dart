import 'package:flutter/material.dart';
import 'package:track_star/Plans/models/plan_type_model.dart';
import '../../Calendar/shared.dart';
import '../../Events/events.dart';
import 'plan.dart';

class AddPlanModel extends ChangeNotifier {
  PlanType type;
  String name;
  bool isRace;
  DateTime? startDate;
  DateTime? endDate;
  RaceType? raceType;
  List<WeekdaySelectorModel> runDays = List.generate(7, (idx) => WeekdaySelectorModel(idx));
  DistanceUnit unit = DistanceUnit.mi;

  AddPlanModel(this.type, this.name, this.isRace);

  factory AddPlanModel.from(AddPlanModel model) {
    var newModel = AddPlanModel(model.type, model.name, model.isRace);
    newModel.startDate = model.startDate;
    newModel.endDate = model.endDate;
    newModel.raceType = model.raceType;
    newModel.runDays = model.runDays;
    newModel.unit = model.unit;
    return newModel;
  }

  int? getNumWeeks() {
    if (endDate == null || startDate == null) { return null; }
    return ((endDate!.difference(startDate!).inDays) / 7).ceil();
  }

  void updateType(PlanType type) {
    this.type = type;
    notifyListeners();
  }

  void updateName(String name) {
    this.name = name;
    notifyListeners();
  }

  void updateStartDate(DateTime date) {
    startDate = date;
    notifyListeners();
  }

  void updateEndDate(DateTime date) {
    endDate = date;
    notifyListeners();
  }

  void updateNumWeeks(int numWeeks) {
    endDate = startDate?.add(Duration(days: (7 * numWeeks)));
    notifyListeners();
  }

  void updateRaceType(RaceType raceType) {
    this.raceType = raceType;
    notifyListeners();
  }

  void toggleRunDay(WeekdaySelectorModel day) {
    day.isSelected = !day.isSelected;
    notifyListeners();
  }

  void updateUnit(DistanceUnit unit) {
    this.unit = unit;
    notifyListeners();
  }
}
