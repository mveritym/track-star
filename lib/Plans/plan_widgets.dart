import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:track_star/Plans/models/plan.dart';
import '../Calendar/shared.dart';
import '../Events/events.dart';
import 'package:track_star/shared/app_metrics.dart';

class PlanNameInput extends StatefulWidget {
  const PlanNameInput({Key? key, required this.name, required this.update}) : super(key: key);

  final String name;
  final Function(String) update;

  @override
  State<PlanNameInput> createState() => _PlanNameInputState();
}

class _PlanNameInputState extends State<PlanNameInput> {

  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Race name',
            style: Theme.of(context).textTheme.subtitle1
          ),
          TextFormField(
            focusNode: focusNode,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              errorMaxLines: 2,
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Enter a name for your training plan.';
              }
              return null;
            },
            initialValue: widget.name,
            onChanged: widget.update,
          ),
        ],
      ),
    );
  }
}

class PlanTypeInput extends StatelessWidget {
  const PlanTypeInput({Key? key, required this.type, required this.update}) : super(key: key);

  final RaceType? type;
  final Function(RaceType) update;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select a race type',
          style: Theme.of(context).textTheme.subtitle1
        ),
        DropdownButton<RaceType>(
          isExpanded: true,
          underline: Container(decoration: BoxDecoration(border: Border.all(width: 0.3))),
          items: RaceType.values.map<DropdownMenuItem<RaceType>>((RaceType planType) {
            return DropdownMenuItem<RaceType>(
              value: planType,
              child: Text(planType.getDisplayName()),
            );
          }).toList(),
          onChanged: (RaceType? selection) {
            if (selection != null) {
              update(selection);
            }
          },
          value: type,
        ),
      ],
    );
  }
}

class PlanIsRaceInput extends StatelessWidget {
  const PlanIsRaceInput({Key? key, required this.isRace, required this.update}) : super(key: key);

  final bool isRace;
  final Function(bool?) update;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Race?',
              style: Theme.of(context).textTheme.subtitle2
            ),
            Checkbox(
              value: isRace,
              onChanged: update,
            ),
          ]
      ),
    );
  }
}


class DateInput extends StatelessWidget {

  const DateInput({Key? key, required this.title, required this.date, required this.update,
  this.customValidate}) : super(key: key);

  final String title;
  final DateTime? date;
  final Function(DateTime) update;
  final Function(void)? customValidate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.subtitle1),
        DateTimePicker(
          type: DateTimePickerType.date,
          dateMask: 'd MMM yyyy',
          firstDate: DateTime.now().add(const Duration(days: -20*7)),
          lastDate: DateTime.now().add(const Duration(days: 365*3)),
          icon: const Icon(Icons.event),
          dateLabelText: 'Date',
          initialValue: date.toString(),
          onChanged: (val) => update(DateTime.parse(val)),
          decoration: const InputDecoration(
            errorMaxLines: 2,
          ),
          validator: (String? val) {

            var validateEmpty = ((val == null || val.isEmpty || val == 'null') ?
              'Enter a date' : null);

            if (customValidate != null) {
              return customValidate!(val) ?? validateEmpty;
            }

            return validateEmpty;
          },
        ),
      ],
    );
  }
}

class IntegerInput extends StatelessWidget {
  const IntegerInput({Key? key, required this.title, required this.number, required this.update}) : super(key: key);

  final String title;
  final int? number;
  final Function(int) update;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.subtitle1),
        TextFormField(
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            errorMaxLines: 2,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ],
          validator: (value) {
            if (value!.isEmpty) {
              return 'Enter a whole number';
            }
            return null;
          },
          initialValue: (number ?? '').toString(),
          onChanged: (val) => update(int.parse(val)),
        ),
      ],
    );
  }
}

class RunDaysInput extends StatelessWidget {
  const RunDaysInput({Key? key, required this.runDays, required this.update}) : super(key: key);

  final List<WeekdaySelectorModel> runDays;
  final Function(WeekdaySelectorModel) update;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Days you plan to run', style: Theme.of(context).textTheme.subtitle1),
        const SizedBox(height: 8),
        RunDaysInputField(runDays: runDays, update: update)
      ],
    );
  }
}

class RunDaysInputField extends FormField<List<WeekdaySelectorModel>> {

  final List<WeekdaySelectorModel> runDays;
  final Function(WeekdaySelectorModel) update;

  final GlobalKey _key = GlobalKey();
  double width = 32.0;

  initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      RenderBox box = _key.currentContext?.findRenderObject() as RenderBox;
      width = box.hasSize ? box.size.height : 0;
    });
  }

  RunDaysInputField({
    Key? key,
    required this.runDays,
    required this.update,
  }) : super(
      key: key,
      validator: (model) {
        if (!runDays.any((day) => day.isSelected)) {
          return "Select days to run";
        }
        return null;
      },
      initialValue: runDays,
      builder: (FormFieldState<List<WeekdaySelectorModel>> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: runDays.map((day) =>
                    GestureDetector(
                      onTap: () {
                        update(day);
                        state.didChange(runDays);
                      },
                      child: SizedBox.square(
                          dimension: AppMetrics.calendarCellWidthWithPadding(64),
                          child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(8),
                                color: day.isSelected ? Colors.black : Colors.white,
                              ),
                              child: Center(child: Text(day.name, style: TextStyle(color: day.isSelected ? Colors.white : Colors.black)))
                          )
                      ),
                    )
                ).toList(),
              ),
            ),
            state.hasError ? const SizedBox(height: 8) : Container(),
            state.hasError ?
            Text('Select days to run', style: TextStyle(color: Theme.of(state.context).errorColor, fontSize: 12), textAlign: TextAlign.left) :
            Container()
          ],
        );
      }
  );
}

class UnitInput extends StatelessWidget {
  const UnitInput({Key? key, required this.selectedUnit, required this.update}) : super(key: key);

  final DistanceUnit selectedUnit;
  final Function(DistanceUnit) update;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('How do you measure your runs?', style: Theme.of(context).textTheme.subtitle1),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: DistanceUnit.values.asMap().entries.map((val) {

            var idx = val.key;
            var unit = val.value;
            var selected = unit == selectedUnit;

            return Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: selected ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: idx == 0 ?
                      const BorderRadius.horizontal(left: Radius.circular(8)) :
                      const BorderRadius.horizontal(right: Radius.circular(8)),
                    )
                ),
                onPressed: () => update(unit),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                      unit.name,
                      style: Theme.of(context).textTheme.headline6?.copyWith(
                          color: selected ? Colors.white : Colors.black
                      )
                  ),
                ),
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton({Key? key, required this.title, required this.onTap}) : super(key: key);

  final String title;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline5?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
