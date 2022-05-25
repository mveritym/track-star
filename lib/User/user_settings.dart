import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_star/User/user_provider.dart';

class UserSettingsView extends StatelessWidget {
  const UserSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'Settings');

    return Scaffold(
      backgroundColor: const Color.fromRGBO(251, 244, 244, 1),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ChangeNotifierProvider<UserSettingsProvider>(
              create: (context) => UserSettingsProvider(),
              child: Consumer<UserSettingsProvider>(
                builder: (context, provider, _) => SettingsButton(
                  title: 'Change unit',
                  icon: const Icon(Icons.straighten),
                  onTap: () => provider.toggleUnit(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(provider.settings?.unit.name ?? 'no unit', style: Theme.of(context).textTheme.headline6),
                  )),
              ),
            ),
          ]
      ),
    );
  }
}

class SettingsButton extends StatefulWidget {
  const SettingsButton({Key? key, required this.title, required this.icon, required this.onTap, this.child}) : super(key: key);

  final String title;
  final Icon icon;
  final Function() onTap;
  final Widget? child;

  @override
  State<SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<SettingsButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
            height: 75,
            decoration: BoxDecoration(
              border: Border.all(width: 2),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  widget.icon,
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(widget.title, style: Theme.of(context).textTheme.headline6),
                          widget.child != null ? widget.child! : Container(),
                        ]
                    ),
                  ),
                ],
              ),
            )
        ),
      ),
    );
  }
}
