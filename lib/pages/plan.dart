import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:essensplan/pages/view_dish.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:hive/hive.dart';

import '../model/dish.dart';
import '../model/day.dart';
import '../widgets/dish_or_note.dart';

const dayUnselected = -1;

class PlanPage extends StatefulWidget {
  PlanPage({Key key}) : super(key: key);

  @override
  _PlanPageState createState() => _PlanPageState();
}

class DragData {
  Day source;
  int index;
  DragData(this.source, this.index);
}

class _PlanPageState extends State<PlanPage> {
  static final GlobalKey<ScaffoldState> _planKey =
      new GlobalKey<ScaffoldState>();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final epoch = new DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  int selectedDay = dayUnselected;

  @override
  Widget build(BuildContext context) {
    var currentDay = new DateTime.now()
        .toUtc()
        .difference(epoch)
        .inDays; // ~18k -> 20k*2 = 40k for now

    if (selectedDay == dayUnselected) {
      selectedDay = currentDay;
    }

    return Scaffold(
      key: _planKey,
      // show an AppBar without tools, so the StatusBar does not cover the list
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      resizeToAvoidBottomInset:
          false, // TODO scroll tapped text area into view?
      body: ScrollablePositionedList.builder(
          initialScrollIndex: currentDay,
          itemCount: 40000,
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          itemBuilder: (context, i) => item(context, i)),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.restaurant_menu),
        onPressed: selectedDay == dayUnselected
            ? null
            : () {
                _selectDish(context, selectedDay);
              },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          children: [
            GestureDetector(
              child: Padding(
                  padding: EdgeInsets.all(8.0),
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
                itemScrollController.scrollTo(
                    index: currentDay,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic);
                setState(() {
                  selectedDay = currentDay;
                });
              },
            ),
            Spacer(),
            GestureDetector(
              child: Padding(
                  padding: EdgeInsets.all(8.0),
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
              onTap: selectedDay == dayUnselected
                  ? null
                  : () {
                      setState(() {
                        var dayBox = Hive.box<Day>('dayBox');
                        var dm = dayBox.get(selectedDay);
                        if (dm == null) {
                          dm = new Day();
                          dayBox.put(selectedDay, dm);
                        }
                        if (dm.entries == null) {
                          dm.entries = new HiveList(Hive.box<Dish>('dishBox'));
                        }
                        var note = new Dish(
                            note: ""); // a hint is rendered for an empty string
                        Hive.box<Dish>('dishBox').add(note);
                        dm.entries.add(note);
                        dm.save();
                      });
                    },
            ),
            GestureDetector(
                child: Padding(
                    padding: EdgeInsets.all(8.0),
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
                  _viewCategories(context);
                }),
          ],
        ),
      ),
      /*
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNav,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            title: Text("Kalender"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank),
            title: Text("Gerichte"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            title: Text("Kategorien"),
          )
        ],
        onTap: (index) {
          setState(() {
            _currentNav = index;
          });
        },
      ),
      */
    );
  }

