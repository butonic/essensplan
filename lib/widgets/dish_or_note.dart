import 'package:flutter/material.dart';

import '../model/day.dart';
import '../model/dish.dart';

class DishOrNoteWidget extends StatefulWidget {
  final Day _day;
  final Dish _dish;
  DishOrNoteWidget({
    Day day,
    Dish dish,
  })  : this._dish = dish,
        this._day = day;

  @override
  _DishOrNoteWidgetState createState() =>
      _DishOrNoteWidgetState(day: _day, dish: _dish);
}

class _DishOrNoteWidgetState extends State<DishOrNoteWidget> {
  final Day _day;
  final Dish _dish;
  _DishOrNoteWidgetState({
    Day day,
    Dish dish,
  })  : this._dish = dish,
        this._day = day;

  bool inEditMode = false;
  Widget text = Text("Empty");

  @override
  Widget build(BuildContext context) {
    if (_dish == null) {
      text = Text('');
    } else if (_dish.name != null) {
      text = TextField(
        // this is not editable
        enabled: false,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        controller: TextEditingController(text: _dish.name),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.all(8.0),
          border: InputBorder.none,
        ),
        onTap: () {
          // unfocus current text input
          // see https://flutterigniter.com/dismiss-keyboard-form-lose-focus/
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
      );
    } else if (_dish.note != null) {
      var controller = new TextEditingController(text: _dish.note);
      text = TextField(
        keyboardType: TextInputType.multiline,
        maxLines: null,
        textAlign: TextAlign.center,
        autofocus: false,
        controller: controller,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.all(8.0),
          border: InputBorder.none,
          //hintText: 'Enter a Note'
        ),
        onChanged: (value) {
          if (_dish.note != value) {
            _dish.note = value;
            _dish.save();
          }
        },
      );
    }
    return Dismissible(
        key: ObjectKey(_dish),
        onDismissed: (direction) {
          var removed = this._day.entries.remove(this._dish);
          if (removed) {
            this._day.save();
            // TODO wenn die liste leer ist muss das neu gerendert werden setState(() {});
          }
          // Show a snackbar. This snackbar could also contain "Undo" actions.
          //Scaffold.of(context).showSnackBar(
          //    SnackBar(content: Text("${this._dish.name} dismissed")));
        },
        child: SizedBox(
          width: double.infinity,
          child: text,
        ));
  }
}
