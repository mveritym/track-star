import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:track_star/Plans/models/plan.dart';
import 'package:track_star/Plans/edit/edit_plan.dart';
import 'package:track_star/Plans/plans_provider.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:track_star/shared/scaffolds.dart';

import '../add/select_plan_type.dart';

class PlanList extends StatefulWidget {
  const PlanList({Key? key}) : super(key: key);

  @override
  State<PlanList> createState() => _PlanListState();
}

class _PlanListState extends State<PlanList> {

  @override
  Widget build(BuildContext context) {

    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'PlanList');

    return TabViewScaffold(
      title: 'All plans',
      actionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SelectPlanType())
            );
          },
          tooltip: 'Add',
          child: const Icon(Icons.add),
          backgroundColor: Colors.black,
        ),
      ),
      body: ChangeNotifierProvider<PlansProvider>(
        create: (context) => PlansProvider(),
        child: Selector<PlansProvider, List<Plan>>(
          selector: (_, provider) => provider.plans,
          builder: (context, plans, child) {
            return GroupedListView<Plan, PlanStatus>(
              elements: plans,
              groupBy: (plan) => plan.status,
              groupComparator: (a, b) => a.index - b.index,
              groupSeparatorBuilder: (PlanStatus status) => Padding(
                padding: const EdgeInsets.fromLTRB(16,32,16,8),
                child: Text(status.getDisplayName(), style: Theme.of(context).textTheme.headline6),
              ),
              itemBuilder: (context, plan) => PlanListTile(plan: plan),
            );
          }
        ),
      ),
    );
  }
}

class PlanListTile extends StatelessWidget {
  const PlanListTile({Key? key, required this.plan}) : super(key: key);
  final Plan plan;

  @override
  Widget build(BuildContext context) {
    var isRace = plan.isRace;
    var name = plan.name;
    var raceType = plan.raceType;

    var formatter = DateFormat("MMMM ''yy");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        shadowColor: Colors.blueAccent,
        elevation: 3,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditPlan(initialPlan: plan)),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: isRace ?
                const Icon(Icons.emoji_events, size: 50, color: Colors.amber) :
                const Icon(Icons.directions_run, size: 50, color: Colors.blueGrey),
              title: Text(name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  raceType != null ? Text(raceType.getDisplayName()) : Container(),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0,8,0,0),
                    child: Text(formatter.format(plan.startDate) + " – " + formatter.format(plan.endDate))
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
