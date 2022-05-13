import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:track_star/Events/events.dart';
import 'package:track_star/Plans/models/plan.dart';
import 'package:track_star/Calendar/calendar_provider.dart';
import 'package:track_star/Calendar/shared.dart';
import 'package:track_star/User/user_provider.dart';

class EventCard extends StatelessWidget {
  const EventCard({Key? key, required this.date, required this.child}) : super(key: key);
  final DateTime date;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var format = DateFormat('d MMMM y');
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: const ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                side: BorderSide(color: Colors.indigo),
              ),
              color: Colors.indigo,
            ),
            child: Text(
              format.format(date),
              textAlign: TextAlign.left,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            )
        ),
        const SizedBox(height: 32),
        child
      ],
    );
  }
}

class AddEventModel extends ChangeNotifier {
  late DateTime date;
  late EventType type;
  String? distanceText;
  String? notes;
  bool complete = false;
  Plan? plan;

  Event? existingEvent;

  get color => type == EventType.run ? (complete ? Colors.amber : Colors.green) : Colors.blueAccent;

  AddEventModel.edit(BuildContext context, Weekday weekday) {
    date = weekday.date;
    type = weekday.event == null ? EventType.rest : EventType.run;
    existingEvent = weekday.event;
    distanceText = weekday.getCellText(context);
    notes = existingEvent?.notes;
    complete = existingEvent?.complete ?? false;
    plan = weekday.plan;
  }

  AddEventModel.newModel(BuildContext context, Weekday weekday) {
    date = weekday.date;
    type = EventType.run;
    existingEvent = weekday.event;
    distanceText = weekday.getCellText(context);
    notes = existingEvent?.notes;
    complete = existingEvent?.complete ?? false;
    plan = weekday.plan;
  }

  void updateDistance(String distance) {
    distanceText = distance;
    notifyListeners();
  }

  void updateNotes(String notes) {
    this.notes = notes;
    notifyListeners();
  }

  void updateType(EventType? type) {
    if (type != null) {
      this.type = type;

      if (type == EventType.rest) {
        distanceText = '';
        notes = null;
        complete = false;
      }
    }

    notifyListeners();
  }

  void updateComplete(bool? complete) {
    this.complete = complete!;
    notifyListeners();
  }
}

class EditEvent extends StatelessWidget {
  const EditEvent({Key? key, required this.weekday}) : super(key: key);

  final Weekday weekday;

  static final _formKey = GlobalKey<FormState>(debugLabel: '_EditEventState');

  @override
  Widget build(BuildContext context) {

    var model = AddEventModel.edit(context, weekday);

    return Form(
      key: EditEvent._formKey,
      child: ChangeNotifierProvider<AddEventModel>.value(
        value: model,
        child: Selector<AddEventModel, Color>(
          selector: (context, model) => model.color,
          builder: (context, color, child) {
            return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 32),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: child,
            );
          },
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        EventTypeSelector(),
                        SizedBox(width: 16),
                        CompletionCheck(),
                      ],
                    ),
                  ),
                  const DistanceInputField(autoFocus: false),
                  const NotesInputField(),
                ],
              ),
              Positioned(
                right: 0,
                top: 0,
                child: EventFormSubmitButton(formKey: EditEvent._formKey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DistanceInputField extends StatelessWidget {
  const DistanceInputField({Key? key, required this.autoFocus}) : super(key: key);

  final bool autoFocus;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSettingsProvider>(
      builder: (context, settingsProvider, _) => Consumer<AddEventModel>(
        builder: (context, model, child) {

          TextEditingController distanceController = TextEditingController();
          FocusNode focusNode = FocusNode();

          if (autoFocus && model.plan!.events.isNotEmpty) {
            focusNode.requestFocus();
          }

          distanceController.value = TextEditingValue(
              text: model.distanceText ?? '',
              selection: TextSelection.fromPosition(
                  TextPosition(offset: model.distanceText?.length ?? 0)
              )
          );

          distanceController.addListener(() {
            final String text = distanceController.text.replaceAll(RegExp(r'[^0-9.]$'), '');
            model.updateDistance(text);
          });

          if (model.type != EventType.run) {
            return Container();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0,0,0,4),
                child: Text('Distance', style: Theme
                    .of(context)
                    .textTheme
                    .subtitle2),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 100),
                    child: IntrinsicWidth(
                      child: TextFormField(
                        focusNode: focusNode,
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        controller: distanceController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          errorMaxLines: 2,
                        ),
                        style: const TextStyle(fontSize: 20),
                        maxLines: 1,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter a distance';
                          }

                          var parsedVal = double.tryParse(value);
                          if (parsedVal == null || parsedVal <= 0) {
                            return 'Invalid distance';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    settingsProvider.settings?.unit.name ?? 'No unit',
                    style: Theme.of(context).textTheme.headline5
                  ),
                ],
              ),
            ],
          );
        }
      ),
    );
  }
}

