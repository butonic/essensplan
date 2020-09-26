import 'package:flutter/material.dart';

import '../model/dish.dart';
import '../services/database.dart';

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
    return new FutureBuilder<List<Dish>>(
        future: DBProvider.db.getDay(day),
        builder: (BuildContext context, AsyncSnapshot<List<Dish>> snapshot) {
          if (snapshot.hasData) {
            return renderDishes(snapshot.data);
          } else {
            return new Container(
              alignment: AlignmentDirectional.center,
              child: new CircularProgressIndicator(),
            );
          }
        });
  }

  Widget renderDishes(List<Dish> dishes) {
    // TODO swipe left zum löschen?
    if (dishes.length == 0) {
      return Text('nichts geplant',
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
      children: List.generate(dishes.length, (i) {
        return DishOrNoteWidget(dish: dishes[i]);
      }),
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