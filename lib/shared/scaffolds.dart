import 'package:flutter/material.dart';
import 'package:track_star/User/user_settings.dart';
import 'package:track_star/shared/app_metrics.dart';

class TabViewScaffold extends StatelessWidget {
  const TabViewScaffold({Key? key, required this.title, this.actionButton, required this.body}) : super(key: key);

  final String title;
  final Widget? actionButton;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(251, 244, 244, 1),
      resizeToAvoidBottomInset: false,
      floatingActionButton: actionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: Stack(
        children: [
          body,
          Positioned(
            top: AppMetrics.paddingTop,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.settings),
              color: Theme.of(context).colorScheme.primary,
              iconSize: 30,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const UserSettingsView())
                );
              },
            ),
          ),
        ],
      )
    );
  }
}
