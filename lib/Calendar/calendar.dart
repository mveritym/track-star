import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:track_star/Calendar/calendar_provider.dart';
import 'package:track_star/Calendar/calendar_widgets.dart';
import 'package:track_star/Calendar/shared.dart';
import 'package:track_star/Plans/plans_provider.dart';
import 'package:track_star/User/user_provider.dart';
import 'package:track_star/shared/scaffolds.dart';
import 'package:track_star/shared/app_metrics.dart';
import 'package:track_star/shared/date_utils.dart';

class Calendar extends StatelessWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'Calendar');

    return TabViewScaffold(
      title: '',
      body: Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary),
        padding: EdgeInsets.only(top: AppMetrics.paddingTop),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => UserSettingsProvider(),
            ),
            ChangeNotifierProvider(
              create: (context) => PlansProvider(),
            ),
            ChangeNotifierProxyProvider<PlansProvider, CalendarProvider>(
              create: (context) => CalendarProvider(),
              update: (context, plansProvider, calendarProvider) =>
                calendarProvider!..updatePlans(plansProvider.plans),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CalendarHeader(),
              Flexible(
                child: Stack(
                  children: const [
                    CalendarWeekList(),
                    CalendarWeekNameLabels(),
                  ]
                ),
              ),
            ]
          )
        ),
      ),
    );
  }
}

class CalendarHeader extends StatelessWidget {
  CalendarHeader({Key? key}) : super(key: key);

  final formatter = DateFormat('MMMM d');

  @override
  Widget build(BuildContext context) {
    return Selector<CalendarProvider, SelectedDay>(
      selector: (_, provider) => provider.selectedDay,
      builder: (context, selectedDay, child) {

        Weekday weekday = selectedDay.weekday;

        String planName = weekday.plan?.name ?? 'No plan';
        String planMiles = weekday.plan?.totalDistanceText(context, selectedDay.weekday.date) ?? '';

        String weekStart = formatter.format(weekday.date.getWeekStart());
        String weekEnd = formatter.format(weekday.date.getWeekEnd());

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(planName, style: Theme.of(context).textTheme.headline5?.copyWith(fontWeight: FontWeight.bold)),
              Text(weekStart + " – " + weekEnd, style: Theme.of(context).textTheme.headline6),
              const SizedBox(height: 8),
              Text(planMiles, style: Theme.of(context).textTheme.headline6),
            ],
          ),
        );
      }
    );
  }
}

class CalendarWeekList extends StatefulWidget {
  const CalendarWeekList({Key? key}) : super(key: key);

  @override
  State<CalendarWeekList> createState() => _CalendarWeekListState();
}

class _CalendarWeekListState extends State<CalendarWeekList> {

  final GlobalKey _weekListKey = GlobalKey();
  final GlobalKey _selectedWeekKey = GlobalKey();
  double widgetHeight = 32.0;
  double selectedWeekHeight = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => getSizeAndPosition());
  }

  getSizeAndPosition() {
    RenderBox box = _weekListKey.currentContext?.findRenderObject() as RenderBox;
    RenderBox box2 = _selectedWeekKey.currentContext?.findRenderObject() as RenderBox;
    widgetHeight = box.hasSize ? box.size.height : 0;
    selectedWeekHeight = box2.hasSize ? box2.size.height : 0;
    setState(() {});
  }

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSettingsProvider>(
      builder: (context, settingsProvider, _) => Consumer<CalendarProvider>(
        builder: (context, provider, child) {

          List<Week> weeks = provider.weeks;
          int selectedWeekIdx = provider.selectedWeekIndex;

          var weekHeight = (selectedWeekIdx * AppMetrics.calendarCellPadding) + 10;

          if (scrollController.hasClients) {
            scrollController.animateTo(
              weekHeight,
              duration: const Duration(milliseconds: 600),
              curve: Curves.decelerate
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            key: _weekListKey,
            child: ListView.builder(
              shrinkWrap: true,
              controller: scrollController,
              itemCount: weeks.length + 1,
              itemBuilder: (context, idx) {

                if (idx == weeks.length) {
                  return SizedBox(height: widgetHeight - selectedWeekHeight - 32);
                }

                return CalendarWeek(
                  key: idx == selectedWeekIdx ? _selectedWeekKey : null,
                  weekIdx: idx,
                  provider: provider,
                );
              },
            ),
          );
        }
      ),
    );
  }
}


class CalendarWeekNameLabels extends StatelessWidget {
  const CalendarWeekNameLabels({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(
            color: Colors.black12.withOpacity(0.1),
            offset: const Offset(0,10),
            blurRadius: 10,
            spreadRadius: 1
          )],
          color: Theme.of(context).colorScheme.secondary,
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: WeekNameLabels(),
        ),
      ),
    );
  }
}

class WeekNameLabels extends StatelessWidget {
  const WeekNameLabels({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var now = DateTime.now();
    List<DateTime> days = TSDateUtils.generateDatesBetween(now.getWeekStart(), now.getWeekEnd());

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) => SizedBox(
          width: AppMetrics.calendarCellWidth,
          child: Center(
              child: Text(
                DateFormat(DateFormat.ABBR_WEEKDAY).format(day)[0],
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
          )
      )).toList(),
    );
  }
}
