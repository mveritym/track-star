import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/add_plan_model.dart';
import '../models/plan_type_model.dart';
import '../models/plan.dart';
import '../plan_widgets.dart';
import 'add_training_details.dart';

class RaceSetup extends StatelessWidget {
  const RaceSetup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'AddRaceDetails');

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: ChangeNotifierProvider<AddPlanModel>(
          create: (context) {
            var model = AddPlanModel(PlanType.race, '', true);
            model.raceType = RaceType.fiveK;
            return model;
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 16.0),
            child: Column(
              children: [
                Text('Add your race details', style: Theme.of(context).textTheme.headline3),
                const RaceInputs(),
              ],
            ),
          ),
        )
    );
  }
}


class RaceInputs extends StatelessWidget {
  const RaceInputs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final _raceInputsKey = GlobalKey<FormState>();

    return Expanded(
      child: Consumer<AddPlanModel>(
        builder: (context, model, _) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
            child: Form(
              key: _raceInputsKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      PlanNameInput(name: model.name, update: model.updateName),
                      const SizedBox(height: 16),
                      PlanTypeInput(type: model.raceType, update: model.updateRaceType),
                      const SizedBox(height: 16),
                      DateInput(title: 'Race date', date: model.endDate, update: model.updateEndDate),
                    ],
                  ),
                  ActionButton(
                    title: 'Next',
                    onTap: () {
                      if (_raceInputsKey.currentState?.validate() ?? false) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => TrainingDetailsPage(model: model)),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
