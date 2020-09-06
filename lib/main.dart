import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:english_words/english_words.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'DishModel.dart';

import 'Database.dart';

void main() {
  initializeDateFormatting('de_DE', null).then((_) => runApp(MyApp()));
  Intl.defaultLocale = "de_DE";
}

// the list needs to build a start and end date
// we can scroll to the current date using the index
// that means we need a data model:
// list of days
// each day can have multiple dishes and notes
//
double _fontSize = 14;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ober Menu Planner',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.amber,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PlanPage(title: 'Planung'),
    );
  }
}

class PlanPage extends StatefulWidget {
  PlanPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _PlanPageState createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  final Set<WordPair> _saved = Set<WordPair>();
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final epoch = new DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  @override
  Widget build(BuildContext context) {
    var now = new DateTime.now().toUtc();
    var currentDay =
        now.difference(epoch).inDays; // ~18k -> 20k*2 = 40k for now
    return Scaffold(
        appBar: AppBar(
          title: Text('Planung'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () {
                  itemScrollController.scrollTo(
                      index: currentDay,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOutCubic);
                }),
            IconButton(
              icon: Icon(Icons.restaurant_menu),
              onPressed: _selectDish,
              tooltip: "23", // kommt bei long press
            ),
          ],
        ),
        body: ScrollablePositionedList.builder(
            initialScrollIndex: currentDay,
            padding: const EdgeInsets.all(4.0),
            itemCount: 40000,
            itemScrollController: itemScrollController,
            itemPositionsListener: itemPositionsListener,
            itemBuilder: (context, i) {
              return _buildRow(i);
            }));
  }

  Widget _buildRow(int day) {
    var d = epoch.add(Duration(days: day));
    return ListTile(
        //leading: Text(DateFormat('E\ndd.MM.yy').format(d)),
        title: Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(DateFormat('E dd.MM.yy').format(d)),
            Spacer(),
            IconButton(
              icon: Icon(Icons.add),
              // TODO zurückgegebenes dish hinzufügen https://flutter.dev/docs/cookbook/navigation/returning-data#interactive-example
              onPressed: _selectDish,
            ),
            IconButton(
              icon: Icon(Icons.note_add),
              onPressed: () {
                // TODO add editable text field
                setState(() {
                  DBProvider.db
                      .addDishToDay(day, 0, null, "something on this day");
                });
              },
            ),
          ],
        ),
        DayWidget(day: day)
      ],
    ));
  }

  void _selectDish() {
    // TODO dish zurückgeben https://flutter.dev/docs/cookbook/navigation/returning-data#interactive-example
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => DishesRoute()),
    );
  }
}

class DishesRoute extends StatelessWidget {
  Widget build(BuildContext context) {
    var dishes = ['one', 'two', 'three'];
    final Iterable<ListTile> tiles = dishes.map(
      (String dish) {
        return ListTile(
          title: Text(dish),
        );
      },
    );
    final List<Widget> divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerichte'),
      ),
      body: ListView(children: divided),
    );
  }
}

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

  bool inEditMode = false;
  final epoch = new DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<Widget>(
        future: buildDayWidget(day),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              return snapshot.data;
            } else {
              return new Text("No Data found");
            }
          }
          return new Container(
            alignment: AlignmentDirectional.center,
            child: new CircularProgressIndicator(),
          );
        });
  }

  Widget renderDishes(dishes) {
    // TODO swipe left zum löschen?
    if (dishes.length == 0) {
      return DishOrNoteWidget(dish: null);
      /*return FlatButton(
        //onPressed: toggleEditMode,
        child: Row(
            children: <Widget>[
              Text("Empty"), // TODO show nothing
              Icon(Icons.edit)
            ],
          ),

            onPressed: () {
              setState(() {
                DBProvider.db.addDishToDay(day, 0, null, "something on this day");
               // _toggleEditMode();
              });
            },
      );
      */
    }
    return Column(
      children: List.generate(dishes.length, (i) {
        return DishOrNoteWidget(dish: dishes[i]);
      }),
//        Row(
//        mainAxisSize: MainAxisSize.min,
//        children: <Widget>[
//          RaisedButton(
//            child: Text('➕'),
//            onPressed: () {
//              setState(() {
//                DBProvider.db.addDishToDay(day, 0, 0, "something on this day");
//              });
//            },
//          ),
//          RaisedButton(
//            child: Text('✍'),
//            onPressed: toggleEditMode
//            /*
//            onPressed: () {
//              setState(() {
//                DBProvider.db.addDishToDay(_day, 0, null, "something on this day");
//                _toggleEditMode();
//              });
//            },
//            */
//          ),
//        ],
//      )
    );
  }

  Future<Widget> buildDayWidget(int day) async {
    // TODO next move the future to the DayWidget, the ListTile can be immediately rendered
    List<Dish> dishes = await DBProvider.db.getDay(day);
    return renderDishes(dishes);
  }
}

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
    } else {
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
