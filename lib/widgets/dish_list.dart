import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../model/day.dart';
import '../model/dish.dart';
import '../callbacks/dish.dart';

class DishList extends StatelessWidget {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  final List<Dish> dishes;

  final Dish scrollTarget;

  /// Called when the user taps a dish.
  final DishTapCallback onTap;

  /// Called when the user long-presses a dish.
  final DishLongPressCallback onLongPress;

  /// Called when the user dismisses a dish.
  final DishDismissCallback onDismissed;
  // TODO inject?
  final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  DishList(
      {Key key,
      this.dishes,
      this.scrollTarget,
      this.onLongPress,
      this.onTap,
      this.onDismissed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dayBox = Hive.box<Day>('dayBox');
    final sorted = dayBox.keys.toList();
    sorted.sort((a, b) => b.compareTo(a));

    // hack to scroll to dish
    if (scrollTarget != null) {
      // find index of targeted dish
      for (var i = 0; i < dishes.length; i++) {
        if (dishes.elementAt(i) == scrollTarget) {
          // register a callback that is executed when tha list has been rendered
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
        itemCount: dishes == null ? 0 : dishes.length,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        itemBuilder: (BuildContext context, int index) =>
            item(context, dayBox, sorted, index));
  }

  // generate item for list
  Widget item(
      BuildContext context, Box<Day> dayBox, List<dynamic> sorted, int index) {
    // This searches from the most recent date ... will still get slow over time
    var lastCookedDay = sorted.firstWhere(
      (i) => dayBox.get(i)?.entries?.contains(dishes[index]),
      orElse: () => null,
    );

    Text dateText;
    if (lastCookedDay != null) {
      // TODO sind nur tage, wochen, monate und jahre
      // timeago forken und PR mit flags ob sekunden, minuten, stunden, tage ...
      dateText = Text(timeago.format(epoch.add(Duration(days: lastCookedDay)),
          locale:
              'de', // TODO Localizations.localeOf(context); braucht localization,
          allowFromNow: true));
    } else {
      dateText = Text('nie');
    }

    return Dismissible(
      key: ObjectKey(dishes[index]),
      onDismissed: (direction) {
        onDismissed(context, direction, dishes[index]);
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
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
                      dishes[index].name,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      textWidthBasis: TextWidthBasis.parent,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 16,
                        decoration: dishes[index].deleted != true
                            ? TextDecoration.none
                            : TextDecoration.lineThrough,
                      ),
                    )),
                    dateText,
                  ],
                ),
                Text(
                  // TODO multiple text fields with different color? or richtext
                  dishes[index].categories.map((e) => e.name).join(' '),
                  // set some style to text
                  style: TextStyle(fontSize: 12.0, color: Colors.lightGreen),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
