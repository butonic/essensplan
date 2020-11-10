import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:hive/hive.dart';

import '../model/dish.dart';
import '../model/day.dart';
import '../widgets/day.dart';

const dayUnselected = -1;

class PlanPage extends StatefulWidget {
  PlanPage({Key key}) : super(key: key);

  @override
  _PlanPageState createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final epoch = new DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

// TODO manually keep track of previous selection, then unselect previous day
  int selectedDay = dayUnselected;

  @override
  Widget build(BuildContext context) {
    var now = new DateTime.now().toUtc();
    var currentDay =
        now.difference(epoch).inDays; // ~18k -> 20k*2 = 40k for now

    return Scaffold(
      appBar: AppBar(
        title: Text('Planung'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () {
                itemScrollController.scrollTo(
                    index: currentDay,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic);
              }),
          IconButton(
            icon: Icon(Icons.restaurant_menu),
            onPressed: () {
              _selectDish(context,
                  -1); // TODO this is not used to select a certain day...
            },
            tooltip: "23", // kommt bei long press
          ),
        ],
      ),
      body: ScrollablePositionedList.builder(
          initialScrollIndex: currentDay,
          padding: const EdgeInsets.all(4.0),
          itemCount: 40000,
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          itemBuilder: (context, i) {
            return _buildRow(context, i);
          }),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            bottom: 10.0,
            right: 10.0,
            child: FloatingActionButton(
              heroTag: 'note',
              onPressed: selectedDay == dayUnselected
                  ? null
                  : () {
                      // TODO add editable text field
                      setState(() {
                        var dayBox = Hive.box<Day>('dayBox');
                        var dm = dayBox.get(selectedDay);
                        if (dm == null) {
                          dm = new Day();
                          dayBox.put(selectedDay, dm);
                        }
                        if (dm.entries == null) {
                          dm.entries = new HiveList(Hive.box<Dish>('dishBox'));
                        }
                        //var note = new Dish(note: "Notiz");
                        var note = new Dish(
                            note: ""); // a hint is rendered for an empty string
                        Hive.box<Dish>('dishBox').add(note);
                        dm.entries.add(note);
                        dm.save();
                      });
                    },
              child: Icon(Icons.note_add),
            ),
          ),
          Positioned(
            bottom: 10.0,
            right: 80.0,
            child: FloatingActionButton(
              heroTag: 'dish',
              onPressed: selectedDay == dayUnselected
                  ? null
                  : () {
                      _selectDish(context, selectedDay);
                    },
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, int day) {
    var d = epoch.add(Duration(days: day));
    return ListTile(
        tileColor: day == selectedDay ? Colors.amber : Colors.white,
        leading: GestureDetector(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  DateFormat('E').format(d),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(DateFormat('dd.MM').format(d)),
              ],
            ),
            onTap: () {
              // unfocus current text input
              // see https://flutterigniter.com/dismiss-keyboard-form-lose-focus/
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              } else {
                // TODO prevent row from being selected if we are just tapping to unfocus a note
              }
              setState(() {
                if (selectedDay == day) {
                  selectedDay = dayUnselected;
                } else {
                  selectedDay = day;
                }
              });
            }),
        title: DayWidget(day: day));
  }

  void _selectDish(BuildContext context, int day) async {
    // TODO dish zurückgeben https://flutter.dev/docs/cookbook/navigation/returning-data#interactive-example
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.pushNamed(context, '/dishes');
    //final result = await Navigator.push(
    //  context,
    //  MaterialPageRoute<Dish>(builder: (context) => DishesPage()),
    //);

    if (result is Dish) {
      setState(() {
        var dayBox = Hive.box<Day>('dayBox');
        var dm = dayBox.get(day);
        if (dm == null) {
          dm = new Day();
          dayBox.put(day, dm);
        }
        if (dm.entries == null) {
          dm.entries = new HiveList(Hive.box<Dish>('dishBox'));
        }
        dm.entries.add(result);
        dm.save();
        // TODO DBProvider.db.addDishToDay(day, 0, result.id, null);
      });
    }
  }
}
