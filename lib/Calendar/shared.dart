import 'package:flutter/material.dart';
import 'package:track_star/Plans/models/plan.dart';
import 'package:track_star/Events/events.dart';
import 'package:track_star/shared/date_utils.dart';

class Week {
  List<Weekday> weekdays = [];

  DateTime get startDate => weekdays.first.date;
  DateTime get endDate => weekdays.last.date;

  Week(this.weekdays) {
    weekdays.sort((a, b) => a.date.compareTo(b.date));
  }

  Week.empty(DateTime startDate) {
    var list = [for (var i = 0; i < 7; i++) i];
    weekdays = list.map((idx) => Weekday.noPlan(startDate.add(Duration(days: idx)))).toList();
  }

  static List<Week> weeksFromDays(List<Weekday> weekdays) {
    weekdays.sort((a, b) => a.date.compareTo(b.date));

    DateTime start = weekdays.first.date.getWeekStart();
    DateTime end = weekdays.last.date.getWeekEnd();
    int numWeeks = ((end.difference(start).inDays) / 7).ceil();

    var initialDate = weekdays[0].date.getWeekStart();
    return List.generate(numWeeks, (i) {
      var startDate = initialDate.add(Duration(days: 7 * i));

      return Week(List.generate(7, (i) {
        DateTime date = startDate.add(Duration(days: i));
        int existingWeekdayIdx = weekdays.indexWhere((day) => day.date.isSameDay(date));
        return existingWeekdayIdx != -1 ? weekdays[existingWeekdayIdx] : Weekday.noPlan(date);
      }));
    });
  }

  static List<Weekday> generateDaysFromProvided(List<Weekday> providedDays) {
    providedDays.sort((a, b) => a.date.compareTo(b.date));
    DateTime startDate = providedDays.first.date.getWeekStart();

    DateTime endDate = providedDays.last.date.getWeekEnd();
    int numDays = endDate.difference(startDate).inDays + 1;

    return List.generate(numDays, (i) {
      DateTime date = startDate.add(Duration(days: i));
      int existingWeekdayIdx = providedDays.indexWhere((day) => day.date.isSameDay(date));
      return existingWeekdayIdx != -1 ? providedDays[existingWeekdayIdx] : Weekday.noPlan(date);
    });
  }
}


enum WeekdayType {
  run,
  rest,
  none,
}

class Weekday {
  final DateTime today = DateTime.now();
  DateTime date;
  Plan? plan;

  Weekday(this.date, this.plan);

  Weekday.noPlan(this.date);

  Event? get event {
    if (plan == null) { return null; }
    int eventIdx = plan!.events.indexWhere((event) => DateUtils.isSameDay(event.date, date));
    return eventIdx != -1 ? plan!.events[eventIdx] : null;
  }

  WeekdayType get type {
    if (plan == null) { return WeekdayType.none; }
    return event == null ? WeekdayType.rest : WeekdayType.run;
  }

  bool get isFinalEvent {
    if (plan == null) { return false; }
    if (event == null) { return false; }
    if (plan!.finalEvent == null) { return false; }
    return event! == plan!.finalEvent!;
  }

  get hasPassed => DateUtils.dateOnly(date).isBefore(DateUtils.dateOnly(today));
  get isToday => DateUtils.dateOnly(date).isSameDay(DateUtils.dateOnly(today));

  String getText(BuildContext context) {
    return event != null ? event!.displayDistanceWithUnit(context) : 'Rest';
  }

  String getCellText(BuildContext context) {
    return event != null ? event!.displayDistance(context) : '';
  }

  get statusText {

    if (isFinalEvent) {
      return event!.plan!.isRace ? 'Race day!' : 'Final run!';
    }

    if (event != null && event!.complete) { return 'Complete'; }
    if (isToday) { return 'Today'; }
    if (!hasPassed) { return 'Upcoming'; }

    return 'Missed';
  }

  get statusIcon {

    if (isFinalEvent) {
      return event!.plan!.isRace ? Icons.emoji_events : Icons.celebration;
    }

    if (event != null) {
      if (event!.complete) { return Icons.check; }
      if (isToday) { return Icons.arrow_downward; }
      if (!hasPassed) { return Icons.arrow_forward; }
      return Icons.close;
    } else {
      return Icons.self_improvement;
    }

  }

  get bodyColor {
    if (type == WeekdayType.none) { return Colors.grey; }

    if (event != null) {
      if (isFinalEvent) { return Colors.deepPurple; }
      if (event!.complete) { return Colors.amber; }
      return hasPassed ? Colors.red[300] : Colors.green;
    } else {
      return Colors.blueAccent;
    }
  }

  Color getFillColor(Color color) => hasPassed ? color :
  ((isToday && event != null && event!.complete) ? color : Colors.white);

  Color getTextColor(Color color) {
    if (type == WeekdayType.none) { return Colors.grey; }
    return (hasPassed || (event?.complete ?? false)) ? Colors.white : color;
  }
}

class WeekdaySelectorModel {
  int idx;
  bool isSelected = false;

  WeekdaySelectorModel(this.idx);

  String get name {
    switch(idx) {
      case 0: return 'M';
      case 1: return 'T';
      case 2: return 'W';
      case 3: return 'T';
      case 4: return 'F';
      case 5: return 'S';
      case 6: return 'S';
    }
    return '';
  }

  void toggleSelected() {
    isSelected = !isSelected;
  }
}
