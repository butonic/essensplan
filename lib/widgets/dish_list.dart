import 'package:flutter/material.dart';

import '../model/dish.dart';
import '../services/database.dart';

typedef DishTapCallback = void Function(BuildContext context, Dish dish);
typedef DishLongPressCallback = void Function(BuildContext context, Dish dish);

class DishList extends StatelessWidget {
  final List<Dish> dishes;

  /// Called when the user taps a dish.
  final DishTapCallback onTap;

  /// Called when the user long-presses a dish.
  final DishLongPressCallback onLongPress;

  DishList({Key key, this.dishes, this.onLongPress, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
        itemCount: dishes == null ? 0 : dishes.length,
        itemBuilder: (BuildContext context, int index) {
          return new Card(
            child: new InkWell(
              onTap: () {
                this.onTap(context, dishes[index]);
                // Navigator.pop<Dish>(context, dishes[index]);
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
                        new Text('12.23.2019'),
                      ],
                    ),
                    new Text(
                      "Tags: FOO BAR",
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
