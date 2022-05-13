import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:track_star/Plans/models/plan.dart';
import 'package:track_star/Plans/plan_widgets.dart';
import 'package:track_star/shared/date_utils.dart';

class EditPlanViewModel extends ChangeNotifier {
  Plan plan;

  EditPlanViewModel(this.plan);

  void updateName(String name) {
    plan.name = name;
    notifyListeners();
  }

  void updateType(RaceType type) {
    plan.raceType = type;
    notifyListeners();
  }

  void updateIsRace(bool? isRace) {
    plan.isRace = isRace ?? false;
    notifyListeners();
  }

  void updateStartDate(DateTime startDate) {
    plan.startDate = startDate;
    notifyListeners();
  }

  void updateEndDate(DateTime endDate) {
    plan.endDate = endDate;
    notifyListeners();
  }
}

class EditPlan extends StatelessWidget {
  EditPlan({Key? key, required this.initialPlan}) : super(key: key);

  final Plan initialPlan;
  final _formKey = GlobalKey<FormState>(debugLabel: '_EditPlanState');

  @override
  Widget build(BuildContext context) {

    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'EditPlan');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Edit plan')),
      body: ChangeNotifierProvider(
        create: (context) => EditPlanViewModel(initialPlan),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Consumer<EditPlanViewModel>(
              builder: (context, model, _) => Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlanNameInput(name: model.plan.name, update: model.updateName),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(flex: 7, child: PlanTypeInput(type: model.plan.raceType, update: model.updateType)),
                            Flexible(flex: 3, child: PlanIsRaceInput(isRace: model.plan.isRace, update: model.updateIsRace)),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 1,
                            child: StartDateInput(
                              startDate: model.plan.startDate,
                              endDate: model.plan.endDate,
                              update: model.updateStartDate
                            )
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            flex: 1,
                            child: EndDateInput(
                              startDate: model.plan.startDate,
                              endDate: model.plan.endDate,
                              update: model.updateEndDate
                            )
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      PlanEditButton(formKey: _formKey, plan: model.plan),
                      PlanDeleteButton(plan: model.plan),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StartDateInput extends StatelessWidget {
  const StartDateInput({Key? key, required this.startDate, required this.endDate, required this.update}) : super(key: key);

  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTime) update;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Start date', style: Theme.of(context).textTheme.subtitle2),
        DateTimePicker(
          type: DateTimePickerType.date,
          dateMask: 'd MMM yyyy',
          firstDate: DateTime.now().add(const Duration(days: -20*7)),
          lastDate: DateTime.now().add(const Duration(days: 365*3)),
          icon: const Icon(Icons.event),
          dateLabelText: 'Start date',
          initialValue: startDate.toString(),
          onChanged: (val) => update(DateTime.parse(val)),
          decoration: const InputDecoration(
            errorMaxLines: 2,
          ),
          validator: (val) {
            if (val!.isEmpty) {
              return 'Enter a plan start date';
            }

            var newStart = DateTime.parse(val);

            if (newStart.isSameDay(endDate) || newStart.isAfter(endDate)) {
              return 'Start date must be before plan end';
            }

            return null;
          },
        ),
      ],
    );
  }
}

class EndDateInput extends StatelessWidget {
  const EndDateInput({Key? key, required this.startDate, required this.endDate, required this.update}) : super(key: key);

  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTime) update;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('End date', style: Theme.of(context).textTheme.subtitle2),
        DateTimePicker(
          type: DateTimePickerType.date,
          dateMask: 'd MMM yyyy',
          firstDate: DateTime.now().add(const Duration(days: -20*7)),
          lastDate: DateTime.now().add(const Duration(days: 365*3)),
          icon: const Icon(Icons.event),
          dateLabelText: 'End date',
          initialValue: endDate.toString(),
          onChanged: (val) => update(DateTime.parse(val)),
          decoration: const InputDecoration(
            errorMaxLines: 2,
          ),
          validator: (val) {
            if (val!.isEmpty) {
              return 'Enter a plan end date';
            }

            var newEnd = DateTime.parse(val);

            if (newEnd.isSameDay(startDate) || newEnd.isBefore(startDate)) {
              return 'End date must be after plan start';
            }

            return null;
          },
        ),
      ],
    );
  }
}

class PlanEditButton extends StatelessWidget {
  const PlanEditButton({Key? key, required this.formKey, required this.plan}) : super(key: key);

  final GlobalKey<FormState> formKey;
  final Plan plan;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
      ),
      onPressed: () {
        final form = formKey.currentState;
        if (form!.validate()) {
          plan.overlappingPlan().then((overlapping) {
            if (overlapping != null) {
              showDialog(
                context: context,
                builder: (context) {
                  var formatter = DateFormat.yMMMd();
                  return AlertDialog(
                    title: const Text("New plan can't overlap existing plan!"),
                    content: Text("Plan '" + overlapping.name + "' runs from " +
                        formatter.format(overlapping.startDate) + " to " +
                        formatter.format(overlapping.endDate)
                    ),
                    actions: [
                      TextButton(
                        child: const Text("OK"),
                        onPressed: () { Navigator.of(context).pop(); },
                      )
                    ],
                  );
                }
              );
            } else {
              plan.events.removeWhere((event) => !event.date.inRange(plan.startDate, plan.endDate));
              plan.savePlanUpdate().then((_) => Navigator.pop(context));
            }
          });
        }
      },
      child: const Text('Update plan'),
    );
  }
}

class PlanDeleteButton extends StatelessWidget {
  const PlanDeleteButton({Key? key, required this.plan}) : super(key: key);

  final Plan plan;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
      ),
      onPressed: () => plan.delete().then((_) => Navigator.pop(context)),
      child: const Text('Delete plan', style: TextStyle(color: Colors.red)),
    );
  }
}
