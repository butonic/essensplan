import 'package:flutter/material.dart';

import '../model/day.dart';
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
  // TODO selected flag, render differently when selected

  bool inEditMode = false;
  final epoch = new DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  @override
  Widget build(BuildContext context) {
    Day d = Hive.box<Day>('dayBox').get(day);
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
        return DishOrNoteWidget(day: d, dish: dish);
      }).toList(),
    );
  }
}
