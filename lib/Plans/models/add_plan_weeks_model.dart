import 'package:flutter/material.dart';
import 'package:track_star/Calendar/shared.dart';
import 'package:track_star/Plans/models/plan.dart';
import 'package:track_star/shared/date_utils.dart';

class AddPlanError implements Exception {
  String cause;
  AddPlanError(this.cause);
}

class AddPlanWeeksModel extends ChangeNotifier {

  late Plan plan;
  late List<Week> weeks;
  late Weekday selectedDay;
  late int selectedWeekIndex;

  Week get currentWeek => weeks[selectedWeekIndex];

  bool get lastDaySelected {
    var selectableDays = currentWeek.weekdays.where((day) => day.type != WeekdayType.none).toList();
    selectableDays.sort((a, b) => a.date.compareTo(b.date));
    return selectedDay.date.isSameDay(selectableDays.last.date);
  }

  bool get lastWeekSelected => selectedWeekIndex == weeks.length - 1;

  AddPlanWeeksModel(List<WeekdaySelectorModel> runDays, this.plan) {
    var weekdays = _createWeekdays(plan, runDays);
    weeks = Week.weeksFromDays(weekdays);
    weeks.removeWhere((week) => week.weekdays.every((day) => day.type == WeekdayType.none));

    if (weeks.isEmpty) {
      throw(AddPlanError('Selected plan dates do not include selected days of the week to run'));
    }

    selectedWeekIndex = 0;
    selectedDay = weeks[0].weekdays.firstWhere((day) => day.type != WeekdayType.none);
  }

  AddPlanWeeksModel.fromExisting(AddPlanWeeksModel provider) {
    plan = provider.plan;
    selectedWeekIndex = provider.selectedWeekIndex + 1;
    weeks = provider.weeks;
    selectedDay = weeks[selectedWeekIndex].weekdays.firstWhere((day) => day.type != WeekdayType.none);
  }

  List<Weekday> _createWeekdays(Plan plan, List<WeekdaySelectorModel> runDays) {
    List<int> selectedRunDays = runDays
        .where((day) => day.isSelected)
        .map((day) => day.idx)
        .toList();

    var planStart = DateUtils.dateOnly(plan.startDate);
    var numDays = plan.endDate.difference(planStart).inDays + 1;

    return List.generate(numDays, (i) {
      var date = planStart.add(Duration(days: i));
      return selectedRunDays.contains(date.weekday - 1) ?
        Weekday(date, plan) :
        Weekday.noPlan(date);
    });
  }

  void selectDate(DateTime date) {
    List<Weekday> weekdays = weeks[selectedWeekIndex].weekdays;
    selectedDay = weekdays.firstWhere((weekday) => weekday.date.isSameDay(date));
    notifyListeners();
  }

  void selectNextDay() {
    List<Weekday> days = weeks[selectedWeekIndex].weekdays;
    days.sort((a, b) => a.date.compareTo(b.date));
    for (Weekday day in days) {
      if (day.date.isAfter(selectedDay.date) && !day.date.isSameDay(selectedDay.date) && day.plan != null) {
        selectedDay = day;
        notifyListeners();
        return;
      }
    }
  }

}