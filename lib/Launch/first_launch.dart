import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:track_star/Plans/add/select_has_plan.dart';

class FirstLaunch extends StatelessWidget {
  const FirstLaunch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'FirstLaunch');

    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(251, 244, 244, 1),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(image: AssetImage('assets/images/TrackStar.png')),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 64),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) =>
                              WillPopScope(
                                onWillPop: () async => false,
                                child: const SelectHasPlan(),
                              )
                            )
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Get started', style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}
