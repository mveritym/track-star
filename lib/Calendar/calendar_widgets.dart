import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:track_star/Calendar/shared.dart';
import 'package:track_star/Events/event_widgets.dart';
import 'package:track_star/shared/date_utils.dart';
import 'package:track_star/shared/app_metrics.dart';
import 'calendar_provider.dart';

class CalendarWeek extends StatelessWidget {
  const CalendarWeek({Key? key, required this.weekIdx, required this.provider}) : super(key: key);

  final int weekIdx;
  final CalendarProvider provider;

  @override
  Widget build(BuildContext context) {

    var isSelectedWeek = provider.selectedWeekIndex == weekIdx;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [...provider.weeks[weekIdx].weekdays.map((weekday) => WeekdayCell(
            weekday: weekday,
            isSelected: weekday.date.isSameDay(provider.selectedDay.weekday.date),
            onTap: () => provider.selectDate(weekday.date),
            color: weekday.bodyColor,
          ))],
        ),
        isSelectedWeek ? const SizedBox(height: 8) : Container(),
        isSelectedWeek ? WeekdayDetailContainer(selectedDay: provider.selectedDay) : Container(),
      ],
    );
  }
}

class WeekdayCell extends StatelessWidget {
  const WeekdayCell({Key? key, required this.weekday, required this.isSelected,
    required this.onTap, required this.color}) : super(key: key);

  final Weekday weekday;
  final bool isSelected;
  final Function() onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isSelected ? AppMetrics.calendarCellPadding + 16 : AppMetrics.calendarCellPadding,
      child: GestureDetector(
        onTap: () => weekday.type != WeekdayType.none ? onTap() : (){},
        child: isSelected ?
          SelectedWeekdaySquare(weekday: weekday, color: color) :
          UnselectedWeekdaySquare(weekday: weekday, color: color),
      ),
    );
  }
}

class SelectedWeekdaySquare extends StatelessWidget {
  const SelectedWeekdaySquare({Key? key, required this.weekday, required this.color}) : super(key: key);

  final Weekday weekday;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox.square(
          dimension: AppMetrics.calendarCellWidth,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 3.0),
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              color: weekday.getFillColor(color).withOpacity(0.7),
            ),
            child: Text(
              weekday.getCellText(context),
              style: TextStyle(color: weekday.getTextColor(color), fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 4.0),
        SizedBox(
          width: AppMetrics.calendarCellWidth * 0.9,
          height: 3,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 3.0, color: Colors.blueGrey),
            ),
          )
        ),
      ],
    );
  }
}

class UnselectedWeekdaySquare extends StatelessWidget {
  const UnselectedWeekdaySquare({Key? key, required this.weekday, required this.color}) : super(key: key);

  final Weekday weekday;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox.square(
          dimension: AppMetrics.calendarCellWidth,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 3.0),
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              color: weekday.getFillColor(color).withOpacity(0.7),
            ),
            child: Text(
              weekday.getCellText(context),
              style: TextStyle(color: weekday.getTextColor(color), fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class WeekdayDetailContainer extends StatelessWidget {
  const WeekdayDetailContainer({Key? key, required this.selectedDay}) : super(key: key);

  final SelectedDay selectedDay;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat(DateFormat.MONTH_WEEKDAY_DAY).format(selectedDay.weekday.date),
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 8.0),
        Flexible(
          fit: FlexFit.loose,
          child: selectedDay.isEditing ?
            EditEvent(weekday: selectedDay.weekday) :
            WeekdayDetail(weekday: selectedDay.weekday),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}

class WeekdayDetail extends StatefulWidget {
  const WeekdayDetail({Key? key, required this.weekday}) : super(key: key);

  final Weekday weekday;

  @override
  State<WeekdayDetail> createState() => _WeekdayDetailState();
}

class _WeekdayDetailState extends State<WeekdayDetail> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {

    var _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    var _colorTween = ColorTween(begin: widget.weekday.bodyColor, end: Colors.amber).animate(_animationController);

    return AnimatedBuilder(
      animation: _colorTween,
      builder: (context, child) => Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: _colorTween.value?.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.weekday.statusIcon, color: _colorTween.value),
                        Text(
                          widget.weekday.statusText,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                    Text(
                      widget.weekday.getText(context),
                      style: Theme.of(context).textTheme.headline4?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox.square(
                  dimension: 40,
                  child: InkWell(
                    onTap: () {
                      CalendarProvider provider = context.read<CalendarProvider>();
                      provider.setEditingSelectedDay(true);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: _colorTween.value!),
                        color: _colorTween.value,
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 20)
                    ),
                  ),
                ),
              ]
            ),
            (widget.weekday.event?.notes != null && widget.weekday.event?.notes != '') ?
              Text(widget.weekday.event!.notes, style: Theme.of(context).textTheme.headline6) : Container(),
            (widget.weekday.isToday && widget.weekday.event != null) ?
              (!widget.weekday.event!.complete ?
                Column(
                  children: [
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _animationController.forward().then((_) {
                          widget.weekday.event!.setComplete(true);
                          widget.weekday.plan!.saveTrainingPlan();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: _colorTween.value,
                      ),
                      child: const Center(
                        child: Text('Complete', style: TextStyle(fontSize: 18, color: Colors.white))
                      ),
                    ),
                  ],
                ) : Container()
              ) : Container(),
            ],
        )
      ),
    );
  }
}
