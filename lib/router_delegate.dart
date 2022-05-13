import 'package:flutter/material.dart';
import 'package:track_star/Login/auth_service.dart';
import 'package:track_star/Plans/plans_provider.dart';
import 'Plans/models/plan.dart';
import 'app.dart';
import 'Launch/first_launch.dart';

class AppRouterDelegate extends RouterDelegate with ChangeNotifier, PopNavigatorRouterDelegateMixin {

  final GlobalKey<NavigatorState> _navigatorKey;
  final AuthService authService;

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  AppRouterDelegate({required this.authService}) : _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Plan>>(
      future: Future<List<Plan>>(() async {
        await authService.loginOrRegister();
        return await PlansProvider.getPlans();
      }),
      builder: (context, AsyncSnapshot<List<Plan>> snapshot) {

        if (!snapshot.hasData) { return Container(); }

        bool hasPlans = snapshot.data!.isNotEmpty;

        return Navigator(
          key: navigatorKey,
          pages: [MaterialPage(
            child: hasPlans ? const App() : const FirstLaunch(),
          )],
          onPopPage: (route, result) {
            return route.didPop(result);
          },
        );
      },
    );
  }

  @override
  Future<void> setNewRoutePath(configuration) async {}
}