class NotesInputField extends StatelessWidget {
  const NotesInputField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Consumer<AddEventModel>(
      builder: (context, model, child) {

        if (model.type != EventType.run) {
          return Container();
        }

        TextEditingController _notesController = TextEditingController();

        _notesController.value = TextEditingValue(
            text: model.notes ?? '',
            selection: TextSelection.fromPosition(
                TextPosition(offset: model.notes?.length ?? 0)
            )
        );

        _notesController.addListener(() {
          model.updateNotes(_notesController.text);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Notes', style: Theme.of(context).textTheme.subtitle2),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 4, 0, 0),
              child: TextFormField(
                scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 40.0),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  fillColor: Colors.white,
                  filled: true,
                ),
                style: Theme.of(context).textTheme.headline6,
                minLines: 2,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: _notesController,
              ),
            ),
          ]
        );
      }
    );
  }
}

class EventTypeSelector extends StatelessWidget {
  const EventTypeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Consumer<AddEventModel>(
        builder: (context, model, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('Type', style: Theme
                    .of(context)
                    .textTheme
                    .subtitle2),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: EventType.values.map((type) {
                    bool isSelected = type == model.type;
                    return GestureDetector(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? model.color : Colors.white,
                        ),
                        child: Text(
                          type.getDisplayName(),
                          style: TextStyle(fontSize: 18, color: isSelected ? Colors.white : model.color),
                        ),
                      ),
                      onTap: () => model.updateType(type),
                    );
                  }
                  ).toList(),
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}

class CompletionCheck extends StatelessWidget {
  const CompletionCheck({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AddEventModel>(
      builder: (context, model, child) {

        if (model.type == EventType.rest ||
            (!isSameDay(model.date, DateTime.now()) &&
                model.date.isAfter(DateTime.now()))) {
          return Container();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0,0,0,4),
              child: Text('Complete?', style: Theme.of(context).textTheme.subtitle2),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4,4,0,0),
              child: Transform.scale(
                scale: 2,
                child: Checkbox(
                  value: model.complete,
                  onChanged: model.updateComplete,
                  activeColor: model.color,
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}

class EventFormSubmitButton extends StatelessWidget {
  const EventFormSubmitButton({Key? key, required this.formKey}) : super(key: key);

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Consumer<AddEventModel>(
      builder: (context, model, child) => SizedBox.square(
        dimension: 40,
        child: InkWell(
          child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: model.color),
                color: model.color,
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              ),
              child: const Icon(Icons.save, color: Colors.white, size: 20)
          ),
          onTap: () {

            if (!formKey.currentState!.validate()) { return; }

            CalendarProvider provider = context.read<CalendarProvider>();
            Event? event = model.existingEvent;

            if (model.type == EventType.rest) {
              event?.delete();
            } else if (formKey.currentState!.validate()) {
              if (event != null) {
                event.update(context, model);
              } else {
                event = Event.createAndAdd(context, model);
              }
            }

            event?.plan!.savePlanUpdate();
            provider.setEditingSelectedDay(false);
          },
        ),
      ),
    );
  }
}