//  will return a widget used as an indicator for the drop position
  Widget _buildDropPreview(BuildContext context, Dish dish) {
    return Card(
      color: Colors.lightBlue[200],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(dish.name == null ? dish.note : dish.name,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
            )),
      ),
    );
  }

  // generate item for day
  Widget item(BuildContext context, int day) {
    final date = epoch.add(Duration(days: day));
    Day dm = Hive.box<Day>('dayBox').get(day);
    List<Widget> dishes = [];

    if (dm != null) {
      // for loop with item index
      for (var i = 0; i < dm.entries.length; i++) {
        // the Draggables are in a Column
        // they need to be interwoven with DragDargets
        // https://stackoverflow.com/a/64011994
        dishes.add(DragTarget<DragData>(
          builder: (context, candidates, rejects) {
            return candidates.length > 0
                ? _buildDropPreview(
                    context, candidates[0].source.entries[candidates[0].index])
                : Container(
                    width: double.infinity,
                    height: 4, // to make up for the EdgeInset of 4.0
                  );
          },
          onWillAccept: (data) => true, // TODO ignore direct neighbors
          onAccept: (data) {
            setState(() {
              dm.entries.insert(i, data.source.entries[data.index]);
              if (dm == data.source && i < data.index) {
                data.source.entries.removeAt(data.index + 1);
              } else {
                data.source.entries.removeAt(data.index);
              }
              dm.save();
              data.source.save();
            });
          },
        ));
        final Dish dish = dm.entries[i];
        dishes.add(LongPressDraggable<DragData>(
            data: DragData(dm, i),
            //dragAnchor: DragAnchor.pointer, // better leave child so we can see what we are dragging
            feedback: Card(
                child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                  dm.entries[i].name == null
                      ? dm.entries[i].note
                      : dm.entries[i].name,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
            )),
            childWhenDragging: SizedBox(
                width: MediaQuery.of(context).size.width - 20,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child:
                      Text("", style: TextStyle(fontWeight: FontWeight.bold)),
                )),
            child: Dismissible(
              key: ValueKey("day-$day[${dish.hashCode}]"),
              onDismissed: (direction) {
                setState(() {
                  dm.entries.removeAt(i);
                  dm.save();
                  dishes.removeAt(i);
                });
                // Show a snackbar. This snackbar could also contain "Undo" actions.
                _planKey.currentState.showSnackBar(SnackBar(
                    content: Text(
                        "${dish.name == null ? dish.note : dish.name} gelöscht")));
              },
              child:
                  /*SizedBox(
                  width: double.infinity,
                  child: */
                  DishOrNoteWidget(
                      dish: dish,
                      onTap: (context, dish) {
                        // unfocus current text input
                        // see https://flutterigniter.com/dismiss-keyboard-form-lose-focus/
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        if (dish.name != null) {
                          _viewDish(context, dish);
                        }
                        setState(() {
                          if (selectedDay != day) {
                            selectedDay = day;
                          }
                        });
                      },
                      noteSuffix: selectedDay != day
                          ? null
                          : LongPressDraggable<DragData>(
                              data: DragData(dm, i),
                              //dragAnchor: DragAnchor.pointer,
                              feedback: Card(
                                  child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                    dish.name == null ? dish.note : dish.name,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                              )),
                              child: Icon(
                                Icons.drag_handle,
                                size: 14,
                              ))) /*)*/,
            )));
      }
    }
    dishes.add(DragTarget<DragData>(
      builder: (context, candidates, rejects) {
        return candidates.length > 0
            ? _buildDropPreview(
                context, candidates[0].source.entries[candidates[0].index])
            : Container(
                width: double.infinity,
                height: 4, // to make up for the EdgeInset of 4.0
              );
      },
      onWillAccept: (data) => true, // TODO ignore direct neighbors
      onAccept: (data) {
        setState(() {
          if (dm == null) {
            dm = new Day();
            Hive.box<Day>('dayBox').put(day, dm);
          }
          if (dm.entries == null) {
            dm.entries = new HiveList(Hive.box<Dish>('dishBox'));
          }
          dm.entries.insert(dm.entries.length, data.source.entries[data.index]);
          if (dm == data.source && dm.entries.length < data.index) {
            data.source.entries.removeAt(data.index + 1);
          } else {
            data.source.entries.removeAt(data.index);
          }
          dm.save();
          data.source.save();
        });
      },
    ));
    return Container(
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
            color: Colors.lightGreenAccent,
          )),
        ),
        child: ListTile(
          key: ValueKey("day-$day"),
          selected: day == selectedDay,
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                DateFormat('E').format(date),
                style: TextStyle(
                    color: day == selectedDay
                        ? Theme.of(context).accentColor
                        : Theme.of(context).textTheme.bodyText1.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              Text(
                DateFormat('dd.MM').format(date),
                style: TextStyle(
                  color: day == selectedDay
                      ? Theme.of(context).accentColor
                      : Theme.of(context).textTheme.bodyText1.color,
                ),
              ),
            ],
          ),
          title: Column(
            children: dishes,
          ),
          onTap: () {
            // unfocus current text input
            // see https://flutterigniter.com/dismiss-keyboard-form-lose-focus/
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            setState(() {
              if (selectedDay != day) {
                selectedDay = day;
              }
            });
          },
        ));
  }

  // TODO scroll to focused textfiled: https://www.didierboelens.com/2018/04/hint-4-ensure-a-textfield-or-textformfield-is-visible-in-the-viewport-when-has-the-focus/

  void _selectDish(BuildContext context, int day) async {
    // TODO dish zurückgeben https://flutter.dev/docs/cookbook/navigation/returning-data#interactive-example
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.pushNamed(context, '/dishes');
    //final result = await Navigator.push(
    //  context,
    //  MaterialPageRoute<Dish>(builder: (context) => DishesPage()),
    //);

    if (result is Dish) {
      setState(() {
        var dayBox = Hive.box<Day>('dayBox');
        var dm = dayBox.get(day);
        if (dm == null) {
          dm = new Day();
          dayBox.put(day, dm);
        }
        if (dm.entries == null) {
          dm.entries = new HiveList(Hive.box<Dish>('dishBox'));
        }
        dm.entries.add(result);
        dm.save();
      });
    }
  }

  void _viewDish(BuildContext context, Dish dish) async {
    await Navigator.pushNamed(context, '/dishes/view',
        arguments: ViewDishArguments(dish));
  }

  void _viewCategories(BuildContext context) async {
    await Navigator.pushNamed(
      context, '/categories',
      // arguments: ViewDishArguments(dish)
    );
  }
}
