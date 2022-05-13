import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_star/Calendar/calendar.dart';
import 'package:track_star/Plans/add/select_plan_type.dart';
import 'package:track_star/Plans/plans_provider.dart';
import 'package:track_star/Plans/list/plan_list.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (_) => PlansProvider(),
      child: Selector<PlansProvider, bool>(
        selector: (_, provider) => provider.plans.isEmpty,
        builder: (_, isEmpty, __) {

          if (isEmpty) {
            return const SelectPlanType();
          }

          return DefaultTabController(
            key: UniqueKey(),
            length: 2,
            animationDuration: Duration.zero,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  flex: 8,
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      Calendar(),
                      PlanList(),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(
                        color: Colors.indigo.withOpacity(0.2),
                        spreadRadius: 10,
                        blurRadius: 20,
                        offset: const Offset(0, 7),
                      )
                      ],
                    ),
                    child: const Material(
                      child: TabBar(
                          indicatorColor: Colors.white,
                          labelColor: Colors.indigo,
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(icon: Icon(Icons.app_registration), text: 'Training'),
                            Tab(icon: Icon(Icons.sort), text: 'All plans')
                          ]
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        }
      ),
    );
  }
}