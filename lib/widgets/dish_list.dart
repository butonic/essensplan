import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

import '../model/day.dart';
import '../model/dish.dart';
import '../callbacks/dish.dart';

class DishList extends StatelessWidget {
  final List<Dish> dishes;

  /// Called when the user taps a dish.
  final DishTapCallback onTap;

  /// Called when the user long-presses a dish.
  final DishLongPressCallback onLongPress;
  // TODO inject?
  final epoch = new DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  DishList({Key key, this.dishes, this.onLongPress, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dayBox = Hive.box<Day>('dayBox');
    final sorted = dayBox.keys.toList();
    sorted.sort((a, b) => b.compareTo(a));
    return new ListView.builder(
        itemCount: dishes == null ? 0 : dishes.length,
        itemBuilder: (BuildContext context, int index) {
          // This searches from the most recent date ... will still get slow over time
          var lastCookedDay = sorted.firstWhere(
            (i) => dayBox.get(i)?.entries?.contains(dishes[index]),
            orElse: () => null,
          );

          Text dateText;
          if (lastCookedDay != null) {
            dateText = Text(DateFormat('dd.MM.yyyy')
                .format(epoch.add(Duration(days: lastCookedDay))));
          } else {
            dateText = Text("nie");
          }

          return new Card(
            child: new InkWell(
              onTap: () {
                this.onTap(context, dishes[index]);
              },
              onLongPress: () {
                this.onLongPress(context, dishes[index]);
              },
              child: new Center(
                child: new Column(
                  // Stretch the cards in horizontal axis
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text(
                          dishes[index].name,
                        ),
                        dateText,
                        //new Text('12.23.2019'),
                      ],
                    ),
                    new Text(
                      dishes[index].categories.map((e) => e.name).join(" "),
                      // set some style to text
                      style: new TextStyle(fontSize: 15.0, color: Colors.amber),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
