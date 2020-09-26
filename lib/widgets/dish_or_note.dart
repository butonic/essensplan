import 'package:flutter/material.dart';

import '../model/dish.dart';

class DishOrNoteWidget extends StatefulWidget {
  final Dish _dish;
  DishOrNoteWidget({
    Dish dish,
  }) : this._dish = dish;

  @override
  _DishOrNoteWidgetState createState() => _DishOrNoteWidgetState(dish: _dish);
}

class _DishOrNoteWidgetState extends State<DishOrNoteWidget> {
  final Dish _dish;
  _DishOrNoteWidgetState({
    Dish dish,
  }) : this._dish = dish;

  bool inEditMode = false;
  Widget text = Text("Empty");

  @override
  Widget build(BuildContext context) {
    if (_dish == null) {
      text = Text('');
    } else if (_dish.name != null) {
      text = Text(_dish.name);
    } else if (_dish.note != null) {
      text = Text("Note: " + _dish.note);
    }
    if (inEditMode) {
      return RaisedButton(
        child: Row(
          children: <Widget>[text, Icon(Icons.edit)],
        ),
        onPressed: toggleEditMode,
      );
    } else {
      return FlatButton(
        child: text,
        onPressed: toggleEditMode,
      );
    }
  }

  // TODO edit immer durch navigation auf die gerichteroute mit parameter der gericht id
  // scrollt dann dahin und klappt das gericht auf
  void toggleEditMode() {
    setState(() {
      if (inEditMode) {
        inEditMode = false;
      } else {
        inEditMode = true;
      }
    });
  }
}
