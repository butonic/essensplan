import 'package:flutter/material.dart';

import '../callbacks/plan.dart';

// We use a new widget to get a new context for the new note action that should
// show the bottom sheet.
class DishBottomBar extends StatelessWidget {
  /// Called when the user taps on 'today'.
  final PlanTapTodayCallback onTapToday;

  /// Called when the user taps on 'new note'.
  final PlanTapNewNoteCallback onTapNewNote;

  /// Called when the user taps on 'categories'.
  final PlanTapCategoriesCallback onTapCategories;

  DishBottomBar({
    Key? key,
    required this.onTapToday,
    required this.onTapNewNote,
    required this.onTapCategories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: Row(
        children: [
          GestureDetector(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.today),
                    Text(
                      'Heute',
                      style: Theme.of(context).textTheme.caption,
                    )
                  ],
                )),
            onTap: () {
              onTapToday(context);
            },
          ),
          Spacer(),
          GestureDetector(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.note_add),
                      Text(
                        'Notiz',
                        style: Theme.of(context).textTheme.caption,
                      )
                    ],
                  )),
              onTap: () {
                onTapNewNote(context);
              }),
          GestureDetector(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.category,
                      color: Colors.black38,
                    ),
                    Text(
                      'Kategorien',
                      style: Theme.of(context).textTheme.caption,
                    )
                  ],
                )),
            onTap: () {
              onTapCategories(context);
            },
          ),
        ],
      ),
    );
  }
}
