import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:track_star/shared/date_utils.dart';

import '../models/add_plan_model.dart';
import '../models/add_plan_weeks_model.dart';
import '../models/plan.dart';
import '../models/plan_type_model.dart';
import 'add_plan_weeks.dart';
import 'package:track_star/User/user_provider.dart';
import 'package:track_star/Plans/plan_widgets.dart';

class TrainingDetailsPage extends StatelessWidget {
  const TrainingDetailsPage({Key? key, this.model}) : super(key: key);

  final AddPlanModel? model;

  @override
  Widget build(BuildContext context) {

    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'AddTrainingDetails');

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: ChangeNotifierProvider<AddPlanModel>(
          create: (context) => model != null ?
            AddPlanModel.from(model!) :
            AddPlanModel(PlanType.baseTraining, 'Base training', false),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add your training plan details', style: Theme.of(context).textTheme.headline3),
                TrainingInputs(showWeekInput: model?.endDate == null),
              ],
            ),
          )
        )
    );
  }
}

class TrainingInputs extends StatelessWidget {
  const TrainingInputs({Key? key, required this.showWeekInput}) : super(key: key);

  final bool showWeekInput;

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<UserSettings?>(
        future: UserSettingsProvider.get(),
        builder: (BuildContext context, AsyncSnapshot<UserSettings?> snapshot) {

          var hasUnit = snapshot.data?.unit != null;

          return Consumer<AddPlanModel>(
              builder: (context, model, _) {

                final _formKey = GlobalKey<FormState>();

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            DateInput(
                              title: 'Plan start date',
                              date: model.startDate,
                              update: model.updateStartDate,
                            ),
                            showWeekInput ? const SizedBox(height: 32) : Container(),
                            showWeekInput ? IntegerInput(
                              title: 'Number of weeks in plan',
                              number: model.getNumWeeks(),
                              update: model.updateNumWeeks,
                            ) : Container(),
                            const SizedBox(height: 32),
                            RunDaysInput(
                              runDays: model.runDays,
                              update: model.toggleRunDay
                            ),
                            !hasUnit ? const SizedBox(height: 16) : Container(),
                            !hasUnit ? UnitInput(
                              selectedUnit: model.unit,
                              update: model.updateUnit,
                            ) : Container(),
                            const SizedBox(height: 16),
                          ],
                        ),
                        ActionButton(
                          title: 'Next',
                          onTap: () async {

                            var formValid = _formKey.currentState?.validate() ?? false;
                            if (!formValid) { return; }

                            if (!hasUnit) {
                              PackageInfo packageInfo = await PackageInfo.fromPlatform();
                              String version = packageInfo.version;
                              UserSettings(FirebaseAuth.instance.currentUser!.uid, model.unit, version).save();
                            }

                            var newPlan = Plan.fromLaunchModel(model);
                            newPlan.overlappingPlan().then((plan) {
                              if (plan != null) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      var formatter = DateFormat.yMMMd();
                                      return AlertDialog(
                                        title: const Text("New plan can't overlap existing plan!"),
                                        content: Text("Plan '" + plan.name + "' runs from " +
                                            formatter.format(plan.startDate) + " to " +
                                            formatter.format(plan.endDate)
                                        ),
                                        actions: [
                                          TextButton(
                                            child: const Text("OK"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          )
                                        ],
                                      );
                                    }
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    var provider = AddPlanWeeksModel(model.runDays, newPlan);
                                    return AddPlanWeeks(provider: provider);
                                  }),
                                );
                              }
                            });
                          },
                        )
                      ],
                    ),
                  ),
                );
              }
          );
        }
    );
  }
}
