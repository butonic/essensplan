import 'package:flutter/material.dart';

import '../model/dish.dart';
import '../callbacks/dish.dart';

class DishOrNoteWidget extends StatefulWidget {
  final Dish _dish;

  /// Called when the user taps a dish.
  final DishTapCallback onTap;

  DishOrNoteWidget({
    Dish dish,
    DishTapCallback onTap,
  })  : this._dish = dish,
        this.onTap = onTap;

  @override
  _DishOrNoteWidgetState createState() => _DishOrNoteWidgetState();
}

class _DishOrNoteWidgetState extends State<DishOrNoteWidget> {
  Widget text = Text("Empty");

  @override
  Widget build(BuildContext context) {
    if (widget._dish == null) {
      text = Text('');
    } else if (widget._dish.name != null) {
      text = Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: GestureDetector(
            child: Text(widget._dish.name,
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            onTap: () {
              widget.onTap(context, widget._dish);
            }),
      ));
    } else if (widget._dish.note != null) {
      text = TextField(
        maxLines: null,
        textAlign: TextAlign.center,
        autofocus: false,
        controller: TextEditingController(text: widget._dish.note),
        style: TextStyle(
          color: Colors.black87,
          fontSize: 14,
        ),
        decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.all(4.0),
            border: InputBorder.none,
            hintText: 'Neue Notiz'),
        onChanged: (value) {
          if (widget._dish.note != value) {
            widget._dish.note = value;
            widget._dish.save();
          }
        },
        //onTap: () {
        //  widget.onTap(context, widget._dish);
        //},
      );
    }
    return SizedBox(
      width: double.infinity,
      child: text,
    );
  }
}
