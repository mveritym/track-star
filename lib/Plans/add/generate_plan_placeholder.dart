import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:track_star/Plans/add/select_plan_type.dart';
import 'package:track_star/Plans/plan_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/firebase_events.dart';

class GeneratePlanPlaceholder extends StatelessWidget {
  const GeneratePlanPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'GeneratePlanPlaceholder');

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
                'Generating plans coming soon!',
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
                    title: 'Add plan manually',
                    onTap: () {
                      var route = MaterialPageRoute(builder: (context) => const SelectPlanType());
                      Navigator.of(context).push(route);
                    }
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: TextButton(
                      child: Text(
                        'See suggested running plans',
                        style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.blue),
                      ),
                      onPressed: () async {
                        FirebaseAnalytics.instance.logCustomEvent(FirebaseEvents.tapSuggestedPlansLink);
                        final Uri _url = Uri.parse('https://mveritym.github.io/track-star/');
                        if (!await launchUrl(_url)) throw 'Could not launch $_url';
                      },
                    ),
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