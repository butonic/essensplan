import 'package:flutter/material.dart';

import '../model/dish.dart';

class DishList extends StatelessWidget {
  final List<Dish> dishes;

  DishList({Key key, this.dishes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
        itemCount: dishes == null ? 0 : dishes.length,
        itemBuilder: (BuildContext context, int index) {
          return new Card(
            child: new InkWell(
              onTap: () {
                Navigator.pop<Dish>(context, dishes[index]);
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
