import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import './daysago.dart';
import '../model/dish.dart';
import '../callbacks/dish.dart';

class DishList extends StatelessWidget {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  final List<Dish> dishes;

  final Dish? scrollTarget;

  /// Called when the user taps a dish.
  final DishTapCallback onTap;

  /// Called when the user long-presses a dish.
  final DishLongPressCallback onLongPress;

  /// Called when the user dismisses a dish.
  final DishDismissCallback onDismissed;
  // TODO inject?
  final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  DishList({
    super.key,
    required this.dishes,
    this.scrollTarget,
    required this.onLongPress,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    // hack to scroll to dish
    if (scrollTarget != null) {
      // find index of targeted dish
      for (var i = 0; i < dishes.length; i++) {
        if (dishes.elementAt(i) == scrollTarget) {
          // register a callback that is executed when the list has been rendered
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (itemScrollController.isAttached) {
              // we use jumpTo because the initialScrollIndex property does not work ... for whatever reason
              itemScrollController.jumpTo(index: i);
            }
          });
          break;
        }
      }
    }
    return ScrollablePositionedList.builder(
      //  initialScrollIndex: initialScrollIndex, // tried that, didn't work. using the hack above
      itemCount: dishes.length,
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
      itemBuilder: (BuildContext context, int index) => item(context, index),
    );
  }

  // generate item for list
  Widget item(BuildContext context, int index) {
    Widget dateText;
    if (dishes[index].lastCookedDay > -1) {
      dateText = DaysAgo(days: dishes[index].lastCookedDay);
    } else {
      dateText = const Text('nie');
    }

    return Dismissible(
      key: ObjectKey(dishes[index]),
      onDismissed: (direction) {
        onDismissed(context, direction, dishes[index]);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: InkWell(
          onTap: () {
            onTap(context, dishes[index]);
          },
          onLongPress: () {
            onLongPress(context, dishes[index]);
          },
          child: Center(
            child: Column(
              // Stretch the cards in horizontal axis
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        dishes[index].name ?? 'Unbekannt',
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        textWidthBasis: TextWidthBasis.parent,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 16,
                          decoration: dishes[index].deleted != true
                              ? TextDecoration.none
                              : TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                    dateText,
                  ],
                ),
                Text(
                  // TODO multiple text fields with different color? or richtext
                  dishes[index].categories?.map((e) => e.name).join(' ') ?? '',
                  // set some style to text
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.lightGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
