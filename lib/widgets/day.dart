import 'package:flutter/material.dart';

import '../model/day.dart';
import 'package:hive/hive.dart';

import 'dish_or_note.dart';
import '../callbacks/dish.dart';

class DayWidget extends StatefulWidget {
  final int day;

  /// Called when the user taps a dish.
  final DishTapCallback onTap;
  DayWidget({
    int day,
    DishTapCallback onTap,
  })  : this.day = day,
        this.onTap = onTap;

  @override
  _DayWidgetState createState() => _DayWidgetState();
}

class _DayWidgetState extends State<DayWidget> {
  // TODO selected flag, render differently when selected

  bool inEditMode = false;
  final epoch = new DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  @override
  Widget build(BuildContext context) {
    Day d = Hive.box<Day>('dayBox').get(widget.day);
    if (d != null) {
      return renderDishes(d);
    } else {
      return new Container(
          alignment: AlignmentDirectional.center, child: Column());
    }
  }

  Widget renderDishes(Day d) {
    if (d.entries.isEmpty) {
      return Column();
    }
    return Column(
      children: d.entries.map((dish) {
        return DishOrNoteWidget(
          day: d,
          dish: dish,
          onTap: widget.onTap,
        );
      }).toList(),
    );
  }
}
