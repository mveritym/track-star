import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:track_star/Plans/add/select_plan_type.dart';
import 'generate_plan_placeholder.dart';
import 'package:track_star/Plans/plan_widgets.dart';

class SelectHasPlan extends StatelessWidget {
  const SelectHasPlan({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'SelectHasPlan');

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
                'Do you already have a training plan?',
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
                    title: 'Yes',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SelectPlanType())
                      );
                    }
                  ),
                  const SizedBox(height: 16),
                  ActionButton(
                    title: 'No',
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const GeneratePlanPlaceholder())
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
