import 'dart:ui';

class AppMetrics {
  static Size size = window.physicalSize / window.devicePixelRatio;
  static double paddingLeft = window.padding.left / window.devicePixelRatio;
  static double paddingTop = window.padding.top / window.devicePixelRatio;
  static double paddingRight = window.padding.right / window.devicePixelRatio;
  static double paddingBottom = window.padding.bottom / window.devicePixelRatio;

  static double calendarCellWidthWithPadding(int padding) => (size.width - padding - (6 * 4)) / 7;
  static double calendarCellWidth = (size.width - 32 - (6 * 4)) / 7;
  static double calendarCellPadding = (size.width - 16 - calendarCellWidth) / 6;
}