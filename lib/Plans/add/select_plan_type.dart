import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import '../models/plan_type_model.dart';
import 'add_race_details.dart';
import 'add_training_details.dart';
import 'package:track_star/Plans/plan_widgets.dart';

class SelectPlanType extends StatelessWidget {
  const SelectPlanType({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'SelectPlanType');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: Text(
                  'What are you training for?',
                  style: Theme.of(context).textTheme.headline3
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ActionButton(
                    title: PlanType.race.getDisplayName(),
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const RaceSetup())
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ActionButton(
                    title: PlanType.baseTraining.getDisplayName(),
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const TrainingDetailsPage())
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
