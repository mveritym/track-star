import 'package:flutter/material.dart';

extension DateTimeExtension on DateTime {

  DateTime getWeekStart() {
    return DateTime(year, month, day - (weekday - 1));
  }

  DateTime getWeekEnd() {
    return DateTime(year, month, day + (7 - weekday));
  }

  bool inRange(DateTime start, DateTime end) {
    return ((isAfter(start) || isSameDay(start)) && (isBefore(end) || isSameDay(end)));
  }

  bool isSameDay(DateTime? b) {
    if (b == null) { return false; }
    return year == b.year && month == b.month && day == b.day;
  }

}

extension TSDateUtils on DateUtils {

  static List<DateTime> generateDatesBetween(DateTime start, DateTime end) {
    int numDays = end.difference(start).inDays + 1;
    return List.generate(numDays, (i) => start.add(Duration(days: i)));
  }

  static List<DateTime> generateWeekStartDatesBetween(DateTime start, DateTime end) {
    int numWeeks = (end.difference(start).inDays / 7).ceil();
    var weekStart = start.getWeekStart();
    return List.generate(numWeeks, (i) => weekStart.add(Duration(days: 7 * i)));
  }

  static DateTime getMinDate(List<DateTime> dates) {
    return dates.reduce((min, e) => e.isBefore(min) ? e : min);
  }

  static DateTime getMaxDate(List<DateTime> dates) {
    return dates.reduce((max, e) => e.isAfter(max) ? e : max);
  }

}