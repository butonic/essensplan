import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:english_words/english_words.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../model/dish.dart';
import '../model/day.dart';
import '../widgets/day.dart';
import 'package:hive/hive.dart';

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
            }));
  }

  Widget _buildRow(BuildContext context, int day) {
    var d = epoch.add(Duration(days: day));
    return ListTile(
        //leading: Text(DateFormat('E\ndd.MM.yy').format(d)),
        title: Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(DateFormat('E dd.MM.yy').format(d)),
            Spacer(),
            IconButton(
                icon: Icon(Icons.add),
                // TODO zurückgegebenes dish hinzufügen https://flutter.dev/docs/cookbook/navigation/returning-data#interactive-example
                onPressed: () {
                  _selectDish(context, day);
                }),
            IconButton(
              icon: Icon(Icons.note_add),
              onPressed: () {
                // TODO add editable text field
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
                  dm.entries.add(new Dish(note: "something on this day"));
                  dm.save();
                  // TODO DBProvider.db
                  //.addDishToDay(day, 0, null, "something on this day");
                });
              },
            ),
          ],
        ),
        DayWidget(day: day)
      ],
    ));
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
