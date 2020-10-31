import 'package:flutter/material.dart';

import '../model/day.dart';
import '../model/dish.dart';
import 'package:hive/hive.dart';

import 'dish_or_note.dart';

class DayWidget extends StatefulWidget {
  final int _day;
  DayWidget({
    int day,
  }) : this._day = day;

  @override
  _DayWidgetState createState() => _DayWidgetState(day: _day);
}

class _DayWidgetState extends State<DayWidget> {
  final int day;
  _DayWidgetState({
    int day,
  }) : this.day = day;

  bool inEditMode = false;
  final epoch = new DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  @override
  Widget build(BuildContext context) {
    Day d = Hive.box<Day>('dayBox').get(day);
    if (d != null) {
      return renderDishes(d);
    } else {
      return new Container(
        alignment: AlignmentDirectional.center,
        child: Text(
          'nichts geplant',
          style: TextStyle(
            color: Colors.grey[300],
          ),
        ),
      );
    }
  }

  Widget renderDishes(Day d) {
    // TODO swipe left zum löschen?
    if (d.entries.isEmpty) {
      return Text(
        'nichts geplant',
        style: TextStyle(
          color: Colors.grey[300],
        ),
      );
      /*return FlatButton(
        //onPressed: toggleEditMode,
        child: Row(
            children: <Widget>[
              Text("Empty"), // TODO show nothing
              Icon(Icons.edit)
            ],
          ),

            onPressed: () {
              setState(() {
                DBProvider.db.addDishToDay(day, 0, null, "something on this day");
               // _toggleEditMode();
              });
            },
      );
      */
    }
    return Column(
      children: d.entries.map((dish) {
        return DishOrNoteWidget(dish: dish);
      }).toList(),
//        Row(
//        mainAxisSize: MainAxisSize.min,
//        children: <Widget>[
//          RaisedButton(
//            child: Text('➕'),
//            onPressed: () {
//              setState(() {
//                DBProvider.db.addDishToDay(day, 0, 0, "something on this day");
//              });
//            },
//          ),
//          RaisedButton(
//            child: Text('✍'),
//            onPressed: toggleEditMode
//            /*
//            onPressed: () {
//              setState(() {
//                DBProvider.db.addDishToDay(_day, 0, null, "something on this day");
//                _toggleEditMode();
//              });
//            },
//            */
//          ),
//        ],
//      )
    );
  }
}
