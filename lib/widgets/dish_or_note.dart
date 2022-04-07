import 'package:flutter/material.dart';

import '../model/dish.dart';
import '../callbacks/dish.dart';

class DishOrNoteWidget extends StatefulWidget {
  final Dish? dish;

  /// Called when the user taps a dish.
  final DishTapCallback onTap;

  DishOrNoteWidget({
    Key? key,
    this.dish,
    required this.onTap,
  }) : super(key: key);

  @override
  _DishOrNoteWidgetState createState() => _DishOrNoteWidgetState();
}

class _DishOrNoteWidgetState extends State<DishOrNoteWidget> {
  Widget text = const Text('Empty');

  bool editing = false;

  @override
  Widget build(BuildContext context) {
    if (widget.dish == null) {
      text = const Text('');
    } else if (widget.dish!.name != null) {
      text = Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: GestureDetector(
            child: Text(widget.dish!.name!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    decoration: widget.dish!.deleted != true
                        ? TextDecoration.none
                        : TextDecoration.lineThrough)),
            onTap: () {
              widget.onTap(context, widget.dish!);
            }),
      ));
    } else if (widget.dish!.note != null) {
      text = Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: GestureDetector(
            child: Text(widget.dish!.note!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    decoration: widget.dish!.deleted != true
                        ? TextDecoration.none
                        : TextDecoration.lineThrough)),
            onTap: () {
              widget.onTap(context, widget.dish!);
            }),
      ));
    }
    return text;
  }
}
