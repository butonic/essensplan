import 'package:flutter/material.dart';

import '../model/dish.dart';
import '../callbacks/dish.dart';

class DishOrNoteWidget extends StatefulWidget {
  final Dish dish;

  /// Called when the user taps a dish.
  final DishTapCallback onTap;

  /// Called when the user taps a dish.
  final Widget noteSuffix;

  DishOrNoteWidget({Key key, this.dish, this.onTap, this.noteSuffix})
      : super(key: key);

  @override
  _DishOrNoteWidgetState createState() => _DishOrNoteWidgetState();
}

class _DishOrNoteWidgetState extends State<DishOrNoteWidget> {
  Widget text = Text("Empty");

  @override
  Widget build(BuildContext context) {
    if (widget.dish == null) {
      text = Text('');
    } else if (widget.dish.name != null) {
      text = Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: GestureDetector(
            child: Text(widget.dish.name,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    decoration: widget.dish.deleted != true
                        ? TextDecoration.none
                        : TextDecoration.lineThrough)),
            onTap: () {
              widget.onTap(context, widget.dish);
            }),
      ));
    } else if (widget.dish.note != null) {
      text = TextField(
        maxLines: null,
        textAlign: TextAlign.center,
        autofocus: false,
        controller: TextEditingController(text: widget.dish.note),
        style: TextStyle(
          color: Colors.black87,
          fontSize: 14,
        ),
        decoration: InputDecoration(
            suffix: widget.noteSuffix,
            isDense: true,
            contentPadding: const EdgeInsets.all(4.0),
            border: InputBorder.none,
            hintText: 'Neue Notiz'),
        onChanged: (value) {
          if (widget.dish.note != value) {
            widget.dish.note = value;
            widget.dish.save();
          }
        },
        //onTap: () {
        //  widget.onTap(context, widget.dish);
        //},
      );
    }
    return text;
    /*return SizedBox(
      width: double.infinity,
      child: text,
    );
    */
  }
}
