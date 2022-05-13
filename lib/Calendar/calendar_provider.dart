import 'package:flutter/material.dart';
import 'package:track_star/Calendar/shared.dart';
import 'package:track_star/shared/date_utils.dart';
import 'package:track_star/Plans/models/plan.dart';

class SelectedDay {
  Weekday weekday;
  bool isEditing;

  SelectedDay(this.weekday, this.isEditing);
}

class CalendarProvider extends ChangeNotifier {

  late List<Week> weeks;
  late SelectedDay selectedDay;

  int get selectedWeekIndex => weeks.indexWhere((week) => selectedDay.weekday.date.inRange(week.startDate, week.endDate));

  CalendarProvider() {
    List<DateTime> defaultWeekStartDates = _generateDefaultWeekStartDates();
    weeks = _generateDefaultWeeks(defaultWeekStartDates);
    selectedDay = SelectedDay(Weekday.noPlan(DateTime.now()), false);
  }

  void updatePlans(List<Plan> plans) {
    if (plans.isEmpty) {
      List<DateTime> defaultWeekStartDates = _generateDefaultWeekStartDates();
      weeks = _generateDefaultWeeks(defaultWeekStartDates);
      selectedDay = SelectedDay(Weekday.noPlan(DateTime.now()), false);
      notifyListeners();
      return;
    }

    List<Weekday> weekdays = Week.generateDaysFromProvided(_toWeekdays(plans));
    weeks = Week.weeksFromDays(weekdays);
    selectedDay = updateSelectedDay(plans);
    notifyListeners();
  }

  SelectedDay updateSelectedDay(List<Plan> plans) {
    plans.sort((a, b) => a.startDate.compareTo(b.startDate));

    DateTime minDate = plans.first.startDate;
    DateTime maxDate = plans.last.endDate;
    DateTime selectedDate = selectedDay.weekday.date;

    if (selectedDate.isBefore(minDate) || selectedDate.isAfter(maxDate)) {
      return SelectedDay(Weekday(minDate, plans.first), selectedDay.isEditing);
    } else {
      var newWeekday = Weekday(selectedDate, plans.firstWhere((plan) {
        return selectedDate.inRange(plan.startDate, plan.endDate);
      }));
      return SelectedDay(newWeekday, false);
    }
  }

  void setEditingSelectedDay(bool isEditing) {
    selectedDay.isEditing = isEditing;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    List<Weekday> allWeekdays = weeks.expand((week) => week.weekdays).toList();
    Weekday weekday = allWeekdays.firstWhere((weekday) => weekday.date.isSameDay(date));
    selectedDay = SelectedDay(weekday, false);
    notifyListeners();
  }

  List<DateTime> _generateDefaultWeekStartDates() {
    DateTime today = DateUtils.dateOnly(DateTime.now());
    DateTime threeMonthsAgo = today.subtract(const Duration(days: 7 * 4 * 3));
    DateTime threeMonthsFromNow = today.add(const Duration(days: 7 * 4 * 3));
    List<DateTime> weekStartDates = TSDateUtils.generateWeekStartDatesBetween(threeMonthsAgo, threeMonthsFromNow);
    return weekStartDates;
  }

  List<Week> _generateDefaultWeeks(List<DateTime> weekStartDates) {
    return weekStartDates.map((startDate) => Week.empty(startDate)).toList();
  }

  List<Weekday> _toWeekdays(List<Plan> plans) {
    return plans.expand((plan) {
      var planStart = DateUtils.dateOnly(plan.startDate);
      var numDays = plan.endDate.difference(planStart).inDays + 1;
      return List.generate(numDays, (i) {
        return Weekday(planStart.add(Duration(days: i)), plan);
      });
    }).toList();
  }
}