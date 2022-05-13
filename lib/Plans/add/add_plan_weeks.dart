import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:track_star/shared/date_utils.dart';
import '../../Calendar/calendar.dart';
import '../../Calendar/calendar_widgets.dart';
import '../../Calendar/shared.dart';
import '../../Events/event_widgets.dart';
import '../../Events/events.dart';
import 'package:track_star/User/user_provider.dart';
import '../../app.dart';
import '../models/add_plan_weeks_model.dart';

class AddPlanWeeks extends StatelessWidget {
  const AddPlanWeeks({Key? key, required this.provider}) : super(key: key);

  final AddPlanWeeksModel provider;

  @override
  Widget build(BuildContext context) {

    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'AddPlanWeeks');

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(251, 244, 244, 1),
        resizeToAvoidBottomInset: false,
        body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 64, 16, 0),
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (context) => UserSettingsProvider(),
                ),
                ChangeNotifierProvider<AddPlanWeeksModel>.value(value: provider),
              ],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter your plan details',
                    style: Theme.of(context).textTheme.headline4
                  ),
                  const AddPlanEventsHeader(),
                  const SizedBox(height: 8),
                  const WeekNameLabels(),
                  const AddPlanWeek(),
                ],
              ),
            )
        ),
      ),
    );
  }
}

class AddPlanEventsHeader extends StatelessWidget {
  const AddPlanEventsHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AddPlanWeeksModel>(
      builder: (context, model, _) => Padding(
        padding: const EdgeInsets.only(top: 32),
        child: SizedBox(
          height: 50,
          child: Text(
            "Week " + (model.selectedWeekIndex + 1).toString() + " of " + model.weeks.length.toString(),
            style: Theme
                .of(context)
                .textTheme
                .headline5
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class AddPlanWeek extends StatelessWidget {
  const AddPlanWeek({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Consumer<AddPlanWeeksModel>(
            builder: (context, provider, _) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [...provider.currentWeek.weekdays.map((weekday) => WeekdayCell(
                weekday: weekday,
                isSelected: provider.selectedDay.date.isSameDay(weekday.date),
                onTap: () => provider.selectDate(weekday.date),
                color: weekday.type == WeekdayType.none ? Colors.grey : Colors.green,
              ))],
            )
        ),
        const SizedBox(height: 8),
        const AddPlanWeekdayContainer(),
      ],
    );
  }
}

class AddPlanWeekdayContainer extends StatelessWidget {
  const AddPlanWeekdayContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AddPlanWeeksModel>(
      builder: (context, provider, _) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat(DateFormat.MONTH_WEEKDAY_DAY).format(provider.selectedDay.date),
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(height: 8.0),
          Flexible(
            fit: FlexFit.loose,
            child: AddEventForm(weekday: provider.selectedDay, provider: provider),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}

class AddEventForm extends StatelessWidget {
  AddEventForm({Key? key, required this.weekday, required this.provider}) : super(key: key);

  final Weekday weekday;
  final AddPlanWeeksModel provider;

  final _formKey = GlobalKey<FormState>(debugLabel: '_AddEventState');

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ChangeNotifierProvider<AddEventModel>(
        create: (context) => AddEventModel.newModel(context, weekday),
        child: Selector<AddEventModel, Color>(
          selector: (context, model) => model.color,
          builder: (context, color, child) {
            return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 32),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: child,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DistanceInputField(autoFocus: true),
              const SizedBox(height: 16),
              AddEventFormSubmitButton(formKey: _formKey, addPlanWeeksModel: provider),
            ],
          ),
        ),
      ),
    );
  }
}

class AddEventFormSubmitButton extends StatelessWidget {
  const AddEventFormSubmitButton({Key? key, required this.formKey, required this.addPlanWeeksModel}) : super(key: key);

  final GlobalKey<FormState> formKey;
  final AddPlanWeeksModel addPlanWeeksModel;

  @override
  Widget build(BuildContext context) {
    return Consumer<AddEventModel>(
      builder: (context, model, _) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
        ),
        child: Text(addPlanWeeksModel.lastWeekSelected && addPlanWeeksModel.lastDaySelected ? 'Finish' : 'Next'),
        onPressed: () {

          if (!formKey.currentState!.validate()) { return; }

          Event? existingEvent = model.existingEvent;

          if (model.type == EventType.rest) {
            existingEvent?.delete();
          } else {
            if (existingEvent != null) {
              existingEvent.update(context, model);
            } else {
              Event.createAndAdd(context, model);
            }
          }

          if (addPlanWeeksModel.lastDaySelected) {
            if (addPlanWeeksModel.lastWeekSelected) {
              addPlanWeeksModel.plan.saveTrainingPlan();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const App()));
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  var newProvider = AddPlanWeeksModel.fromExisting(addPlanWeeksModel);
                  return AddPlanWeeks(provider: newProvider);
                }),
              );
            }
          } else {
            addPlanWeeksModel.selectNextDay();
          }
        },
      ),
    );
  }
}
